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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/user/profile.dart';
import 'package:wger/providers/user_profile_repository.dart';

part 'user_profile_notifier.g.dart';

@Riverpod(keepAlive: true)
class UserProfileNotifier extends _$UserProfileNotifier {
  late UserProfileRepository _repo;

  @override
  Future<Profile?> build() async {
    _repo = ref.read(userProfileRepositoryProvider);
    return _repo.fetchProfile();
  }

  /// Saves the current profile to the server.
  Future<void> saveProfile() async {
    final profile = state.asData?.value;
    if (profile == null) {
      return;
    }
    await _repo.saveProfile(profile);
  }

  /// Triggers the server's verification email flow.
  Future<void> verifyEmail() async {
    await _repo.verifyEmail();
  }

  /// Replaces the in-memory profile. Used by forms that edit profile fields
  /// locally before saving.
  void setProfile(Profile profile) {
    state = AsyncData(profile);
  }

  /// Clears the current profile (e.g. on logout).
  void clear() {
    state = const AsyncData(null);
  }
}
