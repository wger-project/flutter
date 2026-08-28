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

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:wger/features/measurements/charts/calendar.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/measurements.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';

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

/// The point level a category's chart needs.
///
/// Two charts are built on a calendar unit and fix it: a heatmap draws days, a
/// week-over-week chart weeks. A distribution has no time axis and reads
/// counted values of its own; the points it gets here are what its fallback
/// draws when there are too few values to bin.
MeasurementBucketLevel chartBucketLevel(MetricType metricType, ChartType chartType) =>
    switch (metricType.resolveChartType(chartType)) {
      ChartType.heatmap => MeasurementBucketLevel.day,
      ChartType.delta => MeasurementBucketLevel.week,
      // The summed types are drawn as daily totals whatever the range
      _ => metricType.isSummedPerDay ? MeasurementBucketLevel.day : MeasurementBucketLevel.auto,
    };

/// What a chart draws over [range]: the points in it, and the moving average
/// over them.
///
/// The average is computed over all of [points], which reach back beyond the
/// range, and only then cut, so the first ones average the days before them
/// instead of starting over at the cutoff.
({List<MeasurementChartEntry> entries, List<MeasurementChartEntry> average}) chartSeriesFor(
  List<MeasurementChartEntry> points,
  ChartRange range,
  ChartSettings settings,
) {
  final average = movingAverage(
    points,
    days: settings.averageWindow ?? ChartSettings.fallbackWindow,
  );
  final cutoff = range.cutoff;

  return cutoff == null
      ? (entries: points, average: average)
      : (entries: points.whereDate(cutoff, null), average: average.whereDate(cutoff, null));
}

/// Turns SQL-condensed buckets into chart points, converting to [targetUnit].
///
/// Chart points from the aggregated read path. A bucket
/// arrives once per unit its entries were written in, so the slices are
/// converted before they are merged. Their spread becomes the point's range,
/// left off where it says nothing (a single reading, a [summed] total).
List<MeasurementChartEntry> chartEntriesForBuckets(
  List<MeasurementBucket> buckets, {
  required String targetUnit,
  required String categoryUnit,
  bool summed = false,
}) {
  return [
    for (final MapEntry(key: start, value: slices) in groupBy(
      buckets,
      (MeasurementBucket b) => b.start,
    ).entries)
      _mergeSlices(
        start,
        slices,
        targetUnit: targetUnit,
        categoryUnit: categoryUnit,
        summed: summed,
      ),
  ];
}

/// The one point the [slices] of a bucket stand for, each converted from the
/// unit it was written in first.
MeasurementChartEntry _mergeSlices(
  DateTime start,
  List<MeasurementBucket> slices, {
  required String targetUnit,
  required String categoryUnit,
  required bool summed,
}) {
  double convert(num value, String? from) =>
      convertWeight(value, from: unitOrFallback(from, categoryUnit), to: targetUnit);

  final readings = slices.map((s) => s.count).sum;
  final total = slices.map((s) => convert(s.sum, s.unit)).sum;
  if (summed) {
    return MeasurementChartEntry(total, start, count: readings);
  }

  final value = total / readings;
  final low = slices.map((s) => convert(s.min, s.unit)).min;
  final high = slices.map((s) => convert(s.max, s.unit)).max;
  final hasRange = low < value || high > value;

  return MeasurementChartEntry(
    value,
    start,
    min: hasRange ? low : null,
    max: hasRange ? high : null,
    count: readings,
  );
}

/// The points of every component of [group], keyed by component id.
///
/// All components are condensed at one calendar unit, which is what lets the
/// halves of a reading still meet on the same point.
Map<String, List<MeasurementChartEntry>> groupComponentPoints(
  MeasurementCategory group,
  Map<String, List<MeasurementBucket>> buckets, {
  DateTime? cutoff,
}) {
  List<MeasurementChartEntry> pointsOf(MeasurementCategory child) {
    final points = chartEntriesForBuckets(
      buckets[child.id] ?? const [],
      targetUnit: child.unit,
      categoryUnit: child.unit,
      // A stage the night was slept in twice is that night's total, not the
      // average of its two stretches
      summed: child.metricType.isSummedPerDay,
    );

    return cutoff == null ? points : points.whereDate(cutoff, null);
  }

  return {for (final child in group.children) child.id!: pointsOf(child)};
}

