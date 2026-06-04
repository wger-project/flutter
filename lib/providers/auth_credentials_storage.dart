/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/providers/secure_token_storage.dart';

/// Credential + server URL pair restored from on-disk storage. The refresh
/// token (for the JWT path) is intentionally absent: it lives in secure
/// storage and is only read when a refresh actually runs.
class StoredAuth {
  final AuthCredential credential;
  final String serverUrl;

  const StoredAuth({required this.credential, required this.serverUrl});
}

/// All persistence for the auth flow in one place. Holds the JWT-keyed
/// shared-preference bundle, the legacy `PREFS_USER` blob, and the
/// secure-storage refresh token. Lifts the storage layout details out of
/// the notifier so callers don't have to know which keys back which fact.
class AuthCredentialsStorage {
  final SecureTokenStorage _secureStorage;
  final _logger = Logger('AuthCredentialsStorage');

  AuthCredentialsStorage(this._secureStorage);

  SharedPreferencesAsync get _prefs => PreferenceHelper.asyncPref;

  /// Reads the persisted credential bundle. The headless-JWT keys take
  /// priority over the legacy `PREFS_USER` blob, so a partial migration
  /// state still resolves to the JWT path. Returns null when neither
  /// shape is fully present.
  Future<StoredAuth?> load() async {
    final jwt = await _readJwt();
    if (jwt != null) {
      return jwt;
    }
    return _readLegacy();
  }

