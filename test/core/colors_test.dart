/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) wger Team
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
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/colors.dart';
import 'package:wger/theme/theme.dart';

void main() {
  final light = wgerLightTheme.colorScheme;
  final dark = wgerDarkTheme.colorScheme;

  double hueOf(Color c) => Hct.fromInt(c.toARGB32()).hue;
  double toneOf(Color c) => Hct.fromInt(c.toARGB32()).tone;

  group('chartColorPalette', () {
    test('returns as many colors as requested', () {
      for (final count in [1, 3, 5, 8, 15]) {
        expect(chartColorPalette(count, light), hasLength(count));
      }
    });

    test('falls back to a single color for zero or negative counts', () {
      expect(chartColorPalette(0, light), hasLength(1));
      expect(chartColorPalette(-5, light), hasLength(1));
    });

    test('starts at the scheme primary hue', () {
      expect(
        hueOf(chartColorPalette(5, light).first),
        closeTo(hueOf(light.primary), 1),
      );
    });

    test('spreads the hues evenly around the wheel', () {
      for (final count in [3, 6]) {
        final hues = chartColorPalette(count, light).map(hueOf).toList();

        for (var i = 1; i < count; i++) {
          final delta = (hues[i] - hues[i - 1] + 360) % 360;
          expect(delta, closeTo(360 / count, 2), reason: 'uneven step at n=$count');
        }
      }
    });

    test('yields distinct colors', () {
      expect(chartColorPalette(8, light).toSet(), hasLength(8));
    });

    test('ramps the tone across the palette', () {
      for (final scheme in [light, dark]) {
        final tones = chartColorPalette(5, scheme).map(toneOf).toList();

        for (var i = 1; i < tones.length; i++) {
          expect(tones[i], greaterThan(tones[i - 1]));
        }
      }
    });

    test('keeps the dark palette light enough for a dark surface', () {
      // The old fixed palette was tuned for light backgrounds only.
      expect(chartColorPalette(6, dark).every((c) => toneOf(c) >= 55), isTrue);
    });
  });

  group('onChartColor', () {
    double contrast(Color a, Color b) {
      final values = [a.computeLuminance(), b.computeLuminance()]..sort();

      return (values.last + 0.05) / (values.first + 0.05);
    }

    test('switches between white and black along the tone ramp', () {
      expect(
        chartColorPalette(6, light).map(onChartColor).toSet(),
        containsAll(<Color>[Colors.white, Colors.black]),
      );
    });

    test('always picks the higher-contrast option', () {
      final colors = [
        ...chartColorPalette(8, light),
        ...chartColorPalette(8, dark),
        COLOR_SURPLUS,
        Colors.white,
        Colors.black,
      ];

      for (final color in colors) {
        final picked = onChartColor(color);
        final other = picked == Colors.black ? Colors.white : Colors.black;
        expect(
          contrast(color, picked),
          greaterThanOrEqualTo(contrast(color, other)),
          reason: 'wrong pick for $color',
        );
      }
    });

    test('clears 4.5:1 on the generated palette', () {
      for (final scheme in [light, dark]) {
        for (final color in chartColorPalette(8, scheme)) {
          expect(contrast(color, onChartColor(color)), greaterThan(4.5));
        }
      }
    });
  });

  group('generateChartColors', () {
    test('yields the palette in order', () {
      final palette = chartColorPalette(5, light);
      final iterator = generateChartColors(5, light).iterator;

      for (final expected in palette) {
        expect(iterator.moveNext(), isTrue);
        expect(iterator.current, equals(expected));
      }
    });

    test('repeats instead of running out or falling back to black', () {
      final palette = chartColorPalette(3, light);
      final iterator = generateChartColors(3, light).iterator;

      for (var i = 0; i < 12; i++) {
        expect(iterator.moveNext(), isTrue);
        expect(iterator.current, equals(palette[i % palette.length]));
        expect(iterator.current, isNot(equals(Colors.black)));
      }
    });

    test('keeps yielding for zero items', () {
      final iterator = generateChartColors(0, light).iterator;

      expect(iterator.moveNext(), isTrue);
      expect(iterator.moveNext(), isTrue);
    });
  });
}
