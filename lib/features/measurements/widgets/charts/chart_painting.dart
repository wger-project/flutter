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

/// What the hand-painted charts (heatmap, spark, distribution) share, so the
/// full chart and its spark stay the same picture at two sizes.
library;

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Colour of a heatmap cell holding [value].
///
/// A day without a measurement is neutral, everything else is tinted by how
/// large its value is within the grid. The scale is continuous and starts
/// well above transparent: a day that was measured has to read as measured
/// even when its value is the smallest one.
Color heatmapCellColor(
  num? value, {
  required num maxValue,
  required Color filled,
  required Color empty,
}) {
  if (value == null) {
    return empty;
  }
  final share = maxValue <= 0 ? 1.0 : (value / maxValue).clamp(0.0, 1.0);
  return Color.lerp(filled.withValues(alpha: 0.3), filled, share)!;
}

/// The gap between heatmap cells, following the cell size: a fixed one is a
/// hairline on a wide grid and half the cell on a year of columns, where it
/// turns the squares into scattered dots.
double heatmapCellGap(double step) => (step * 0.18).clamp(1.0, 3.0);

/// Rounded, but never so much that a small cell becomes a dot.
Radius heatmapCellRadius(double cell) => Radius.circular(min(2, cell / 4));

/// Lays [text] out as a single unwrapped line; the call sites position it.
TextPainter singleLineLabel(String text, TextStyle style, {required double maxWidth}) =>
    TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
      ellipsis: '',
    )..layout(maxWidth: maxWidth);
