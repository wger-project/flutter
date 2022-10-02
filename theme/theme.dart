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

//Dark mode Light mode switch
bool darkmode = true;

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
      headline1:
          const TextStyle(fontFamily: 'OpenSansLight', color: wgerPrimaryButtonColor, fontSize: 12),
      headline2:
          const TextStyle(fontFamily: 'OpenSans', color: wgerPrimaryButtonColor, fontSize: 15),
      headline3: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'OpenSans',
        color: wgerPrimaryButtonColor,
      ),
      headline4: TextStyle(
        fontSize: materialSizes['h4']! * 0.8,
        fontFamily: 'OpenSansBold',
        color: wgerPrimaryButtonColor,
      ),
      headline5: TextStyle(
        fontSize: 16,
        fontFamily: 'OpenSansSemiBold',
        color: wgerPrimaryButtonColor,
      ),
      headline6: TextStyle(
        fontSize: materialSizes['h6']! * 0.8,
        fontFamily: 'OpenSans',
        color: wgerPrimaryButtonColor,
      ),
      subtitle1: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w200,
        fontFamily: 'OpenSans',
        color: wgerPrimaryColorLight,
      ),
      subtitle2: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w200,
        fontFamily: 'OpenSansLight',
        color: wgerPrimaryColorLight,
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

final wgerCalendarStyle = CalendarStyle(
// Use `CalendarStyle` to customize the UI
  outsideDaysVisible: false,
  todayDecoration: BoxDecoration(
    border: Border.all(color: wgerSecondaryColor, width: 2),
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

final ThemeData darkTheme = ThemeData(
  dividerColor: wgerSecondaryColorLightDark,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.white,
    unselectedItemColor: wgerSecondaryColorLightDark,
    backgroundColor: wgerPrimaryColorDark,
  ),
  focusColor: wgerSecondaryColorDark,
  splashColor: wgerPrimaryColorLightDark,
  primaryColor: wgerPrimaryColorDark,
  primaryColorDark: wgerPrimaryButtonColorDark,
  scaffoldBackgroundColor: wgerBackgroundDark,
  cardColor: wgerPrimaryColorLightDark,
  appBarTheme: AppBarTheme(color: wgerPrimaryColorDark, elevation: 10),
  textTheme: TextTheme(
    headline1: const TextStyle(fontFamily: 'OpenSansLight', color: Colors.white, fontSize: 12),
    headline2: const TextStyle(fontFamily: 'OpenSans', color: Colors.white, fontSize: 15),
    headline3: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'OpenSans',
      color: wgerSecondaryColorLightDark,
    ),
    headline4: TextStyle(
        color: wgerSecondaryColorLightDark,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontFamily: 'OpenSansBold'),
    headline5: TextStyle(
      fontSize: 16,
      fontFamily: 'OpenSansSemiBold',
      color: wgerSecondaryColorLightDark,
    ),
    headline6: TextStyle(
      fontSize: materialSizes['h6']! * 0.8,
      fontFamily: 'OpenSans',
      color: Colors.white,
    ),
    subtitle1: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w200,
      fontFamily: 'OpenSans',
      color: Colors.white,
    ),
    subtitle2: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w200,
      fontFamily: 'OpenSansLight',
      color: Colors.white,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    iconColor: wgerSecondaryColorDark,
    labelStyle: TextStyle(color: Colors.white),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      primary: wgerSecondaryColorDark,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      primary: wgerSecondaryColorDark,
      visualDensity: VisualDensity.compact,
      side: const BorderSide(color: wgerSecondaryColor),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: wgerSecondaryColorDark,
    ),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: wgerSecondaryColor,
    thumbColor: wgerPrimaryColor,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: wgerSecondaryColorDark),
);

const Color wgerPrimaryColorDark = Color(0xff1E1E2C);
const Color wgerPrimaryButtonColorDark = Colors.white;
const Color wgerPrimaryColorLightDark = Color(0xff2F3142);
const Color wgerSecondaryColorDark = Color(0xffe63946);
const Color wgerSecondaryColorLightDark = Color(0xffFFF8DE);
const Color wgerTextMutedDark = Colors.white;
const Color wgerBackgroundDark = Color(0xff1E1E2C);

class darkMode extends StatefulWidget {
  const darkMode({Key? key}) : super(key: key);

  @override
  State<darkMode> createState() => _darkModeState();
}

class _darkModeState extends State<darkMode> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: darkmode,
      onChanged: (value) {
        setState(() {
          darkmode = !darkmode;
        });
      },
    );
  }
}
