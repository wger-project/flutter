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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/providers/auth_credentials_storage.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/providers/helpers.dart';

/// `/api/v2/` endpoints used by the gating chain.
const _MIN_APP_VERSION_PATH = 'min-app-version';
const _SERVER_VERSION_PATH = 'version';

/// Outcome of the post-credentials gating chain. The notifier folds this
/// into an [AuthState] with the credential / serverUrl / appVersion
/// it already has.
class GatingResult {
  final AuthStatus status;
  final String? serverVersion;

  const GatingResult({required this.status, this.serverVersion});
}

/// Server-side reachability and version checks that gate "we have valid
/// credentials" from "the user can actually use the app".
class ServerGating {
  final http.Client _client;
  final AuthCredentialsStorage _storage;
  final _logger = Logger('ServerGating');

  ServerGating(this._client, this._storage);

  /// Runs the gating chain in order: server version → min app version →
  /// PowerSync reachability (only on the first-time path). Returns the
  /// resulting [AuthStatus] plus the fetched [serverVersion] so the
  /// caller can surface it in the auth state regardless of which gate
  /// triggered.
  Future<GatingResult> resolve({
    required AuthCredential credential,
    required String serverUrl,
    required PackageInfo appVersion,
  }) async {
    final serverVersion = await fetchServerVersion(serverUrl);
    if (serverUpdateRequired(serverVersion)) {
      return GatingResult(
        status: AuthStatus.serverUpdateRequired,
        serverVersion: serverVersion,
      );
    }

    if (await applicationUpdateRequired(serverUrl, appVersion.version)) {
      return GatingResult(
        status: AuthStatus.appUpdateRequired,
        serverVersion: serverVersion,
      );
    }

    if (!await isPowerSyncReachable(serverUrl: serverUrl, credential: credential)) {
      return GatingResult(
        status: AuthStatus.powerSyncUnreachable,
        serverVersion: serverVersion,
      );
    }

    return GatingResult(status: AuthStatus.loggedIn, serverVersion: serverVersion);
  }

  /// HEAD probe against `/routine` to confirm the server is reachable
  /// and accepts our credential. Returns null when the request couldn't
  /// leave the device (offline, TLS handshake failure, etc.) so callers
  /// can distinguish "we couldn't reach the server" from "the server said
  /// no". Only the latter is grounds for logging the user out.
  Future<http.Response?> probe({
    required AuthCredential credential,
    required String serverUrl,
    required PackageInfo appVersion,
  }) async {
    try {
      return await _client.head(
        makeUri(serverUrl, 'routine'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.userAgentHeader: getAppNameHeader(appVersion),
          HttpHeaders.authorizationHeader: credential.authHeaderValue,
        },
      );
    } on Exception catch (e, s) {
      if (isNetworkError(e)) {
        _logger.warning('wger probe: server unreachable: $e', e, s);
        return null;
      }
      rethrow;
    }
  }