/// The readings of a two-component group as ranges: one point per bucket,
/// spanning from the lower component to the upper one.
///
/// A reading is one event, so it is drawn as a single bar (diastolic to
/// systolic) rather than as two lines: the components belong together, and
/// nothing was measured between two readings. An unpaired half-reading is
/// skipped, it has no range.
List<MeasurementChartEntry> groupRangeEntries(Map<String, List<MeasurementChartEntry>> points) {
  final byDate = <DateTime, List<num>>{};
  for (final component in points.values) {
    for (final point in component) {
      byDate.putIfAbsent(point.date, () => []).add(point.value);
    }
  }

  return [
    for (final MapEntry(key: date, value: values) in byDate.entries)
      if (values.length > 1)
        MeasurementChartEntry(
          values.average,
          date,
          min: values.min,
          max: values.max,
        ),
  ]..sort((a, b) => a.date.compareTo(b.date));
}

/// One line per component of a multi-value group, in the children's in-group
/// order and named after them.
///
/// All components share the same range, so their lines cover the same span
/// even when one of them has fewer readings.
List<MeasurementChartSeries> groupComponentSeries(
  BuildContext context,
  MeasurementCategory group,
  Map<String, List<MeasurementChartEntry>> points,
) => [
  for (final child in group.children)
    MeasurementChartSeries(
      points[child.id] ?? const [],
      MeasurementSeriesRole.component,
      label: child.displayName(context),
    ),
];

/// The components of [group] that stack into one whole, i.e. everything but a
/// roll-up component (see [MetricType.isGroupTotal]).
List<MeasurementCategory> stackableComponents(MeasurementCategory group) =>
    group.children.where((c) => !c.metricType.isGroupTotal).toList();

/// One stacked bar per day for [components], stacked in the order they are
/// given.
///
/// Only days that any component reported are returned; the query already
/// summed a component's readings for the day the bar shows.
List<MeasurementStackedEntry> groupStackedEntries(
  List<MeasurementCategory> components,
  Map<String, List<MeasurementChartEntry>> points,
) {
  final byDay = <DateTime, List<num?>>{};
  for (final (index, child) in components.indexed) {
    for (final point in points[child.id] ?? const <MeasurementChartEntry>[]) {
      final values = byDay.putIfAbsent(
        point.date,
        () => List<num?>.filled(components.length, null),
      );
      values[index] = (values[index] ?? 0) + point.value;
    }
  }

  return [
    for (final MapEntry(key: day, value: values) in byDay.entries)
      MeasurementStackedEntry(
        day,
        values,
      ),
  ]..sort((a, b) => a.date.compareTo(b.date));
}

/// How one reading of [group] is quoted: the roll-up total alone where there
/// is one, otherwise the values joined the way the reading is read (a blood
/// pressure as 120/80, largest first).
///
/// The one place this rule lives: the overview tile and the entries screen
/// quote through it, so they can never disagree. [values] holds what was
/// measured, keyed by component id; [format] renders one value.
String quoteGroupReading(
  MeasurementCategory group,
  Map<String, num> values,
  String Function(num) format,
) {
  final total = group.children.firstWhereOrNull((c) => c.metricType.isGroupTotal)?.id;
  if (total != null && values.containsKey(total)) {
    return format(values[total]!);
  }
  return values.values.sorted((a, b) => b.compareTo(a)).map(format).join('/');
}

/// The readings of a group, newest first: one per timestamp, with what each
/// component holds for it.
///
/// Components are paired by their shared timestamp, which is how the importer
/// and the group form write them. A reading only some components reported is
/// kept, listing what there is: for a group whose parts are optional (a night
/// without deep sleep) that is the normal case, not a broken pair.
List<(DateTime, Map<String, num>)> groupReadings(
  MeasurementCategory group,
  List<MeasurementEntry> entries,
) {
  final unitOf = {for (final child in group.children) child.id!: child.unit};

  // Keyed by the component id rather than by its name: the name is translated
  // for display, and two components could carry the same one
  final byDate = <DateTime, Map<String, num>>{};
  for (final entry in entries) {
    final unit = unitOf[entry.categoryId];
    if (unit == null) {
      continue;
    }
    final values = byDate.putIfAbsent(entry.date, () => {});
    final value = entry.valueIn(unit, categoryUnit: unit);
    values[entry.categoryId] = (values[entry.categoryId] ?? 0) + value;
  }

  return [for (final MapEntry(key: date, value: values) in byDate.entries) (date, values)]
    ..sort((a, b) => b.$1.compareTo(a.$1));
}

/// Whether a group has anything to draw at all.
bool groupHasData(Map<String, List<MeasurementChartEntry>> points) =>
    points.values.any((component) => component.isNotEmpty);

