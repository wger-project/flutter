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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// A nutrition plan period shown for context: shaded as a vertical band in
/// the chart, and named in the tooltip of the points it contains.
typedef PlanPeriod = ({DateTimeRange range, String name});

/// Fill of a plan period band, shared with the legend so its swatch matches.
Color planBandColor(BuildContext context) =>
    Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);

/// The parts of [periods] that overlap [bounds], clamped to it. Periods
/// entirely outside [bounds] are dropped.
List<DateTimeRange> clampPeriods(List<DateTimeRange> periods, DateTimeRange bounds) => [
  for (final period in periods)
    if (period.start.isBefore(bounds.end) && period.end.isAfter(bounds.start))
      DateTimeRange(
        start: period.start.isAfter(bounds.start) ? period.start : bounds.start,
        end: period.end.isBefore(bounds.end) ? period.end : bounds.end,
      ),
];

/// Colour of the [index]-th [MeasurementSeriesRole.component] line. Shared
/// with the legend so a component's colour matches its line.
Color componentColor(BuildContext context, int index) {
  final scheme = Theme.of(context).colorScheme;
  final colors = [scheme.primary, scheme.tertiary, scheme.secondary, scheme.error];
  return colors[index % colors.length];
}

/// Colour of a change bar, by which way it points. Theme colours rather than
/// green and red: which direction is the good one depends on the goal (losing
/// weight, building muscle), and the chart should not assert one.
Color deltaColor(BuildContext context, num delta) =>
    delta < 0 ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary;

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

/// For each point, the average of all the points in the [days] preceding it.
List<MeasurementChartEntry> movingAverage(List<MeasurementChartEntry> vals, {int days = 7}) {
  var start = 0;
  var end = 0;
  final List<MeasurementChartEntry> out = <MeasurementChartEntry>[];

  // first make sure our list is in ascending order, without reordering the
  // caller's own list
  final sorted = [...vals]..sort((a, b) => a.date.compareTo(b.date));

  // The window total is carried along instead of re-summing the window for
  // every point: with densely sampled metrics the window holds thousands of
  // values, and re-adding them each time makes this quadratic
  num sum = 0;

  while (end < sorted.length) {
    sum += sorted[end].value;

    // since users can log measurements several days, or minutes apart,
    // we can't make assumptions.  We have to manually advance 'start'
    // such that it is always the first point within our desired range.
    // posibly start == end (when there is only one point in the range)
    final intervalStart = sorted[end].date.subtract(Duration(days: days));
    while (start < end && sorted[start].date.isBefore(intervalStart)) {
      sum -= sorted[start].value;
      start++;
    }

    out.add(MeasurementChartEntry(sum / (end - start + 1), sorted[end].date));

    end++;
  }
  return out;
}

/// Produces a smoothed trendline via an Exponential Moving Average (EMA),
/// seeded with the first data point. A larger [period] tracks the raw values
/// more loosely (smoother, more lag).
List<MeasurementChartEntry> smoothedTrendline(
  List<MeasurementChartEntry> vals, {
  int period = 10,
}) {
  if (vals.isEmpty) {
    return [];
  }

  final sorted = [...vals]..sort((a, b) => a.date.compareTo(b.date));
  final List<MeasurementChartEntry> out = [];

  // Seed the initialization layer with the first data point value
  double currentEma = sorted[0].value.toDouble();
  final double smoothing = 2 / (period + 1);

  for (int i = 0; i < sorted.length; i++) {
    final point = sorted[i];

    if (i > 0) {
      // EMA equation: point.weight * smoothing + ema * (1 - smoothing)
      currentEma = (point.value * smoothing) + (currentEma * (1 - smoothing));
    }

    out.add(MeasurementChartEntry(currentEma, point.date));
  }

  return out;
}

/// The Monday of the week [date] falls into, at midnight.
DateTime weekStart(DateTime date) =>
    DateTime(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));

/// Sums entries per calendar day. Used for metric types where individual
/// samples aren't meaningful on their own (steps, distance, energy, sleep) —
/// see MeasurementMetricType.isSummedPerDay.
List<MeasurementChartEntry> aggregatePerDay(List<MeasurementChartEntry> vals) {
  if (vals.isEmpty) {
    return [];
  }

  // Bucket by the day component only (strip time-of-day).
  final Map<DateTime, num> sums = {};
  for (final e in vals) {
    final day = DateTime(e.date.year, e.date.month, e.date.day);
    sums.update(day, (existing) => existing + e.value, ifAbsent: () => e.value);
  }

  final out = sums.entries.map((e) => MeasurementChartEntry(e.value, e.key)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return out;
}

/// Averages entries per calendar day.
///
/// The per-day counterpart of [aggregatePerDay] for the sample metrics (body
/// weight, heart rate), where a day's readings are repeated measurements of the
/// same thing and adding them up would be meaningless. Used by the charts that
/// need exactly one value per day.
List<MeasurementChartEntry> averagePerDay(List<MeasurementChartEntry> vals) {
  if (vals.isEmpty) {
    return [];
  }

  final byDay = groupBy(
    vals,
    (MeasurementChartEntry e) => DateTime(e.date.year, e.date.month, e.date.day),
  );

  return [
    for (final day in byDay.keys.toList()..sort())
      MeasurementChartEntry(byDay[day]!.map((e) => e.value).average, day),
  ];
}

/// The level a week is summarised at: its total for the summed metric types,
/// its average for the sample ones, whose readings repeat the same measurement.
num _weekLevel(List<MeasurementChartEntry> week, bool summed) =>
    summed ? week.map((e) => e.value).sum : week.map((e) => e.value).average;

/// Week-over-week change: one point per calendar week against the last week
/// with readings, summarised (see [_weekLevel]) before subtracting so no single
/// reading decides a bar. The running week of a summed metric is left out,
/// its total is still growing and would read as a drop until Sunday.
List<MeasurementChartEntry> weeklyDeltas(
  List<MeasurementChartEntry> vals, {
  bool summed = false,
  DateTime? today,
}) {
  final byWeek = groupBy(vals, (MeasurementChartEntry e) => weekStart(e.date));
  if (summed) {
    byWeek.remove(weekStart(today ?? DateTime.now()));
  }
  final weeks = byWeek.keys.toList()..sort();

  return [
    for (final (index, week) in weeks.indexed.skip(1))
      MeasurementChartEntry(
        _weekLevel(byWeek[week]!, summed) - _weekLevel(byWeek[weeks[index - 1]]!, summed),
        week,
      ),
  ];
}
