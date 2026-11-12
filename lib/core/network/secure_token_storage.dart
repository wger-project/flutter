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

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wger/core/consts.dart';

/// Keychain status `errSecInteractionNotAllowed`: the item exists but its
/// protection class keeps it sealed right now (device locked).
const _errSecInteractionNotAllowed = -25308;

/// Secure storage cannot be read at the moment, but may hold a token. Unlike
/// a missing or undecryptable token this says nothing about the session.
class SecureStorageLockedException implements Exception {
  final Object cause;

  const SecureStorageLockedException(this.cause);

  @override
  String toString() => 'SecureStorageLockedException: $cause';
}

/// Persists the headless refresh token in platform-level secure storage
/// (Keychain on iOS, EncryptedSharedPreferences on Android).
///
/// Wrapped behind an interface so tests can substitute an in-memory mock
/// without touching platform channels.
abstract interface class SecureTokenStorage {
  /// Persists [token] under the well-known refresh-token key. Overwrites any
  /// previous value.
  Future<void> writeRefreshToken(String token);

  /// Returns the persisted refresh token, or null if none is stored. Throws
  /// [SecureStorageLockedException] while the storage is temporarily sealed.
  Future<String?> readRefreshToken();

  /// Removes the persisted refresh token. No-op when none is stored.
  Future<void> deleteRefreshToken();
}

class FlutterSecureTokenStorage implements SecureTokenStorage {
  final FlutterSecureStorage _storage;

  // A background refresh (phone locked between sets) must still read the
  // token. Existing items move to this class on their next write.
  const FlutterSecureTokenStorage([
    this._storage = const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    ),
  ]);

  @override
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: SECURE_STORAGE_REFRESH_TOKEN, value: token);

  @override
  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: SECURE_STORAGE_REFRESH_TOKEN);
    } on PlatformException catch (e) {
      if (e.details == _errSecInteractionNotAllowed) {
        throw SecureStorageLockedException(e);
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteRefreshToken() => _storage.delete(key: SECURE_STORAGE_REFRESH_TOKEN);
}

final secureTokenStorageProvider = Provider<SecureTokenStorage>(
  (ref) => const FlutterSecureTokenStorage(),
);