/// The chart [picked] resolves to, given the data it would draw.
///
/// On top of [MetricType.resolveChartType]'s rule that a pick has to fit the
/// type, a distribution needs enough readings to be one: a histogram of a
/// handful is noise with gaps, so it falls back to the derived default. The
/// criterion lives here so every dispatch point applies it identically, or
/// the overview card and the detail screen would draw different charts.
///
/// What is counted is what the histogram bins: readings for the sample types,
/// days for the summed ones. A condensed point stands for several readings
/// ([MeasurementChartEntry.count]), so counting points would call a hundred
/// weigh-ins around one number too few to bin.
ChartType resolveChartTypeForData(
  MetricType metricType,
  ChartType picked,
  List<MeasurementChartEntry> raw,
) {
  final resolved = metricType.resolveChartType(picked);
  if (resolved != ChartType.distribution) {
    return resolved;
  }

  // For the summed types the histogram bins their daily totals, so a day is
  // what counts there; everything else bins the readings themselves
  final readings = metricType.isSummedPerDay
      ? aggregatePerDay(raw).length
      : raw.map((e) => e.count).sum;

  return readings < _distributionMinValues ? metricType.defaultChartType : resolved;
}

/// Fewest values a distribution says anything about: below this a histogram
/// is noise with gaps, and the chart falls back to the derived default. Same
/// principle as a group whose readings are all unpaired falling back to
/// lines: never an empty or misleading card.
const _distributionMinValues = 15;

/// Widest a histogram gets, in bins. A single outlier (a lb reading stored
/// into a kg category) would otherwise stretch a fixed-width histogram into
/// hundreds of near-empty bins.
const _distributionMaxBins = 100;

/// A bin width for values nothing is known about: the span split into
/// [targetBins], rounded up to 1, 2 or 5 times a power of ten so the edges
/// land on round numbers. For the typed metrics the maintained widths in
/// MetricType.binWidth are used instead.
num niceBinWidth(num min, num max, {int targetBins = 20}) {
  final span = max - min;
  if (span <= 0) {
    return 1;
  }

  final raw = span / targetBins;
  final magnitude = pow(10.0, (log(raw) / ln10).floor());
  final normalized = raw / magnitude;
  return (normalized <= 1
          ? 1
          : normalized <= 2
          ? 2
          : normalized <= 5
          ? 5
          : 10) *
      magnitude;
}

/// A distribution: the values of a period binned by size instead of plotted
/// over time, which is what shows the spread and the outliers.
class MeasurementHistogram {
  /// Lower edge of the first bin, a multiple of [binWidth] so the edges land
  /// on round numbers (60-62, not 59.3-61.3).
  final num firstEdge;

  final num binWidth;

  /// How many values each bin holds. Bins between the occupied ones are
  /// present with a zero: a gap in the distribution is worth seeing.
  final List<int> counts;

  /// Median of the binned values.
  final num median;

  /// The newest value, i.e. where in the distribution the user is today.
  final num latest;

  const MeasurementHistogram({
    required this.firstEdge,
    required this.binWidth,
    required this.counts,
    required this.median,
    required this.latest,
  });

  num lowerEdgeOf(int bin) => firstEdge + bin * binWidth;

  num upperEdgeOf(int bin) => firstEdge + (bin + 1) * binWidth;
}

/// One value and how often it occurred.
typedef ValueCount = ({num value, int count});

/// Bins values into a histogram of [binWidth]-wide bins aligned to round
/// boundaries; without a width (free-form categories) one is derived from the
/// span, see [niceBinWidth].
///
/// Values arrive counted rather than one by one, which is how the aggregated
/// query reads them. [latest] is where the user stands today; it cannot be
/// derived here, since counting a value throws away when it was measured.
///
/// What one value stands for (a reading, a daily total) is the caller's
/// decision, the same split as for the heatmap: the summed types distribute
/// their days, the sample types every reading.
MeasurementHistogram buildWeightedHistogram(
  List<ValueCount> values, {
  required num latest,
  num? binWidth,
}) {
  assert(values.isNotEmpty, 'a histogram of nothing has no bins');

  final sorted = [...values]..sort((a, b) => a.value.compareTo(b.value));
  final minValue = sorted.first.value;
  final maxValue = sorted.last.value;

  var width = binWidth ?? niceBinWidth(minValue, maxValue);
  // Doubling keeps the edges round, unlike recomputing a fitted width
  while ((maxValue / width).floor() - (minValue / width).floor() >= _distributionMaxBins) {
    width *= 2;
  }

  final firstBin = (minValue / width).floor();
  final counts = List<int>.filled((maxValue / width).floor() - firstBin + 1, 0);
  for (final entry in sorted) {
    counts[(entry.value / width).floor() - firstBin] += entry.count;
  }

  return MeasurementHistogram(
    firstEdge: firstBin * width,
    binWidth: width,
    counts: counts,
    median: _weightedMedian(sorted),
    latest: latest,
  );
}

