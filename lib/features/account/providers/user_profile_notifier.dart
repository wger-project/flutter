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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';

part 'user_profile_notifier.g.dart';

/// The IANA zone the owner's calendar days are cut in, like the server's
/// UserProfile.zone_info; null while the profile has not synced or no client
/// has reported a zone yet (the day helpers then fall back to the device zone)
final ownerTimeZoneProvider = Provider<String?>((ref) {
  final zone = ref.watch(userProfileProvider).value?.timeZone;
  return (zone == null || zone.isEmpty) ? null : zone;
});

@Riverpod(keepAlive: true)
class UserProfileNotifier extends _$UserProfileNotifier {
  late UserProfileRepository _repo;

  @override
  Stream<UserProfile?> build() {
    _repo = ref.read(userProfileRepositoryProvider);
    return _repo.watchDrift();
  }

  /// Persists the edited preferences locally; PowerSync syncs them upstream.
  Future<void> updateProfile(UserProfile profile) async {
    await _repo.editLocalDrift(profile);
  }
}
