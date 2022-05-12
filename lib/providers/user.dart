/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wger/models/user/profile.dart';
import 'package:wger/providers/base_provider.dart';

class UserProvider with ChangeNotifier {
  final WgerBaseProvider baseProvider;
  UserProvider(this.baseProvider);

  static const _profileUrlPath = 'userprofile';
  static const _verifyEmail = 'verify-email';

  Profile? _profile;

  Profile? get profile => _profile;
  set profile(Profile? profile) {
    _profile = profile;
  }

  int get userId => _profile!.id;

  /// Clear the current profile
  void clear() {
    _profile = null;
  }

  /// Fetch the current user's profile
  Future<void> fetchAndSetProfile() async {
    final userData = await baseProvider.fetch(baseProvider.makeUrl(_profileUrlPath));
    try {
      _profile = Profile.fromJson(userData['results'][0]);
    } catch (error) {
      rethrow;
    }
  }

  /// Verify the user's email
  Future<void> verifyEmail() async {
    final userData = await baseProvider.fetch(baseProvider.makeUrl(
      _profileUrlPath,
      id: userId,
      objectMethod: _verifyEmail,
    ));
  }
}
