/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/user/profile.dart';
import 'package:wger/providers/base_provider.dart';

enum DashboardWidget {
  routines('routines'),
  nutrition('nutrition'),
  weight('weight'),
  measurements('measurements'),
  calendar('calendar');

  final String value;
  const DashboardWidget(this.value);

  static DashboardWidget? fromString(String s) {
    for (final e in DashboardWidget.values) {
      if (e.value == s) {
        return e;
      }
    }
    return null;
  }
}

class DashboardItem {
  final DashboardWidget widget;
  bool isVisible;

  DashboardItem(this.widget, {this.isVisible = true});

  Map<String, dynamic> toJson() => {
    'widget': widget.value,
    'visible': isVisible,
  };
}

class UserProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  final WgerBaseProvider baseProvider;
  late SharedPreferencesAsync prefs;

  UserProvider(this.baseProvider, {SharedPreferencesAsync? prefs}) {
    this.prefs = prefs ?? PreferenceHelper.asyncPref;
    _loadThemeMode();
    _loadDashboardConfig();
  }

  static const String PREFS_DASHBOARD_CONFIG = 'dashboardConfig';
  static const PROFILE_URL = 'userprofile';
  static const VERIFY_EMAIL = 'verify-email';

  Profile? profile;

  /// Clear the current profile
  void clear() {
    profile = null;
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

  // Dashboard configuration
  List<DashboardItem> _dashboardItems = DashboardWidget.values
      .map((w) => DashboardItem(w))
      .toList();

  List<DashboardWidget> get dashboardOrder => _dashboardItems.map((e) => e.widget).toList();

  Future<void> _loadDashboardConfig() async {
    final jsonString = await prefs.getString(PREFS_DASHBOARD_CONFIG);
    if (jsonString == null) {
      notifyListeners();
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final List<DashboardItem> loaded = [];

      for (final item in decoded) {
        final widget = DashboardWidget.fromString(item['widget']);
        if (widget != null) {
          loaded.add(
            DashboardItem(widget, isVisible: item['visible'] as bool),
          );
        }
      }

      // Add any missing widgets (e.g. newly added features)
      for (final widget in DashboardWidget.values) {
        if (!loaded.any((item) => item.widget == widget)) {
          loaded.add(DashboardItem(widget));
        }
      }

      _dashboardItems = loaded;
    } catch (_) {
      // parsing failed -> keep defaults
    }
    notifyListeners();
  }

  Future<void> _saveDashboardConfig() async {
    final serializable = _dashboardItems.map((e) => e.toJson()).toList();
    await prefs.setString(PREFS_DASHBOARD_CONFIG, jsonEncode(serializable));
  }

  bool isDashboardWidgetVisible(DashboardWidget key) {
    final widget = _dashboardItems.firstWhereOrNull((e) => e.widget == key);
    return widget == null || widget.isVisible;
  }

  Future<void> setDashboardWidgetVisible(DashboardWidget key, bool visible) async {
    final item = _dashboardItems.firstWhereOrNull((e) => e.widget == key);
    if (item == null) {
      return;
    }

    item.isVisible = visible;
    await _saveDashboardConfig();
    notifyListeners();
  }

  Future<void> setDashboardOrder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _dashboardItems.removeAt(oldIndex);
    _dashboardItems.insert(newIndex, item);

    await _saveDashboardConfig();
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
    await baseProvider.fetch(
      baseProvider.makeUrl(
        PROFILE_URL,
        objectMethod: VERIFY_EMAIL,
      ),
    );
    //log(verificationData.toString());
  }
}
