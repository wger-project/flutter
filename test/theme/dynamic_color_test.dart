/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/theme/dynamic_color.dart';

void main() {
  final light = ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4));
  final dark = ColorScheme.fromSeed(
    seedColor: const Color(0xFFB3261E),
    brightness: Brightness.dark,
  );

  group('appThemeSeed', () {
    test('is null while the setting is off, whatever the platform offers', () {
      expect(
        appThemeSeed(useDynamicColor: false, lightDynamic: light, darkDynamic: dark),
        isNull,
      );
    });

    test('is null when the platform offers nothing', () {
      expect(
        appThemeSeed(useDynamicColor: true, lightDynamic: null, darkDynamic: null),
        isNull,
      );
    });

    test('prefers the light scheme when both are present', () {
      expect(
        appThemeSeed(useDynamicColor: true, lightDynamic: light, darkDynamic: dark),
        light.primary,
      );
    });

    test('falls back to the dark scheme on its own', () {
      expect(
        appThemeSeed(useDynamicColor: true, lightDynamic: null, darkDynamic: dark),
        dark.primary,
      );
    });
  });
}
