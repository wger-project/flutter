/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/core/exceptions/mfa_required_exception.dart';
import 'package:wger/core/helpers.dart';
import 'package:wger/core/network/api_headers.dart';
import 'package:wger/core/network/auth_credential.dart';
import 'package:wger/core/network/jwt.dart';
import 'package:wger/core/network/network_provider.dart';

/// `allauth.headless` `app` client endpoints, relative to the
/// `/allauth/app/v1/` base.
const HEADLESS_TOKENS_REFRESH_PATH = 'tokens/refresh';
const HEADLESS_AUTH_LOGIN_PATH = 'auth/login';
const HEADLESS_AUTH_SIGNUP_PATH = 'auth/signup';
const HEADLESS_AUTH_MFA_AUTHENTICATE_PATH = 'auth/2fa/authenticate';

/// Header that carries the short-lived `session_token` returned by
/// `auth/login` when a follow-up step (currently only 2FA) is still pending.
const HEADLESS_SESSION_TOKEN_HEADER = 'X-Session-Token';

/// In-memory bundle returned by the login / signup flows. Always carries a
/// [JwtCredential] (fresh logins go through `allauth.headless`); the refresh
/// token is the one the caller still needs to write to secure storage.
typedef FreshCredentials = ({JwtCredential credential, String? refreshToken});

/// The `allauth.headless` endpoints the app authenticates against: which URL
/// carries which body, and how the response envelope is read.
///
/// Knows nothing about the session it produces credentials for; what happens
/// with them (persisting, gating, publishing the state) is the notifier's.
class HeadlessAuthApi {
  final http.Client _client;

  HeadlessAuthApi(this._client);

  /// Registers a user, who is logged in by the same call: the response
  /// already carries the access + refresh tokens.
  Future<FreshCredentials> signup({
    required String username,
    required String password,
    required String email,
    required String serverUrl,
    required PackageInfo appVersion,
    String locale = 'en',
  }) async {
    final body = <String, String>{'username': username, 'password': password};
    if (email.isNotEmpty) {
      body['email'] = email;
    }

    return _post(
      serverUrl,
      HEADLESS_AUTH_SIGNUP_PATH,
      appVersion,
      body,
      extraHeaders: {HttpHeaders.acceptLanguageHeader: locale},
    );
  }

  /// Logs in with username and password. A pending second factor surfaces as
  /// [MfaRequiredException], which the caller answers with [authenticateMfa].
  Future<FreshCredentials> login({
    required String username,
    required String password,
    required String serverUrl,
    required PackageInfo appVersion,
  }) => _post(serverUrl, HEADLESS_AUTH_LOGIN_PATH, appVersion, {
    'username': username,
    'password': password,
  });

  /// Answers a pending second-factor challenge with [code] (a TOTP or a
  /// recovery code) and the session token the challenge came with.
  Future<FreshCredentials> authenticateMfa({
    required String sessionToken,
    required String code,
    required String serverUrl,
    required PackageInfo appVersion,
  }) => _post(
    serverUrl,
    HEADLESS_AUTH_MFA_AUTHENTICATE_PATH,
    appVersion,
    {'code': code},
    extraHeaders: {HEADLESS_SESSION_TOKEN_HEADER: sessionToken},
  );

  /// Exchanges a refresh token for a fresh bundle. Rotation is on by default
  /// server-side, so the token handed in is invalidated by this call and the
  /// new one is what the caller has to persist.
  Future<FreshCredentials> exchangeRefreshToken({
    required String refreshToken,
    required String serverUrl,
    required PackageInfo appVersion,
  }) => _post(serverUrl, HEADLESS_TOKENS_REFRESH_PATH, appVersion, {
    'refresh_token': refreshToken,
  });

  /// The raw token refresh, for the background path that tells a network
  /// error, a rejection and a malformed body apart, since each means
  /// something different for the session it is refreshing.
  Future<http.Response> postTokenRefresh({
    required String refreshToken,
    required String serverUrl,
    required PackageInfo appVersion,
  }) => _client.post(
    makeHeadlessUri(serverUrl, HEADLESS_TOKENS_REFRESH_PATH),
    headers: jsonApiHeaders(appVersion),
    body: json.encode({'refresh_token': refreshToken}),
  );

  Future<FreshCredentials> _post(
    String serverUrl,
    String path,
    PackageInfo appVersion,
    Map<String, String> body, {
    Map<String, String>? extraHeaders,
  }) async {
    final response = await _client.post(
      makeHeadlessUri(serverUrl, path),
      headers: jsonApiHeaders(appVersion, extraHeaders),
      body: json.encode(body),
    );
    return consumeAuthResponse(response);
  }

  /// Parses the standard `allauth.headless` auth response envelope.
  ///
  /// Returns a populated [FreshCredentials] on 200 (tokens carried in
  /// `meta`).
  ///
  /// Throws:
  /// - [MfaRequiredException] on a 401 that carries `meta.session_token`,
  ///   signalling that the user must complete a second factor before tokens
  ///   are issued.
  /// - [WgerHttpException] for any other status, or for malformed / partial
  ///   bodies on otherwise-successful responses.
  static FreshCredentials consumeAuthResponse(http.Response response) {
    final Map<String, dynamic> body;
    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw WgerHttpException(response);
    }

    if (response.statusCode == 401) {
      final meta = body['meta'] as Map<String, dynamic>?;
      final sessionToken = meta?['session_token'] as String?;
      if (sessionToken != null && sessionToken.isNotEmpty) {
        final flows = (body['data'] as Map<String, dynamic>?)?['flows'] as List<dynamic>?;
        final factors =
            flows
                ?.whereType<Map<String, dynamic>>()
                .where(
                  (f) => f['id'] == 'mfa_authenticate' && (f['is_pending'] as bool? ?? false),
                )
                .expand((f) => (f['types'] as List<dynamic>?)?.cast<String>() ?? const <String>[])
                .toList() ??
            const <String>[];
        throw MfaRequiredException(sessionToken: sessionToken, availableFactors: factors);
      }
      throw WgerHttpException(response);
    }

    if (response.statusCode != 200) {
      throw WgerHttpException(response);
    }

    // auth/login and auth/signup return the tokens under `meta`, while
    // tokens/refresh returns them under `data` (see allauth.headless source:
    // base/response.py vs tokens/response.py). Read both so this parser
    // works for either response shape.
    final meta = body['meta'] as Map<String, dynamic>?;
    final data = body['data'] as Map<String, dynamic>?;
    final accessToken = (meta?['access_token'] ?? data?['access_token']) as String?;
    if (accessToken == null || accessToken.isEmpty) {
      // 200 without tokens, likely a still-pending flow we don't know how
      // to drive. Surface as an HTTP error so the caller renders something.
      throw WgerHttpException(response);
    }
    return (
      credential: JwtCredential(
        accessToken: accessToken,
        expiresAt: jwtExp(decodeJwtPayload(accessToken)),
      ),
      refreshToken: (meta?['refresh_token'] ?? data?['refresh_token']) as String?,
    );
  }
}

final headlessAuthApiProvider = Provider<HeadlessAuthApi>(
  (ref) => HeadlessAuthApi(ref.read(authHttpClientProvider)),
);
