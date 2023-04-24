/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

const Color wgerPrimaryColor = Color(0xff2a4c7d);
const Color wgerPrimaryButtonColor = Color(0xff266dd3);
const Color wgerPrimaryColorLight = Color(0xff94B2DB);
const Color wgerSecondaryColor = Color(0xffe63946);
const Color wgerSecondaryColorLight = Color(0xffF6B4BA);
const Color wgerBackground = Color(0xfff4f4f6);

// Make a light ColorScheme from the seeds.
final ColorScheme schemeLight = SeedColorScheme.fromSeeds(
  primary: wgerPrimaryColor,
  primaryKey: wgerPrimaryColor,
  secondaryKey: wgerSecondaryColor,
  brightness: Brightness.light,
  tones: FlexTones.vivid(Brightness.light),
);

// Make a dark ColorScheme from the seeds.
final ColorScheme schemeDark = SeedColorScheme.fromSeeds(
  primaryKey: wgerPrimaryColor,
  secondaryKey: wgerSecondaryColor,
  brightness: Brightness.dark,
  tones: FlexTones.vivid(Brightness.dark),
);

// Make a high contrast light ColorScheme from the seeds
final ColorScheme schemeLightHc = SeedColorScheme.fromSeeds(
  primaryKey: wgerPrimaryColor,
  secondaryKey: wgerSecondaryColor,
  brightness: Brightness.light,
  tones: FlexTones.ultraContrast(Brightness.light),
);

// Make a ultra contrast dark ColorScheme from the seeds.
final ColorScheme schemeDarkHc = SeedColorScheme.fromSeeds(
  primaryKey: wgerPrimaryColor,
  secondaryKey: wgerSecondaryColor,
  brightness: Brightness.dark,
  tones: FlexTones.ultraContrast(Brightness.dark),
);

// Chart colors
const charts.Color wgerChartSecondaryColor = charts.Color(r: 0xe6, g: 0x39, b: 0x46);

final wgerLightTheme = ThemeData.from(
  colorScheme: schemeLight,
  useMaterial3: true,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontFamily: 'OpenSansLight', fontWeight: FontWeight.bold),
    displayMedium:
        TextStyle(fontSize: 45, fontFamily: 'OpenSansLight', fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 36, fontFamily: 'OpenSansLight', fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(fontSize: 32, fontFamily: 'OpenSansLight'),
    headlineMedium: TextStyle(fontSize: 28, fontFamily: 'OpenSansLight'),
    headlineSmall: TextStyle(fontSize: 24, fontFamily: 'OpenSansLight'),
    titleLarge: TextStyle(fontSize: 22, fontFamily: 'OpenSansLight'),
    titleMedium: TextStyle(fontSize: 16, fontFamily: 'OpenSansLight'),
    titleSmall: TextStyle(fontSize: 14, fontFamily: 'OpenSansLight'),
    labelLarge: TextStyle(fontSize: 14, fontFamily: 'OpenSansLight'),
    labelMedium: TextStyle(fontSize: 12, fontFamily: 'OpenSansLight'),
    labelSmall: TextStyle(fontSize: 11, fontFamily: 'OpenSansLight'),
    bodyLarge: TextStyle(fontSize: 16, fontFamily: 'OpenSansLight'),
    bodyMedium: TextStyle(fontSize: 14, fontFamily: 'OpenSansLight'),
    bodySmall: TextStyle(fontSize: 12, fontFamily: 'OpenSansLight'),
  ),
);

final wgerDarkTheme = ThemeData.from(
  colorScheme: schemeDark,
  useMaterial3: true,
);

final wgerLightThemeHc = ThemeData.from(
  colorScheme: schemeLightHc,
  useMaterial3: true,
);

final wgerDarkThemeHc = ThemeData.from(
  colorScheme: schemeDarkHc,
  useMaterial3: true,
);

const wgerCalendarStyle = CalendarStyle(
// Use `CalendarStyle` to customize the UI
  outsideDaysVisible: false,
  todayDecoration: BoxDecoration(
    color: Colors.amber,
    shape: BoxShape.circle,
  ),

  markerDecoration: BoxDecoration(
    color: Colors.black,
    shape: BoxShape.circle,
  ),
  selectedDecoration: BoxDecoration(
    color: wgerSecondaryColor,
    shape: BoxShape.circle,
  ),
  rangeStartDecoration: BoxDecoration(
    color: wgerSecondaryColor,
    shape: BoxShape.circle,
  ),
  rangeEndDecoration: BoxDecoration(
    color: wgerSecondaryColor,
    shape: BoxShape.circle,
  ),
  rangeHighlightColor: wgerSecondaryColorLight,
  weekendTextStyle: TextStyle(color: wgerSecondaryColor),
);
