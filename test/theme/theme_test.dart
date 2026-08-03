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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/theme/theme.dart';

void main() {
  group('wgerThemeFromScheme', () {
    test('light scheme is preserved and applied to the light theme', () {
      final scheme = ColorScheme.fromSeed(
        seedColor: const Color(0xFF112233),
        brightness: Brightness.light,
      );
      final theme = wgerThemeFromScheme(scheme);

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, scheme.primary);
      expect(theme.colorScheme.surface, scheme.surface);
    });

    test('dark scheme is preserved and applied to the dark theme', () {
      final scheme = ColorScheme.fromSeed(
        seedColor: const Color(0xFF112233),
        brightness: Brightness.dark,
      );
      final theme = wgerThemeFromScheme(scheme);

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, scheme.primary);
      expect(theme.colorScheme.surface, scheme.surface);
    });

    test('keeps the wger typography', () {
      final theme = wgerThemeFromScheme(
        ColorScheme.fromSeed(seedColor: const Color(0xFF112233)),
      );

      expect(theme.textTheme.headlineLarge?.fontFamily, wgerDisplayFont);
    });
  });
}
