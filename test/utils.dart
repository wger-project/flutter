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

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/exercises.dart';

import 'measurements/measurement_provider_test.mocks.dart';
import 'other/base_provider_test.mocks.dart';

// Test Auth provider
final AuthProvider testAuthProvider = AuthProvider(MockClient(), false)
  ..token = 'FooBar'
  ..serverUrl = 'https://localhost';

// Test Exercises provider
final mockBaseProvider = MockWgerBaseProvider();
final ExercisesProvider testExercisesProvider = ExercisesProvider(mockBaseProvider);

// Load app fonts
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  String derivedFontFamily(Map<String, dynamic> fontDefinition) {
    const List<String> overridableFonts = <String>[
      'Roboto',
      '.SF UI Display',
      '.SF UI Text',
      '.SF Pro Text',
      '.SF Pro Display',
    ];

    if (!fontDefinition.containsKey('family')) {
      return '';
    }

    final String fontFamily = fontDefinition['family'];

    if (overridableFonts.contains(fontFamily)) {
      return fontFamily;
    }

    if (fontFamily.startsWith('packages/')) {
      final fontFamilyName = fontFamily.split('/').last;
      if (overridableFonts.any((font) => font == fontFamilyName)) {
        return fontFamilyName;
      }
    } else {
      for (final Map<String, dynamic> fontType in fontDefinition['fonts']) {
        final String? asset = fontType['asset'];
        if (asset != null && asset.startsWith('packages')) {
          final packageName = asset.split('/')[1];
          return 'packages/$packageName/$fontFamily';
        }
      }
    }
    return fontFamily;
  }

  final fontManifest = await rootBundle.loadStructuredData<Iterable<dynamic>>(
    'FontManifest.json',
        (string) async => json.decode(string),
  );

  for (final Map<String, dynamic> font in fontManifest) {
    final fontLoader = FontLoader(derivedFontFamily(font));
    for (final Map<String, dynamic> fontType in font['fonts']) {
      fontLoader.addFont(rootBundle.load(fontType['asset']));
    }
    await fontLoader.load();
  }
}