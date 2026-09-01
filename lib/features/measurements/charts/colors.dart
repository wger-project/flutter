/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:material_ui/material_ui.dart';
import 'package:wger/features/measurements/charts/series.dart';

/// Fill of a plan period band, shared with the legend so its swatch matches.
Color planBandColor(BuildContext context) =>
    Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);

/// The component colours in order: what [componentColor] indexes into, and
/// what the spark painters take as a whole. One list, so a spark segment, its
/// full-chart line and the legend never drift apart.
List<Color> componentPalette(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return [scheme.primary, scheme.tertiary, scheme.secondary, scheme.error];
}

/// Colour of the [index]-th [MeasurementSeriesRole.component] line. Shared
/// with the legend so a component's colour matches its line.
Color componentColor(BuildContext context, int index) {
  final colors = componentPalette(context);
  return colors[index % colors.length];
}

/// Colour of a change bar, by which way it points. Theme colours rather than
/// green and red: which direction is the good one depends on the goal (losing
/// weight, building muscle), and the chart should not assert one.
Color deltaColor(BuildContext context, num delta) =>
    delta < 0 ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary;
