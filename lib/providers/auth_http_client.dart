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

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/auth_state.dart';

/// Pre-emptive refresh leeway: if the access JWT will expire within this
/// window we refresh before sending the request. Chosen to absorb mild
/// client/server clock skew without burning a refresh on every call.
const _refreshLeeway = Duration(seconds: 30);

/// HTTP client that owns the `Authorization` header for every outgoing
/// authenticated request to the wger backend.
///
/// Responsibilities:
/// - Inject the right `Authorization` value for the current credential
///   ([AuthCredential.authHeaderValue] does the dispatch).
/// - For [JwtCredential], pre-emptively refresh when the stored expiry is
///   within [_refreshLeeway] of now.
/// - On a 401 reply for a *replayable* [http.Request] body that was sent
///   with a JWT, refresh once and retry. If the retry also returns 401
///   the session is treated as genuinely revoked: [onSessionExpired]
///   runs (clear credentials + surface a snackbar) and a synthetic 401
///   is returned to the caller. Non-replayable bodies (multipart /
///   streamed) are not retried; the pre-emptive refresh in the happy
///   path is the primary safeguard.
///
/// Wrapped behind [authenticatedHttpClientProvider] so consumers
/// ([WgerBaseProvider], PowerSync's connector) get the auth handling for
/// free without needing to know about the migration state.
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

    if (credential?.needsRefresh(_refreshLeeway) ?? false) {
      _logger.fine('Pre-emptive refresh: access token within leeway window');
      await _refresh();
      credential = _readAuth()?.credential;
    }

    _applyAuthHeader(request, credential);
    final response = await _inner.send(request);

    final canRetry =
        response.statusCode == 401 && credential is JwtCredential && request is http.Request;
    if (!canRetry) {
      return response;
    }

    _logger.fine('401 on JWT request, refreshing once and retrying');
    await response.stream.drain<void>();
    await _refresh();
    final fresh = _readAuth()?.credential;
    if (fresh is! JwtCredential) {
      return _syntheticUnauthorized();
    }

    final retry = _cloneRequest(request, fresh);
    final retryResponse = await _inner.send(retry);
    if (retryResponse.statusCode == 401) {
      _logger.warning(
        'Retry after refresh still returned 401 for '
        '${request.method} ${request.url.path}, treating session as revoked',
      );
      await retryResponse.stream.drain<void>();
      await _onSessionExpired();
      return _syntheticUnauthorized();
    }
    return retryResponse;
  }

  @override
  void close() => _inner.close();

  void _applyAuthHeader(http.BaseRequest req, AuthCredential? credential) {
    if (credential == null) {
      return;
    }
    req.headers[HttpHeaders.authorizationHeader] = credential.authHeaderValue;
  }

  http.Request _cloneRequest(http.Request orig, AuthCredential credential) {
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
