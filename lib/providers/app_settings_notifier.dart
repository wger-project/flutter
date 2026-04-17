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

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';

part 'app_settings_notifier.freezed.dart';
part 'app_settings_notifier.g.dart';

const PREFS_DASHBOARD_CONFIG = 'dashboardConfig';

enum DashboardWidget {
  networkInfo('networkInfo'),
  trophies('trophies'),
  routines('routines'),
  nutrition('nutrition'),
  weight('weight'),
  measurements('measurements'),
  calendar('calendar')
  ;

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
  final bool isVisible;

  const DashboardItem(this.widget, {this.isVisible = true});

  DashboardItem copyWith({bool? isVisible}) =>
      DashboardItem(widget, isVisible: isVisible ?? this.isVisible);

  Map<String, dynamic> toJson() => {
    'widget': widget.value,
    'visible': isVisible,
  };
}

@freezed
sealed class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default([]) List<DashboardItem> dashboardItems,
  }) = _AppSettings;
}

/// SharedPreferences accessor for local settings. Override in tests.
final appSettingsPrefsProvider = Provider<SharedPreferencesAsync>(
  (ref) => PreferenceHelper.asyncPref,
);

@Riverpod(keepAlive: true)
class AppSettingsNotifier extends _$AppSettingsNotifier {
  late SharedPreferencesAsync _prefs;

  @override
  Future<AppSettings> build() async {
    _prefs = ref.read(appSettingsPrefsProvider);
    final themeMode = await _loadThemeMode();
    final items = await _loadDashboardItems();
    return AppSettings(themeMode: themeMode, dashboardItems: items);
  }

  //
  // Theme mode
  //

  Future<ThemeMode> _loadThemeMode() async {
    final dark = await _prefs.getBool(PREFS_USER_DARK_THEME);
    if (dark == null) {
      return ThemeMode.system;
    }
    return dark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.asData?.value ?? const AppSettings();
    state = AsyncData(current.copyWith(themeMode: mode));

    if (mode == ThemeMode.system) {
      await _prefs.remove(PREFS_USER_DARK_THEME);
    } else {
      await _prefs.setBool(PREFS_USER_DARK_THEME, mode == ThemeMode.dark);
    }
  }

  //
  // Dashboard config
  //

  Future<List<DashboardItem>> _loadDashboardItems() async {
    final jsonString = await _prefs.getString(PREFS_DASHBOARD_CONFIG);
    if (jsonString == null) {
      return DashboardWidget.values.map((w) => DashboardItem(w)).toList();
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final List<DashboardItem> loaded = [];

      for (final item in decoded) {
        final widget = DashboardWidget.fromString(item['widget']);
        if (widget != null) {
          loaded.add(DashboardItem(widget, isVisible: item['visible'] as bool));
        }
      }

      // Add any missing widgets (e.g. newly added features)
      for (final widget in DashboardWidget.values) {
        if (!loaded.any((item) => item.widget == widget)) {
          var index = DashboardWidget.values.indexOf(widget);
          if (index > loaded.length) {
            index = loaded.length;
          }
          loaded.insert(index, DashboardItem(widget));
        }
      }

      return loaded;
    } catch (_) {
      return DashboardWidget.values.map((w) => DashboardItem(w)).toList();
    }
  }

  Future<void> _persistDashboard(List<DashboardItem> items) async {
    final serializable = items.map((e) => e.toJson()).toList();
    await _prefs.setString(PREFS_DASHBOARD_CONFIG, jsonEncode(serializable));
  }

  Future<void> setWidgetVisible(DashboardWidget key, bool visible) async {
    final current = state.asData?.value ?? const AppSettings();
    final updated = current.dashboardItems.map((item) {
      if (item.widget == key) {
        return item.copyWith(isVisible: visible);
      }
      return item;
    }).toList();

    state = AsyncData(current.copyWith(dashboardItems: updated));
    await _persistDashboard(updated);
  }

  Future<void> setDashboardOrder(int oldIndex, int newIndex) async {
    var to = newIndex;
    if (oldIndex < to) {
      to -= 1;
    }
    final current = state.asData?.value ?? const AppSettings();
    final items = List<DashboardItem>.of(current.dashboardItems);
    final item = items.removeAt(oldIndex);
    items.insert(to, item);

    state = AsyncData(current.copyWith(dashboardItems: items));
    await _persistDashboard(items);
  }
}

extension DashboardConfigQuery on List<DashboardItem> {
  /// List of visible dashboard widgets, in the configured order.
  List<DashboardWidget> get visibleWidgets =>
      where((w) => w.isVisible).map((w) => w.widget).toList();

  /// All dashboard widgets, in the configured order (including hidden).
  List<DashboardWidget> get allWidgets => map((w) => w.widget).toList();

  bool isWidgetVisible(DashboardWidget key) {
    final item = firstWhereOrNull((e) => e.widget == key);
    return item == null || item.isVisible;
  }
}