/// The middle value of [sorted], counting each of them as often as it occurred.
num _weightedMedian(List<ValueCount> sorted) {
  final total = sorted.map((e) => e.count).sum;
  final firstHalf = _valueAt(sorted, (total - 1) ~/ 2);

  return total.isOdd ? firstHalf : (firstHalf + _valueAt(sorted, total ~/ 2)) / 2;
}

num _valueAt(List<ValueCount> sorted, int index) {
  var seen = 0;
  for (final entry in sorted) {
    seen += entry.count;
    if (index < seen) {
      return entry.value;
    }
  }
  return sorted.last.value;
}

/// A calendar heatmap laid out as a grid of week columns and weekday rows,
/// with the values it draws.
///
/// Days are addressed by their position in the grid, so nothing downstream has
/// to do calendar arithmetic: column 0 row 0 is [start], which is always a
/// Monday.
class MeasurementHeatmapGrid {
  /// Monday of the first (oldest) week column.
  final DateTime start;

  /// Number of week columns.
  final int weeks;

  /// Value of each day the grid shows that has one, keyed by the day at
  /// midnight. Days outside the window are not part of this chart and are left
  /// out, see [buildHeatmapGrid].
  final Map<DateTime, num> values;

  /// Largest value in [values], the top of the colour scale. Zero for an empty
  /// grid, and for a history that holds nothing but zeroes.
  final num maxValue;

  const MeasurementHeatmapGrid({
    required this.start,
    required this.weeks,
    required this.values,
    required this.maxValue,
  });

  /// The day in column [week], row [weekday] (0 = Monday).
  DateTime dayAt(int week, int weekday) =>
      DateTime(start.year, start.month, start.day + week * 7 + weekday);

  /// The value of that day, null when nothing was measured on it. That is the
  /// distinction the chart exists for, so it is kept apart from a zero.
  num? valueAt(int week, int weekday) => values[dayAt(week, weekday)];
}

/// Widest a heatmap gets, in week columns.
///
/// A year is where the grid stops being readable: 53 columns already put the
/// cells at a few pixels each, and a history of several years would be a wall
/// rather than a chart. The range selector above the chart can go further
/// (all-time), so the heatmap caps itself here; the month labels along the top
/// say which span is actually drawn.
const heatmapMaxWeeks = 53;

/// Lays [days] out as a calendar grid, newest week last.
///
/// Expects one entry per calendar day (see [aggregatePerDay] and
/// [averagePerDay]). The grid ends with the current week, so a stretch without
/// measurements at the end stays visible as empty cells; only a history that
/// ended longer ago than the grid is wide is anchored at its own last day
/// instead, since an empty grid shows nothing at all.
MeasurementHeatmapGrid buildHeatmapGrid(
  List<MeasurementChartEntry> days, {
  int maxWeeks = heatmapMaxWeeks,
  DateTime? today,
}) {
  final values = {for (final day in days) dayOf(day.date): day.value};
  final now = dayOf(today ?? DateTime.now());

  if (values.isEmpty) {
    return MeasurementHeatmapGrid(
      start: shiftDays(weekStart(now), -7 * (maxWeeks - 1)),
      weeks: maxWeeks,
      values: const {},
      maxValue: 0,
    );
  }

  final first = values.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  final last = values.keys.reduce((a, b) => a.isAfter(b) ? a : b);
  final oldestVisible = shiftDays(weekStart(now), -7 * (maxWeeks - 1));
  final end = weekStart(last).isBefore(oldestVisible) ? last : now;

  final endMonday = weekStart(end);
  final weeks = min(maxWeeks, daysBetween(weekStart(first), endMonday) ~/ 7 + 1);
  final start = shiftDays(endMonday, -7 * (weeks - 1));
  final lastDay = shiftDays(start, 7 * weeks - 1);

  // Only the days the grid actually shows. A history longer than the grid is
  // wide keeps its older days out of the window, and a spike among them would
  // otherwise set the top of the colour scale without being visible itself,
  // washing out every cell that is
  final visible = {
    for (final MapEntry(key: day, value: value) in values.entries)
      if (!day.isBefore(start) && !day.isAfter(lastDay)) day: value,
  };

  return MeasurementHeatmapGrid(
    start: start,
    weeks: weeks,
    values: visible,
    maxValue: visible.isEmpty ? 0 : visible.values.max,
  );
}