  /// Detects reverse-proxy misconfiguration on the wger server by
  /// confirming pagination URLs returned by the API point back to the
  /// same host and scheme as the configured [serverUrl]. Returns true
  /// when the configuration looks fine (or the check could not be
  /// completed conclusively, so the caller defaults to permissive).
  Future<bool> serverConfigSane({
    required String serverUrl,
    required AuthCredential credential,
  }) async {
    try {
      final baseUri = Uri.parse(serverUrl);
      final response = await _client.get(
        Uri.parse('$serverUrl/api/v2/exercise/?limit=1'),
        headers: {
          HttpHeaders.authorizationHeader: credential.authHeaderValue,
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return true;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final nextUrl = data['next'] as String?;
      if (nextUrl == null) {
        return true;
      }

      final nextUri = Uri.parse(nextUrl);
      return nextUri.host.toLowerCase() == baseUri.host.toLowerCase() &&
          nextUri.scheme == baseUri.scheme;
    } catch (e) {
      _logger.info('serverConfigSane check failed: $e');
      return true;
    }
  }

  /// Tries to reach the PowerSync service and returns true if it looks
  /// alive. Only runs the first time a user logs in (subsequent calls
  /// short-circuit via [AuthCredentialsStorage.hasEverSynced]); on
  /// success the flag is set so future starts skip the probe.
  Future<bool> isPowerSyncReachable({
    required String serverUrl,
    required AuthCredential credential,
  }) async {
    if (await _storage.hasEverSynced()) {
      return true;
    }

    try {
      final tokenResponse = await _client.get(
        makeUri(serverUrl, 'powersync-token', trailingSlash: false),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: credential.authHeaderValue,
        },
      );
      if (tokenResponse.statusCode != 200) {
        _logger.warning(
          'PowerSync probe: token endpoint returned ${tokenResponse.statusCode}',
        );
        return false;
      }
      final body = json.decode(tokenResponse.body) as Map<String, dynamic>;
      final powerSyncUrl = body['powersync_url'] as String?;
      if (powerSyncUrl == null || powerSyncUrl.isEmpty) {
        _logger.warning('PowerSync probe: empty powersync_url in token response');
        return false;
      }

      final probeUri = Uri.parse(
        '$powerSyncUrl${powerSyncUrl.endsWith('/') ? '' : '/'}probes/liveness',
      );
      final probeResponse = await _client.get(probeUri);
      if (probeResponse.statusCode == 200) {
        await _storage.markEverSynced();
        return true;
      }
      _logger.warning('PowerSync probe: liveness returned ${probeResponse.statusCode}');
      return false;
    } on Exception catch (e, s) {
      _logger.warning('PowerSync probe failed: $e', e, s);
      return false;
    }
  }

  /// Fetches the server's reported version, or null when it can't be read
  /// (non-200, unparseable body, or network error). Null is handled leniently
  /// by [serverUpdateRequired], so a transient blip doesn't gate the user out.
  Future<String?> fetchServerVersion(String serverUrl) async {
    try {
      final response = await _client.get(makeUri(serverUrl, _SERVER_VERSION_PATH));
      if (response.statusCode != 200) {
        _logger.warning('fetchServerVersion: status ${response.statusCode}, skipping check');
        return null;
      }
      final decoded = json.decode(response.body);
      return decoded is String ? decoded : null;
    } on Exception catch (e, s) {
      _logger.warning('fetchServerVersion failed: $e', e, s);
      return null;
    }
  }

  /// Whether the server requires a newer app build. Lenient: on a non-200,
  /// unparseable body, or network error the check is skipped (returns false),
  /// so a transient blip doesn't lock the user out.
  Future<bool> applicationUpdateRequired(String serverUrl, String appVersion) async {
    try {
      final response = await _client.get(makeUri(serverUrl, _MIN_APP_VERSION_PATH));
      if (response.statusCode != 200) {
        _logger.warning(
          'applicationUpdateRequired: status ${response.statusCode}, skipping check',
        );
        return false;
      }
      final decoded = json.decode(response.body);
      if (decoded is! String) {
        _logger.warning('applicationUpdateRequired: unexpected body, skipping check');
        return false;
      }
      final current = Version.parse(appVersion);
      final required = Version.parse(decoded);
      final needUpdate = required > current;
      if (needUpdate) {
        _logger.fine('Application update required: $required > $current');
      }
      return needUpdate;
    } on Exception catch (e, s) {
      _logger.warning('applicationUpdateRequired failed: $e', e, s);
      return false;
    }
  }
}

/// Checks whether the connected server meets the minimum version required
/// by this build of the app.
///
/// Returns false (lenient) when the version cannot be read or parsed, so
/// users aren't locked out on unexpected server configurations.
bool serverUpdateRequired(String? rawVersion) {
  final logger = Logger('ServerGating');
  if (rawVersion == null) {
    logger.warning('serverUpdateRequired: serverVersion is null, skipping check');
    return false;
  }

  // Strip common non-semver suffixes emitted by Python/Django backends,
  // e.g. '2.5.0a2' → '2.5.0', '2.3.0 (git-abc1234)' → '2.3.0'.
  final sanitized = rawVersion
      .replaceFirst(RegExp(r'\s.*$'), '')
      .replaceFirst(RegExp(r'[a-zA-Z].*$'), '');

  final Version current;
  try {
    current = Version.parse(sanitized);
  } on FormatException {
    logger.warning(
      'serverUpdateRequired: could not parse server version "$rawVersion" '
      '(sanitized: "$sanitized"), skipping check',
    );
    return false;
  }
  final required = Version.parse(MIN_SERVER_VERSION);
  final needUpdate = current < required;
  if (needUpdate) {
    logger.fine('Server update required: server $current < minimum $required');
  }
  return needUpdate;
}

/// Provider over the singleton gating service. Uses the raw HTTP client
/// from [authHttpClientProvider] (probes are unauthenticated or carry the
/// credential explicitly, so the auth-injecting wrapper is the wrong
/// dependency here).
final serverGatingProvider = Provider<ServerGating>(
  (ref) => ServerGating(
    ref.read(authHttpClientProvider),
    ref.read(authCredentialsStorageProvider),
  ),
);
