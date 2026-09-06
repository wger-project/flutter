/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/core/network/auth_notifier.dart';
import 'package:wger/core/network/auth_state.dart';
import 'package:wger/core/network/network_provider.dart';

/// Pre-emptive refresh leeway: if the access JWT will expire within this
/// window we refresh before sending the request. Chosen to absorb mild
/// client/server clock skew without burning a refresh on every call.
const refreshLeeway = Duration(seconds: 30);

/// HTTP client that owns the `Authorization` header for every outgoing
/// authenticated request to the wger backend.
///
/// Responsibilities:
/// - Inject the `Authorization` value for the current credential.
/// - Pre-emptively refresh when the stored expiry is within
///   [refreshLeeway] of now.
/// - On a refused credential (see [_isAuthFailure]) for a *replayable*
///   [http.Request] body, refresh once and retry with the renewed
///   credential. If the refresh kept the old one (offline carve-out in
///   `_runRefresh`) the 401 goes back without a retry; a second refusal
///   counts as revoked and runs `onSessionExpired`. Non-replayable bodies
///   (multipart / streamed) are not retried.
///
/// Wrapped behind [authenticatedHttpClientProvider] so consumers
/// (`WgerBaseProvider`, PowerSync's connector) get the auth handling for
/// free.
class AuthHttpClient extends http.BaseClient {
  final http.Client _inner;
  final AuthState? Function() _readAuth;
  final Future<void> Function() _refresh;
  final Future<void> Function() _onSessionExpired;
  final _logger = Logger('AuthHttpClient');

  AuthHttpClient({
    required http.Client inner,
    required AuthState? Function() readAuth,
    required Future<void> Function() refresh,
    required Future<void> Function() onSessionExpired,
  }) : _inner = inner,
       _readAuth = readAuth,
       _refresh = refresh,
       _onSessionExpired = onSessionExpired;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var credential = _readAuth()?.credential;

    if (credential?.needsRefresh(refreshLeeway) ?? false) {
      _logger.fine('Pre-emptive refresh: access token within leeway window');
      await _refresh();
      credential = _readAuth()?.credential;
    }

    _applyAuthHeader(request, credential);
    final (refused, response) = await _isAuthFailure(await _inner.send(request));

    final canRetry = refused && credential != null && request is http.Request;
    if (!canRetry) {
      return response;
    }

    _logger.fine('Credential refused, refreshing once and retrying');
    await response.stream.drain<void>();
    await _refresh();
    final fresh = _readAuth()?.credential;
    if (fresh == null) {
      return _syntheticUnauthorized();
    }
    if (fresh == credential) {
      // Offline carve-out kept the token; the same token would be refused again
      _logger.fine('Refresh produced no new credential, reporting the refusal as 401');
      return _syntheticUnauthorized();
    }

    final retry = _cloneRequest(request, fresh);
    final (stillRefused, retryResponse) = await _isAuthFailure(await _inner.send(retry));
    if (stillRefused) {
      _logger.warning(
        'Retry after refresh was refused again for '
        '${request.method} ${request.url.path}, treating session as revoked',
      );
      await retryResponse.stream.drain<void>();
      await _onSessionExpired();
      return _syntheticUnauthorized();
    }
    return retryResponse;
  }

  /// Whether [response] means the credential we sent was refused, paired with
  /// a response the caller can still read.
  ///
  /// A 403 only counts when the body carries SimpleJWT's `token_not_valid`:
  /// the API answers an expired token with 403 rather than 401 because
  /// SessionAuthentication runs first, but a plain permission denial is not a
  /// reason to refresh or to end the session.
  Future<(bool, http.StreamedResponse)> _isAuthFailure(http.StreamedResponse response) async {
    if (response.statusCode == 401) {
      return (true, response);
    }
    if (response.statusCode != 403) {
      return (false, response);
    }
    final body = await response.stream.toBytes();
    return (_isRejectedToken(body), _withBody(response, body));
  }

  bool _isRejectedToken(List<int> body) {
    try {
      final decoded = json.decode(utf8.decode(body));
      return decoded is Map && decoded['code'] == 'token_not_valid';
    } on FormatException {
      // Not the API's JSON error shape, e.g. the plain 403 of an unauthenticated
      // request or an HTML page from a proxy in front of the server.
      return false;
    }
  }

  /// Rebuilds [response] around an already-read [body], so consuming the
  /// stream to look at it stays invisible to the caller.
  http.StreamedResponse _withBody(http.StreamedResponse response, List<int> body) =>
      http.StreamedResponse(
        Stream.value(body),
        response.statusCode,
        contentLength: body.length,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );

  @override
  void close() => _inner.close();

  void _applyAuthHeader(http.BaseRequest req, JwtCredential? credential) {
    if (credential == null) {
      return;
    }
    req.headers[HttpHeaders.authorizationHeader] = credential.authHeaderValue;
  }

  http.Request _cloneRequest(http.Request orig, JwtCredential credential) {
    final retry = http.Request(orig.method, orig.url)
      ..bodyBytes = orig.bodyBytes
      ..encoding = orig.encoding
      ..followRedirects = orig.followRedirects
      ..maxRedirects = orig.maxRedirects
      ..persistentConnection = orig.persistentConnection;
    retry.headers.addAll(orig.headers);
    _applyAuthHeader(retry, credential);
    return retry;
  }

  http.StreamedResponse _syntheticUnauthorized() => http.StreamedResponse(
    const Stream<List<int>>.empty(),
    401,
    reasonPhrase: 'Authentication lost',
  );
}

/// Provider of the authenticated HTTP client used by every data-API call.
/// Wraps the raw client from [authHttpClientProvider] (kept separate so the
/// notifier itself can issue unauthenticated requests (login, refresh,
/// version probe) without recursing through this wrapper).
final authenticatedHttpClientProvider = Provider<http.Client>(
  (ref) => AuthHttpClient(
    inner: ref.watch(authHttpClientProvider),
    readAuth: () => ref.read(authProvider).asData?.value,
    refresh: () => ref.read(authProvider.notifier).refreshAccessToken(),
    onSessionExpired: () async {
      await ref.read(authProvider.notifier).clearSessionOnly();
      showSessionExpiredSnackbar();
    },
  ),
);
