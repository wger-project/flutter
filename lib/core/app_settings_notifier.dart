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
import 'package:wger/core/consts.dart';
import 'package:wger/core/http_overrides.dart';
import 'package:wger/core/locale.dart';
import 'package:wger/core/logs.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

part 'app_settings_notifier.freezed.dart';
part 'app_settings_notifier.g.dart';

const PREFS_DASHBOARD_CONFIG = 'dashboardConfig';

enum DashboardWidget {
  trophies('trophies'),
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

    /// Locale override. Null means the app follows the system locale.
    Locale? userLocale,

    /// When true, a manual logout keeps the local database on disk instead
    /// of wiping it, so the same user signing back in resumes incrementally.
    @Default(KEEP_DATA_ON_LOGOUT_DEFAULT) bool keepDataOnLogout,

    /// When true, an invalid TLS certificate is accepted from the self-hosted
    /// server the app is configured for. Never applies to the official servers.
    @Default(ALLOW_SELF_SIGNED_CERTS_DEFAULT) bool allowSelfSignedCerts,

    /// When true, the app palette follows the platform dynamic colors
    /// (system wallpaper on Android 12+) instead of the fixed wger seeds.
    /// A no-op on platforms without dynamic color support.
    @Default(USE_DYNAMIC_COLOR_DEFAULT) bool useDynamicColor,

    /// When true, everything is logged instead of only INFO and above.
    @Default(VERBOSE_LOGGING_DEFAULT) bool verboseLogging,
  }) = _AppSettings;
}

/// Every widget in its declared order, all visible: what a fresh install gets
/// and what is shown while the stored arrangement is still being read
final defaultDashboardItems = List<DashboardItem>.unmodifiable(
  DashboardWidget.values.map((widget) => DashboardItem(widget)),
);

const _storedKeys = {
  PREFS_USER_DARK_THEME,
  PREFS_USER_LOCALE,
  PREFS_DASHBOARD_CONFIG,
  PREFS_KEEP_DATA_ON_LOGOUT,
  PREFS_ALLOW_SELF_SIGNED_CERTS,
  PREFS_USE_DYNAMIC_COLOR,
  PREFS_VERBOSE_LOGGING,
};

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

    // One round trip for all of them: every consumer shows a default until
    // this resolves, and the dashboard has nothing to show at all
    final stored = await _prefs.getAll(allowList: _storedKeys);

    return AppSettings(
      themeMode: _readThemeMode(stored),
      userLocale: _matchSupportedLocale(stored[PREFS_USER_LOCALE] as String?),
      dashboardItems: _readDashboardItems(stored),
      keepDataOnLogout: stored[PREFS_KEEP_DATA_ON_LOGOUT] as bool? ?? KEEP_DATA_ON_LOGOUT_DEFAULT,
      allowSelfSignedCerts: _readAllowSelfSignedCerts(stored),
      useDynamicColor: stored[PREFS_USE_DYNAMIC_COLOR] as bool? ?? USE_DYNAMIC_COLOR_DEFAULT,
      verboseLogging: _readVerboseLogging(stored),
    );
  }

  //
  // Theme mode
  //

  static ThemeMode _readThemeMode(Map<String, Object?> stored) {
    final dark = stored[PREFS_USER_DARK_THEME] as bool?;
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
  // Locale override
  //

  /// Match a stored locale tag (`languageCode` or `languageCode_subtag`)
  /// against [AppLocalizations.supportedLocales]. Returns the exact supported
  /// instance to keep dropdown identity stable, or null when no match is found.
  static Locale? _matchSupportedLocale(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    for (final locale in AppLocalizations.supportedLocales) {
      if (encodeLocale(locale) == raw) {
        return locale;
      }
    }
    // Fallback: match by language only (e.g. stored "pl" picks the only pl).
    final lang = raw.split('_').first;
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == lang &&
          (locale.countryCode == null || locale.countryCode!.isEmpty) &&
          (locale.scriptCode == null || locale.scriptCode!.isEmpty)) {
        return locale;
      }
    }
    return null;
  }

  /// Override the app locale. Passing `null` clears the override and falls
  /// back to the system locale.
  Future<void> setUserLocale(Locale? locale) async {
    final current = state.asData?.value ?? const AppSettings();
    state = AsyncData(current.copyWith(userLocale: locale));

    if (locale == null) {
      await _prefs.remove(PREFS_USER_LOCALE);
    } else {
      await _prefs.setString(PREFS_USER_LOCALE, encodeLocale(locale));
    }
  }

  //
  // Keep local data on logout
  //

  Future<void> setKeepDataOnLogout(bool value) async {
    final current = state.asData?.value ?? const AppSettings();
    state = AsyncData(current.copyWith(keepDataOnLogout: value));
    await _prefs.setBool(PREFS_KEEP_DATA_ON_LOGOUT, value);
  }

  //
  // Allow self-signed certificates
  //

  static bool _readAllowSelfSignedCerts(Map<String, Object?> stored) {
    final value = stored[PREFS_ALLOW_SELF_SIGNED_CERTS] as bool? ?? ALLOW_SELF_SIGNED_CERTS_DEFAULT;
    // The override reads a static, so mirror the setting on both load and write
    // and it can never drift from this provider.
    WgerHttpOverrides.allowSelfSignedCerts = value;
    return value;
  }

  Future<void> setAllowSelfSignedCerts(bool value) async {
    final current = state.asData?.value ?? const AppSettings();
    state = AsyncData(current.copyWith(allowSelfSignedCerts: value));
    WgerHttpOverrides.allowSelfSignedCerts = value;
    await _prefs.setBool(PREFS_ALLOW_SELF_SIGNED_CERTS, value);
  }

  //
  // Use dynamic color
  //

  Future<void> setUseDynamicColor(bool value) async {
    final current = state.asData?.value ?? const AppSettings();
    state = AsyncData(current.copyWith(useDynamicColor: value));
    await _prefs.setBool(PREFS_USE_DYNAMIC_COLOR, value);
  }

  //
  // Verbose logging
  //

  static bool _readVerboseLogging(Map<String, Object?> stored) {
    final value = stored[PREFS_VERBOSE_LOGGING] as bool? ?? VERBOSE_LOGGING_DEFAULT;
    // main() already seeds the level from the same key, applying it here as
    // well keeps the two from drifting apart.
    applyVerboseLogging(value);
    return value;
  }

  Future<void> setVerboseLogging(bool value) async {
    final current = state.asData?.value ?? const AppSettings();
    state = AsyncData(current.copyWith(verboseLogging: value));
    applyVerboseLogging(value);
    await _prefs.setBool(PREFS_VERBOSE_LOGGING, value);
  }

  //
  // Dashboard config
  //

  static List<DashboardItem> _readDashboardItems(Map<String, Object?> stored) {
    final jsonString = stored[PREFS_DASHBOARD_CONFIG] as String?;
    if (jsonString == null) {
      return defaultDashboardItems;
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
    // The screen shows the default arrangement while this resolves, editing
    // on top of that would persist it over the stored one
    final current = await future;
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
    final current = await future;
    final items = List<DashboardItem>.of(current.dashboardItems);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

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