  Future<StoredAuth?> _readJwt() async {
    final tokenType = await _prefs.getString(PREFS_TOKEN_TYPE);
    if (tokenType != AuthTokenType.headlessJwt.name) {
      return null;
    }
    final accessToken = await _prefs.getString(PREFS_ACCESS_TOKEN);
    final serverUrl = await _prefs.getString(PREFS_SERVER_URL);
    if (accessToken == null || accessToken.isEmpty || serverUrl == null || serverUrl.isEmpty) {
      return null;
    }
    final expiresAtMs = await _prefs.getInt(PREFS_ACCESS_EXPIRES_AT);
    final expiresAt = expiresAtMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expiresAtMs, isUtc: true);
    return StoredAuth(
      credential: JwtCredential(accessToken: accessToken, expiresAt: expiresAt),
      serverUrl: serverUrl,
    );
  }

  Future<StoredAuth?> _readLegacy() async {
    if (!(await _prefs.containsKey(PREFS_USER))) {
      return null;
    }
    final raw = await _prefs.getString(PREFS_USER);
    if (raw == null) {
      return null;
    }
    final Map<String, dynamic> blob;
    try {
      blob = json.decode(raw) as Map<String, dynamic>;
    } catch (e, s) {
      _logger.warning('Could not decode PREFS_USER blob', e, s);
      return null;
    }
    final token = blob['token'] as String?;
    final serverUrl = blob['serverUrl'] as String?;
    if (token == null || serverUrl == null) {
      return null;
    }
    return StoredAuth(credential: LegacyCredential(token), serverUrl: serverUrl);
  }

  /// Persists a fresh JWT bundle. As a side effect this records the
  /// server URL as the "last server" for the next login screen and wipes
  /// the legacy `PREFS_USER` blob (legacy users transition to JWT on first
  /// login through this path). The DB-owner marker is intentionally NOT
  /// written here; the login flow sets it after any required DB wipe.
  Future<void> saveJwt({
    required JwtCredential credential,
    required String serverUrl,
    String? refreshToken,
  }) async {
    await _prefs.setString(PREFS_LAST_SERVER, json.encode({'serverUrl': serverUrl}));
    await _prefs.setString(PREFS_ACCESS_TOKEN, credential.accessToken);
    if (credential.expiresAt != null) {
      await _prefs.setInt(PREFS_ACCESS_EXPIRES_AT, credential.expiresAt!.millisecondsSinceEpoch);
    } else {
      await _prefs.remove(PREFS_ACCESS_EXPIRES_AT);
    }
    await _prefs.setString(PREFS_TOKEN_TYPE, AuthTokenType.headlessJwt.name);
    await _prefs.setString(PREFS_SERVER_URL, serverUrl);

    if (refreshToken != null) {
      await _secureStorage.writeRefreshToken(refreshToken);
    }

    await clearLegacy();
  }

  /// Updates the persisted JWT bundle in place after a successful refresh.
  /// Identical to [saveJwt] minus the legacy-cleanup and last-server side
  /// effects (the original login already wrote those).
  Future<void> updateJwt({
    required JwtCredential credential,
    String? refreshToken,
  }) async {
    await _prefs.setString(PREFS_ACCESS_TOKEN, credential.accessToken);
    if (credential.expiresAt != null) {
      await _prefs.setInt(PREFS_ACCESS_EXPIRES_AT, credential.expiresAt!.millisecondsSinceEpoch);
    } else {
      await _prefs.remove(PREFS_ACCESS_EXPIRES_AT);
    }
    if (refreshToken != null) {
      await _secureStorage.writeRefreshToken(refreshToken);
    }
  }

  /// Wipes the headless-JWT preference bundle and the secure-storage
  /// refresh token. Used both for involuntary session clears and as part
  /// of a full [clearAll]. The DB-owner marker is deliberately left intact:
  /// it tracks who owns the on-disk data, which clearing credentials does
  /// not change. It is reset only when the DB is actually wiped.
  Future<void> clearJwt() async {
    await _prefs.remove(PREFS_ACCESS_TOKEN);
    await _prefs.remove(PREFS_ACCESS_EXPIRES_AT);
    await _prefs.remove(PREFS_TOKEN_TYPE);
    await _prefs.remove(PREFS_SERVER_URL);
    await _secureStorage.deleteRefreshToken();
  }

  /// Wipes only the legacy `PREFS_USER` blob. Used by the JWT-migration
  /// path on a 401 from the exchange endpoint (DRF token revoked) and as
  /// a side effect of [saveJwt].
  Future<void> clearLegacy() async {
    await _prefs.remove(PREFS_USER);
  }

  /// Wipes both credential shapes but keeps the "has ever synced" flag,
  /// so the next login takes the offline-friendly restored-session path.
  /// Used for involuntary session loss (refresh token expired, 401
  /// retries exhausted) where the local PowerSync DB is preserved.
  Future<void> clearCredentials() async {
    await clearLegacy();
    await clearJwt();
  }

  /// Manual-logout wipe: clears credentials plus the "has ever synced"
  /// flag, so the next login takes the full first-run gating path
  /// (PowerSync reachability probe etc.) again.
  Future<void> clearAll() async {
    await clearCredentials();
    await _prefs.remove(PREFS_HAS_EVER_SYNCED);
  }

  /// JWT `sub` of the user whose data sits in the local PowerSync DB, or null
  /// if none. Durable across credential clears.
  Future<String?> dbOwnerUserId() => _prefs.getString(PREFS_DB_OWNER_USER_ID);

  /// Records (or, with null, clears) the owner of the on-disk local DB.
  Future<void> setDbOwnerUserId(String? userId) async {
    if (userId == null) {
      await _prefs.remove(PREFS_DB_OWNER_USER_ID);
    } else {
      await _prefs.setString(PREFS_DB_OWNER_USER_ID, userId);
    }
  }

  /// User preference: whether a manual logout keeps the local DB on disk.
  /// Defaults to [KEEP_DATA_ON_LOGOUT_DEFAULT] (keep on logout).
  Future<bool> keepDataOnLogout() async =>
      (await _prefs.getBool(PREFS_KEEP_DATA_ON_LOGOUT)) ?? KEEP_DATA_ON_LOGOUT_DEFAULT;

  /// True once a PowerSync sync has completed for the current install.
  /// Drives the offline-friendly fast path in auto-login.
  Future<bool> hasEverSynced() async => (await _prefs.getBool(PREFS_HAS_EVER_SYNCED)) ?? false;

  Future<void> markEverSynced() => _prefs.setBool(PREFS_HAS_EVER_SYNCED, true);

  /// Reads the persisted refresh token from secure storage. Returned to
  /// callers raw because the refresh flow needs to send it verbatim to the
  /// `tokens/refresh` endpoint.
  Future<String?> readRefreshToken() => _secureStorage.readRefreshToken();
}

/// Provider over the singleton storage. Reads [secureTokenStorageProvider]
/// for the refresh-token half; shared preferences are accessed through
/// [PreferenceHelper] which already manages a single async instance.
final authCredentialsStorageProvider = Provider<AuthCredentialsStorage>(
  (ref) => AuthCredentialsStorage(ref.read(secureTokenStorageProvider)),
);
