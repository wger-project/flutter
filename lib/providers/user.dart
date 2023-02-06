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

  static const PROFILE_URL = 'userprofile';
  static const VERIFY_EMAIL = 'verify-email';

  Profile? profile;

  /// Clear the current profile
  void clear() {
    profile = null;
  }

  /// Fetch the current user's profile
  Future<void> fetchAndSetProfile() async {
    final userData = await baseProvider.fetch(baseProvider.makeUrl(PROFILE_URL));
    try {
      profile = Profile.fromJson(userData);
    } catch (error) {
      rethrow;
    }
  }

  /// Save the user's profile to the server
  Future<void> saveProfile() async {
    final data = await baseProvider.post(
      profile!.toJson(),
      baseProvider.makeUrl(PROFILE_URL),
    );
  }

  /// Verify the user's email
  Future<void> verifyEmail() async {
    final verificationData = await baseProvider.fetch(baseProvider.makeUrl(
      PROFILE_URL,
      objectMethod: VERIFY_EMAIL,
    ));
    //log(verificationData.toString());
  }
}
