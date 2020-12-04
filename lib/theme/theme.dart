import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

const Color wgerPrimaryColor = Color(0xff2a4c7d);
const Color wgerPrimaryButtonColor = Color(0xff266dd3);
const Color wgerSecondaryColor = Color(0xffe63946);

// Chart colors
const charts.Color wgerChartPrimaryColor = charts.Color(r: 0x2a, g: 0x4c, b: 0x7d);
const charts.Color wgerChartSecondaryColor = charts.Color(r: 0xe6, g: 0x39, b: 0x46);

final ThemeData wgerTheme = ThemeData(
    /*
   * General stuff
   */
    primaryColor: wgerPrimaryColor,
    accentColor: wgerSecondaryColor,

    // This makes the visual density adapt to the platform that you run
    // the app on. For desktop platforms, the controls will be smaller and
    // closer together (more dense) than on mobile platforms.
    visualDensity: VisualDensity.adaptivePlatformDensity,

    /*
     * Text theme
     */
    textTheme: TextTheme(
      //headline1: TextStyle(fontSize: 30.0, fontFamily: "OpenSansBold"),
      headline2: TextStyle(fontSize: 30.0, fontFamily: "OpenSansBold"),
      //headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    ),

    /*
     * Button theme
     */
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: wgerPrimaryButtonColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        primary: wgerPrimaryButtonColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: wgerPrimaryButtonColor,
      ),
    ),

    /*
    * Forms, etc.
    */
    sliderTheme: SliderThemeData(
      activeTrackColor: wgerPrimaryButtonColor,
      thumbColor: wgerPrimaryColor,
    ));
