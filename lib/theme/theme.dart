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

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Color scheme, please consult
// * https://pub.dev/packages/flex_color_scheme
// * https://rydmike.com/flexseedscheme/demo-v1/#/

const Color wgerPrimaryColor = Color(0xff2a4c7d);
const Color wgerPrimaryButtonColor = Color(0xff266dd3);
const Color wgerPrimaryColorLight = Color(0xff94B2DB);
const Color wgerSecondaryColor = Color(0xffe63946);
const Color wgerSecondaryColorLight = Color(0xffF6B4BA);
const Color wgerTertiaryColor = Color(0xFF6CA450);

/// Semantic colours that Material 3's [ColorScheme] does not provide, defined
/// per brightness so they stay legible in both light and dark themes. Access
/// via `Theme.of(context).extension<WgerColors>()!`.
@immutable
class WgerColors extends ThemeExtension<WgerColors> {
  /// Affirmative "success / done / completed" colour (e.g. a logged set).
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  const WgerColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
  });

  static const WgerColors light = WgerColors(
    success: Color(0xFF477030),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFCDEBC2),
    onSuccessContainer: Color(0xFF14521A),
  );

  static const WgerColors dark = WgerColors(
    success: Color(0xFF8AD173),
    onSuccess: Color(0xFF0A3900),
    successContainer: Color(0xFF2C4A24),
    onSuccessContainer: Color(0xFFC6F0B5),
  );

  @override
  WgerColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
  }) {
    return WgerColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    );
  }

  @override
  WgerColors lerp(ThemeExtension<WgerColors>? other, double t) {
    if (other is! WgerColors) {
      return this;
    }
    return WgerColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
    );
  }
}

const FlexSubThemesData wgerSubThemeData = FlexSubThemesData(
  fabSchemeColor: SchemeColor.secondary,
  inputDecoratorBorderType: FlexInputBorderType.underline,
  inputDecoratorIsFilled: false,
  useMaterial3Typography: true,
  appBarScrolledUnderElevation: 4,
  navigationBarIndicatorOpacity: 0.24,
  navigationBarHeight: 56,
);

const String wgerDisplayFont = 'RobotoCondensed';
const List<FontVariation> displayFontBoldWeight = [FontVariation('wght', 600)];
const List<FontVariation> displayFontHeavyWeight = [FontVariation('wght', 800)];

// Make a light ColorScheme from the seeds.
final ColorScheme schemeLight = SeedColorScheme.fromSeeds(
  primary: wgerPrimaryColor,
  primaryKey: wgerPrimaryColor,
  secondaryKey: wgerSecondaryColor,
  secondary: wgerSecondaryColor,
  tertiaryKey: wgerTertiaryColor,
  brightness: Brightness.light,
  tones: FlexTones.vivid(Brightness.light),
);

// Make a dark ColorScheme from the seeds.
final ColorScheme schemeDark = SeedColorScheme.fromSeeds(
  // primary: wgerPrimaryColor,
  primaryKey: wgerPrimaryColor,
  secondaryKey: wgerSecondaryColor,
  secondary: wgerSecondaryColor,
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

const wgerTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: wgerDisplayFont,
    fontVariations: displayFontHeavyWeight,
  ),
  displayMedium: TextStyle(
    fontFamily: wgerDisplayFont,
    fontVariations: displayFontHeavyWeight,
  ),
  displaySmall: TextStyle(
    fontFamily: wgerDisplayFont,
    fontVariations: displayFontHeavyWeight,
  ),
  headlineLarge: TextStyle(
    fontFamily: wgerDisplayFont,
    fontVariations: displayFontBoldWeight,
  ),
  headlineMedium: TextStyle(
    fontFamily: wgerDisplayFont,
    fontVariations: displayFontBoldWeight,
  ),
  headlineSmall: TextStyle(
    fontFamily: wgerDisplayFont,
    fontVariations: displayFontBoldWeight,
  ),
  titleLarge: TextStyle(
    fontFamily: wgerDisplayFont,
    fontVariations: displayFontBoldWeight,
  ),
  titleMedium: TextStyle(
    fontFamily: wgerDisplayFont,
    fontVariations: displayFontBoldWeight,
  ),
  titleSmall: TextStyle(
    fontFamily: wgerDisplayFont,
    fontVariations: displayFontBoldWeight,
  ),
);

final wgerLightTheme = FlexThemeData.light(
  colorScheme: schemeLight,
  useMaterial3: true,
  appBarStyle: FlexAppBarStyle.primary,
  subThemesData: wgerSubThemeData,
  textTheme: wgerTextTheme,
  extensions: const [WgerColors.light],
);

final wgerDarkTheme = FlexThemeData.dark(
  colorScheme: schemeDark,
  useMaterial3: true,
  subThemesData: wgerSubThemeData,
  textTheme: wgerTextTheme,
  extensions: const [WgerColors.dark],
);

final wgerLightThemeHc = FlexThemeData.light(
  colorScheme: schemeLightHc,
  useMaterial3: true,
  appBarStyle: FlexAppBarStyle.primary,
  subThemesData: wgerSubThemeData,
  textTheme: wgerTextTheme,
  extensions: const [WgerColors.light],
);

final wgerDarkThemeHc = FlexThemeData.dark(
  colorScheme: schemeDarkHc,
  useMaterial3: true,
  subThemesData: wgerSubThemeData,
  textTheme: wgerTextTheme,
  extensions: const [WgerColors.dark],
);

CalendarStyle getWgerCalendarStyle(ThemeData theme) {
  return CalendarStyle(
    outsideDaysVisible: false,
    todayDecoration: const BoxDecoration(
      color: Colors.amber,
      shape: BoxShape.circle,
    ),
    markerDecoration: BoxDecoration(
      color: theme.textTheme.headlineLarge?.color,
      shape: BoxShape.circle,
    ),
    selectedDecoration: const BoxDecoration(
      color: wgerSecondaryColor,
      shape: BoxShape.circle,
    ),
    rangeStartDecoration: const BoxDecoration(
      color: wgerSecondaryColor,
      shape: BoxShape.circle,
    ),
    rangeEndDecoration: const BoxDecoration(
      color: wgerSecondaryColor,
      shape: BoxShape.circle,
    ),
    rangeHighlightColor: wgerSecondaryColorLight,
    weekendTextStyle: const TextStyle(color: wgerSecondaryColor),
  );
}
