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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/user/profile.dart';
import 'package:wger/providers/base_provider.dart';

class UserProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  final WgerBaseProvider baseProvider;
  late SharedPreferencesAsync prefs;

  UserProvider(this.baseProvider, {SharedPreferencesAsync? prefs}) {
    this.prefs = prefs ?? PreferenceHelper.asyncPref;
    _loadThemeMode();
  }

  static const PROFILE_URL = 'userprofile';
  static const VERIFY_EMAIL = 'verify-email';

  Profile? profile;

  /// Clear the current profile
  void clear() {
    profile = null;
  }

  // change the unit of plates
  void changeUnit({changeTo = 'kg'}) {
    if (changeTo == 'kg') {
      profile?.weightUnitStr = 'lb';
    } else {
      profile?.weightUnitStr = 'kg';
    }
  }

  // Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefsDarkMode = await prefs.getBool(PREFS_USER_DARK_THEME);

    if (prefsDarkMode == null) {
      themeMode = ThemeMode.system;
    } else {
      themeMode = prefsDarkMode ? ThemeMode.dark : ThemeMode.light;
    }

    notifyListeners();
  }

  //  Change mode on switch button click
  void setThemeMode(ThemeMode mode) async {
    themeMode = mode;

    // Save to SharedPreferences
    if (themeMode == ThemeMode.system) {
      await prefs.remove(PREFS_USER_DARK_THEME);
    } else {
      await prefs.setBool(PREFS_USER_DARK_THEME, themeMode == ThemeMode.dark);
    }

    notifyListeners();
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
    await baseProvider.post(
      profile!.toJson(),
      baseProvider.makeUrl(PROFILE_URL),
    );
  }

  /// Verify the user's email
  Future<void> verifyEmail() async {
    await baseProvider.fetch(baseProvider.makeUrl(
      PROFILE_URL,
      objectMethod: VERIFY_EMAIL,
    ));
    //log(verificationData.toString());
  }
}
