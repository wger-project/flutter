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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

const Color wgerPrimaryColor = Color(0xff2a4c7d);
const Color wgerPrimaryButtonColor = Color(0xff266dd3);
const Color wgerPrimaryColorLight = Color(0xff94B2DB);
const Color wgerSecondaryColor = Color(0xffe63946);
const Color wgerSecondaryColorLight = Color(0xffF6B4BA);
const Color wgerTextMuted = Colors.black38;
const Color wgerBackground = Color.fromARGB(255, 192, 230, 255);

// Chart colors
const charts.Color wgerChartPrimaryColor = charts.Color(r: 0x2a, g: 0x4c, b: 0x7d);
const charts.Color wgerChartSecondaryColor = charts.Color(r: 0xe6, g: 0x39, b: 0x46);

/// Original sizes for the material text theme
/// https://api.flutter.dev/flutter/material/TextTheme-class.html
const materialSizes = {
  'h1': 96.0,
  'h2': 60.0,
  'h3': 48.0,
  'h4': 34.0,
  'h5': 24.0,
  'h6': 20.0,
};

final ThemeData wgerTheme = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      iconColor: wgerSecondaryColor,
      labelStyle: TextStyle(color: Colors.black),
    ),

    /*
    * General stuff
    */
    primaryColor: wgerPrimaryColor,
    scaffoldBackgroundColor: wgerBackground,

    // This makes the visual density adapt to the platform that you run
    // the app on. For desktop platforms, the controls will be smaller and
    // closer together (more dense) than on mobile platforms.
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Show icons in the system's bar in light colors
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      color: wgerPrimaryColor,
    ),

    /*
     * Text theme
     */
    textTheme: TextTheme(
      headline1: const TextStyle(fontFamily: 'OpenSansLight', color: wgerPrimaryButtonColor),
      headline2: const TextStyle(fontFamily: 'OpenSansLight', color: wgerPrimaryButtonColor),
      headline3: TextStyle(
        fontSize: materialSizes['h3']! * 0.8,
        fontFamily: 'OpenSansBold',
        color: wgerPrimaryButtonColor,
      ),
      headline4: TextStyle(
        fontSize: materialSizes['h4']! * 0.8,
        fontFamily: 'OpenSansBold',
        color: wgerPrimaryButtonColor,
      ),
      headline5: TextStyle(
        fontSize: materialSizes['h5'],
        fontFamily: 'OpenSansBold',
        color: wgerPrimaryButtonColor,
      ),
      headline6: TextStyle(
        fontSize: materialSizes['h6']! * 0.8,
        fontFamily: 'OpenSansBold',
        color: wgerPrimaryButtonColor,
      ),
    ),

    /*
     * Button theme
     */
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: wgerSecondaryColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        primary: wgerSecondaryColor,
        visualDensity: VisualDensity.compact,
        side: const BorderSide(color: wgerSecondaryColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: wgerSecondaryColor,
      ),
    ),

    /*
    * Forms, etc.
    */
    sliderTheme: const SliderThemeData(
      activeTrackColor: wgerSecondaryColor,
      thumbColor: wgerPrimaryColor,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: wgerSecondaryColor));

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
