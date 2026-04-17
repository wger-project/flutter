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
import 'package:wger/models/user/profile.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/wger_base_riverpod.dart';

const _PROFILE_URL = 'userprofile';
const _VERIFY_EMAIL = 'verify-email';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final base = ref.read(wgerBaseProvider);
  return UserProfileRepository(base);
});

class UserProfileRepository {
  final _logger = Logger('UserProfileRepository');
  final WgerBaseProvider _base;

  UserProfileRepository(this._base);

  Future<Profile> fetchProfile() async {
    _logger.finer('Fetching user profile');
    final data = await _base.fetch(_base.makeUrl(_PROFILE_URL));
    return Profile.fromJson(data);
  }

  Future<void> saveProfile(Profile profile) async {
    _logger.finer('Saving user profile');
    await _base.post(profile.toJson(), _base.makeUrl(_PROFILE_URL));
  }

  Future<void> verifyEmail() async {
    _logger.finer('Requesting email verification');
    await _base.fetch(_base.makeUrl(_PROFILE_URL, objectMethod: _VERIFY_EMAIL));
  }
}
