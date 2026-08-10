/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

const COLOR_SURPLUS = Color.fromARGB(255, 231, 71, 71);

const _CHART_CHROMA = 60.0;
const _CHART_TONE_LIGHT = (from: 32.0, to: 75.0);
const _CHART_TONE_DARK = (from: 58.0, to: 80.0);

/// [nrOfItems] chart colors derived from the scheme's primary hue.
///
/// Hue is spread evenly around the wheel and tone ramps across the palette, so
/// neighbouring series differ in both. The lightness difference is what carries
/// in greyscale and with a color vision deficiency. The tones follow the
/// scheme's brightness, and the first color always matches the theme.
List<Color> chartColorPalette(int nrOfItems, ColorScheme scheme) {
  final count = nrOfItems < 1 ? 1 : nrOfItems;
  final baseHue = Hct.fromInt(scheme.primary.toARGB32()).hue;
  final tones = scheme.brightness == Brightness.dark ? _CHART_TONE_DARK : _CHART_TONE_LIGHT;

  return List.generate(count, (i) {
    final hue = (baseHue + 360 / count * i) % 360;
    final tone = count == 1 ? tones.from : tones.from + (tones.to - tones.from) * i / (count - 1);

    return Color(Hct.from(hue, _CHART_CHROMA, tone).toInt());
  });
}

/// Black or white, whichever contrasts more with [background].
///
/// For labels drawn directly on a data color, which has no matching `on` role
/// the way a scheme surface does.
Color onChartColor(Color background) {
  final luminance = background.computeLuminance();
  final contrastWithBlack = (luminance + 0.05) / 0.05;
  final contrastWithWhite = 1.05 / (luminance + 0.05);

  return contrastWithBlack >= contrastWithWhite ? Colors.black : Colors.white;
}

/// The palette from [chartColorPalette], repeating once exhausted so a caller
/// pulling more colors than it asked for can never run out.
Iterable<Color> generateChartColors(int nrOfItems, ColorScheme scheme) sync* {
  final colors = chartColorPalette(nrOfItems, scheme);

  while (true) {
    yield* colors;
  }
}
