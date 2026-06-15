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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/user/user_profile.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return UserProfileRepository(db);
});

/// Local data access for the user's profile preferences
class UserProfileRepository {
  final _logger = Logger('UserProfileRepository');
  final DriftPowersyncDatabase _db;

  UserProfileRepository(this._db);

  /// Streams the synced profile row, or null until it has synced down.
  Stream<UserProfile?> watchDrift() {
    _logger.finer('Watching local user profile');
    return _db.select(_db.userProfileTable).watchSingleOrNull();
  }

  /// Writes the edited preferences locally; PowerSync pushes them upstream.
  Future<void> editLocalDrift(UserProfile profile) async {
    _logger.finer('Updating local user profile ${profile.id}');
    await (_db.update(
      _db.userProfileTable,
    )..where((t) => t.id.equals(profile.id))).write(profile.toCompanion());
  }
}
