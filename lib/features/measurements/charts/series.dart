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

import 'package:flutter/material.dart' show DateTimeRange;

/// A nutrition plan period shown for context: shaded as a vertical band in
/// the chart, and named in the tooltip of the points it contains.
typedef PlanPeriod = ({DateTimeRange range, String name});

class MeasurementChartEntry {
  num value;
  DateTime date;

  /// Lower and upper bound of the values [value] summarises. Set for metrics
  /// stored as a daily aggregate (heart rate min/max); the chart then draws a
  /// band around the line. Both are null for a plain sample.
  num? min;
  num? max;

  /// How many readings this point stands for, which a condensed one summarises
  /// several of. Only the distribution asks: a histogram of a handful of
  /// readings is noise, however many points they were condensed into.
  int count;

  MeasurementChartEntry(this.value, this.date, {this.min, this.max, this.count = 1});

  /// Whether this point carries a range that can be drawn as a band.
  bool get hasRange => min != null && max != null;
}

/// What a series means, which decides how it is drawn. The colours come from
/// the theme when the chart is built, not from the series itself.
enum MeasurementSeriesRole {
  /// The measured values themselves, drawn as dots.
  raw,

  /// A moving average over [raw].
  average,

  /// The smoothed trend through [raw].
  trend,

  /// One component of a multi-value metric (systolic, diastolic, ...). Every
  /// component gets its own colour and appears in the legend by name.
  component,
}

/// One line of a chart: its points and what they mean.
///
/// A chart takes a list of these, which is what lets one chart show several
/// lines (the components of a group) instead of a single measurement.
class MeasurementChartSeries {
  const MeasurementChartSeries(this.entries, this.role, {this.label});

  final List<MeasurementChartEntry> entries;
  final MeasurementSeriesRole role;

  /// Name for the legend and the tooltip. Null for the unnamed series of a
  /// plain category, where the chart title already says what is shown.
  final String? label;
}

/// One stacked bar: a day, and the value each component contributed to it.
///
/// [values] runs parallel to the components the chart was given, a null
/// standing for a component that has nothing on that day.
class MeasurementStackedEntry {
  const MeasurementStackedEntry(this.date, this.values);

  final DateTime date;
  final List<num?> values;

  /// The bar's full height, i.e. what the components add up to.
  num get total => values.fold(0, (sum, value) => sum + (value ?? 0));
}
