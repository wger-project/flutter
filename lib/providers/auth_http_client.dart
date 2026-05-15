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
/// - Pick the right scheme per [AuthTokenType]: `Bearer <jwt>` for the
///   `headlessJwt` flow, `Token <key>` for the legacy DRF token flow.
/// - For `headlessJwt`, pre-emptively refresh the access token when the
///   stored `accessExpiresAt` is within [_refreshLeeway] of now.
/// - On a 401 reply for a *replayable* `http.Request` body, refresh once
///   and retry. If the retry also returns 401, the user is logged out.
///   Non-replayable bodies (multipart / streamed) are not retried; the
///   pre-emptive refresh in the happy path is the primary safeguard.
///
/// Wrapped behind [authenticatedHttpClientProvider] so consumers
/// ([WgerBaseProvider], PowerSync's connector) get the auth handling for
/// free without needing to know about the migration state.
class AuthHttpClient extends http.BaseClient {
  final http.Client _inner;
  final AuthState? Function() _readAuth;
  final Future<void> Function() _refresh;
  final Future<void> Function() _logout;
  final _logger = Logger('AuthHttpClient');

  AuthHttpClient({
    required http.Client inner,
    required AuthState? Function() readAuth,
    required Future<void> Function() refresh,
    required Future<void> Function() logout,
  }) : _inner = inner,
       _readAuth = readAuth,
       _refresh = refresh,
       _logout = logout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var auth = _readAuth();

    if (_shouldPreemptivelyRefresh(auth)) {
      _logger.fine('Pre-emptive refresh: access token within leeway window');
      await _refresh();
      auth = _readAuth();
    }

    _applyAuthHeader(request, auth);
    final response = await _inner.send(request);

    final canRetry =
        response.statusCode == 401 &&
        auth?.tokenType == AuthTokenType.headlessJwt &&
        request is http.Request;
    if (!canRetry) {
      return response;
    }

    _logger.fine('401 on headless JWT request, refreshing once and retrying');
    await response.stream.drain<void>();
    await _refresh();
    final fresh = _readAuth();
    if (fresh?.tokenType != AuthTokenType.headlessJwt || fresh?.accessToken == null) {
      // Refresh failed → caller already logged the user out. Surface a
      // 401 to the request issuer so its error handling fires.
      return _syntheticUnauthorized();
    }

    final retry = _cloneRequest(request, fresh);
    final retryResponse = await _inner.send(retry);
    if (retryResponse.statusCode == 401) {
      _logger.warning('Retry after refresh still returned 401, logging out');
      await retryResponse.stream.drain<void>();
      await _logout();
      return _syntheticUnauthorized();
    }
    return retryResponse;
  }

  @override
  void close() => _inner.close();

  bool _shouldPreemptivelyRefresh(AuthState? auth) {
    if (auth?.tokenType != AuthTokenType.headlessJwt) {
      return false;
    }
    final expiresAt = auth?.accessExpiresAt;
    if (expiresAt == null) {
      return false;
    }
    return expiresAt.isBefore(DateTime.now().toUtc().add(_refreshLeeway));
  }

  void _applyAuthHeader(http.BaseRequest req, AuthState? auth) {
    if (auth == null) {
      return;
    }
    final String? value;
    switch (auth.tokenType) {
      case AuthTokenType.headlessJwt:
        value = auth.accessToken != null ? 'Bearer ${auth.accessToken}' : null;
      case AuthTokenType.legacyApiToken:
        value = auth.token != null ? 'Token ${auth.token}' : null;
      case null:
        value = null;
    }
    if (value != null) {
      req.headers[HttpHeaders.authorizationHeader] = value;
    }
  }

  http.Request _cloneRequest(http.Request orig, AuthState? auth) {
    final retry = http.Request(orig.method, orig.url)
      ..bodyBytes = orig.bodyBytes
      ..encoding = orig.encoding
      ..followRedirects = orig.followRedirects
      ..maxRedirects = orig.maxRedirects
      ..persistentConnection = orig.persistentConnection;
    retry.headers.addAll(orig.headers);
    _applyAuthHeader(retry, auth);
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
    logout: () => ref.read(authProvider.notifier).logout(),
  ),
);
