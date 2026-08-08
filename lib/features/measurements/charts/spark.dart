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

/// What the spark chart of an overview tile draws: the miniature a category's
/// chart type survives as, and the window the range filter gives it. The
/// widgets that paint it live in `../widgets/charts/spark_charts.dart`.
library;

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:wger/features/measurements/charts/calendar.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';

/// The shapes a spark chart comes in. Fewer than the full chart types: a
/// distribution does not survive miniaturisation and a group's structural
/// charts (floating, stacked) are bar sparks with more than one segment.
enum SparkKind { line, bars, delta, heatmap }

/// Fewest and most week columns of a heatmap spark. The filter decides within
/// these: below the floor a heatmap says nothing about regularity, above the
/// cap the columns stop fitting the tile as legible cells.
const sparkHeatmapMinWeeks = 4;
const sparkHeatmapMaxWeeks = 16;

/// Longest a bar or delta spark gets, in weekly slots. Bounds the unlimited
/// range: a year of weeks is where the slots reach hairline width.
const sparkMaxWeeks = 52;

/// Widest window drawn as one slot per day. Beyond it the daily bars fall
/// below legibility and the bar family switches to weekly slots.
const sparkWeeklyThresholdDays = 35;

/// Fewest points in the window before a line spark draws dots instead: a line
/// through a handful of readings claims a continuity they do not have.
const sparkSparseMinDays = 3;

/// The spark a category of [metricType] is drawn as, honoring [picked]
/// wherever the format survives miniaturisation.
///
/// A distribution has no time axis to shrink, so it falls back to the type's
/// default spark, the same principle as `resolveChartTypeForData`'s fallback
/// for a pick that does not fit its data.
SparkKind sparkKindFor(MetricType metricType, ChartType picked) =>
    switch (metricType.resolveChartType(picked)) {
      ChartType.heatmap => SparkKind.heatmap,
      ChartType.delta => SparkKind.delta,
      ChartType.bar => SparkKind.bars,
      ChartType.distribution => metricType.isSummedPerDay ? SparkKind.bars : SparkKind.line,
      _ => SparkKind.line,
    };

/// The stretch a spark covers and how it is slotted.
///
/// [start] doubles as the query bound and identifies a provider, so it is
/// always a midnight (see `ChartRange.countCutoff` for the same rule). It is
/// null only for a full-history line, whose start follows from the data.
class SparkWindow {
  const SparkWindow({this.start, this.days, this.weekly = false});

  final DateTime? start;
  final int? days;

  /// Whether the bars hold one week rather than one day. Weekly windows start
  /// on a Monday, so the slots are calendar weeks.
  final bool weekly;

  /// How many slots a bar spark lays across the width.
  int? get slotCount => days == null ? null : (weekly ? days! ~/ 7 : days);
}

/// The window a spark of [kind] draws under the range filter, whose cutoff is
/// passed in (null for the full history).
///
/// The line follows the filter as it is. The bar family switches to weekly
/// slots beyond [sparkWeeklyThresholdDays] and is capped at [sparkMaxWeeks];
/// the heatmap follows it within its own, tighter legibility bounds. The
/// delta window gets one slot beyond its weeks for the running week.
SparkWindow sparkWindowFor(SparkKind kind, {required DateTime? cutoff, DateTime? today}) {
  final now = dayOf(today ?? DateTime.now());
  final days = cutoff == null ? null : daysBetween(dayOf(cutoff), now) + 1;
  int weeksOf(int? days) => days == null ? sparkMaxWeeks : min(sparkMaxWeeks, (days / 7).ceil());

  switch (kind) {
    case SparkKind.heatmap:
      final weeks = weeksOf(days).clamp(sparkHeatmapMinWeeks, sparkHeatmapMaxWeeks);
      return SparkWindow(
        start: shiftDays(weekStart(now), -7 * (weeks - 1)),
        days: 7 * weeks,
        weekly: true,
      );

    case SparkKind.delta:
      final weeks = weeksOf(days);
      return SparkWindow(
        start: shiftDays(weekStart(now), -7 * weeks),
        days: 7 * (weeks + 1),
        weekly: true,
      );

    case SparkKind.bars:
      if (days != null && days <= sparkWeeklyThresholdDays) {
        return SparkWindow(start: dayOf(cutoff!), days: days);
      }
      final weeks = weeksOf(days);
      return SparkWindow(
        start: shiftDays(weekStart(now), -7 * (weeks - 1)),
        days: 7 * weeks,
        weekly: true,
      );

    case SparkKind.line:
      return days == null ? const SparkWindow() : SparkWindow(start: dayOf(cutoff!), days: days);
  }
}

/// Whether the window holds too few points for a line, see [sparkSparseMinDays].
bool sparkIsSparse(List<MeasurementChartEntry> days) => days.length < sparkSparseMinDays;

/// One point per calendar week: the mean of the week's daily values, carrying
/// the span of everything measured in it as its range.
///
/// The mean rather than the sum, so a weekly bar keeps the daily level and the
/// axis does not jump by a factor of seven when the range filter crosses the
/// weekly threshold. The plain bars ignore the range; the floating bars draw
/// it (a week of blood pressure readings from diastolic to systolic).
List<MeasurementChartEntry> sparkWeeklyPoints(List<MeasurementChartEntry> days) => [
  for (final MapEntry(key: week, value: ofWeek) in groupBy(
    days,
    (MeasurementChartEntry e) => weekStart(e.date),
  ).entries)
    MeasurementChartEntry(
      ofWeek.map((e) => e.value).average,
      week,
      min: ofWeek.map((e) => e.min ?? e.value).min,
      max: ofWeek.map((e) => e.max ?? e.value).max,
    ),
]..sort((a, b) => a.date.compareTo(b.date));

/// One stacked bar per calendar week: per component the mean over the days it
/// reported, so the stack keeps the height of a typical night.
List<MeasurementStackedEntry> sparkWeeklyStacks(List<MeasurementStackedEntry> days) {
  if (days.isEmpty) {
    return const [];
  }

  final components = days.first.values.length;
  return [
    for (final MapEntry(key: week, value: ofWeek) in groupBy(
      days,
      (MeasurementStackedEntry e) => weekStart(e.date),
    ).entries)
      MeasurementStackedEntry(week, [
        for (var component = 0; component < components; component++)
          switch (ofWeek.map((e) => e.values[component]).nonNulls.toList()) {
            [] => null,
            final reported => reported.average,
          },
      ]),
  ]..sort((a, b) => a.date.compareTo(b.date));
}

/// One piece of a spark bar: plain bars have one from zero, floating bars one
/// spanning the reading, stacked bars one per component. The colour index
/// picks the component colour and is 0 for the single-segment shapes.
typedef SparkSegment = ({num from, num to, int colorIndex});

/// One bar and the slot it sits in.
typedef SparkBar = ({int slot, List<SparkSegment> segments});

/// What a bar spark draws: [slotCount] slots across the width, of which only
/// the measured ones hold a bar.
class SparkBarsData {
  final int slotCount;
  final List<SparkBar> bars;

  /// Whether the values are changes: their bars hang off a zero hairline and
  /// point both ways.
  final bool signed;

  const SparkBarsData({required this.slotCount, required this.bars, this.signed = false});

  bool get isEmpty => bars.isEmpty;

  Iterable<num> get _drawn sync* {
    for (final bar in bars) {
      for (final segment in bar.segments) {
        yield segment.from;
        yield segment.to;
      }
    }
  }

  /// Bounds of everything drawn, including the zero line of a signed spark.
  /// Zero for an empty spark, which is never painted.
  num get minValue => signed ? _drawn.fold(0, (a, b) => a < b ? a : b) : _fold((a, b) => a < b);

  num get maxValue => signed ? _drawn.fold(0, (a, b) => a > b ? a : b) : _fold((a, b) => a > b);

  num _fold(bool Function(num, num) keepFirst) =>
      _drawn.isEmpty ? 0 : _drawn.reduce((a, b) => keepFirst(a, b) ? a : b);
}

/// One plain bar per entry, from zero to its value, slotted per day or, with
/// `slotDays: 7` and a Monday [start], per calendar week.
SparkBarsData sparkBars(
  List<MeasurementChartEntry> entries, {
  required DateTime start,
  required int slotCount,
  int slotDays = 1,
}) => SparkBarsData(
  slotCount: slotCount,
  bars: _slotted(
    entries,
    start,
    slotDays,
    slotCount,
    (e) => e.date,
    (e) => [
      (from: 0, to: e.value, colorIndex: 0),
    ],
  ),
);

/// One floating bar per entry, spanning the reading's range (a blood pressure
/// day or week from diastolic to systolic). Points without a range carry a
/// single value and are drawn as a short bar around it.
SparkBarsData sparkFloatingBars(
  List<MeasurementChartEntry> ranges, {
  required DateTime start,
  required int slotCount,
  int slotDays = 1,
}) => SparkBarsData(
  slotCount: slotCount,
  bars: _slotted(
    ranges,
    start,
    slotDays,
    slotCount,
    (e) => e.date,
    (e) => [
      (from: e.min ?? e.value, to: e.max ?? e.value, colorIndex: 0),
    ],
  ),
);

/// One stacked bar per entry, a segment per component in the order the
/// entries carry them (see `groupStackedEntries`).
SparkBarsData sparkStackedBars(
  List<MeasurementStackedEntry> days, {
  required DateTime start,
  required int slotCount,
  int slotDays = 1,
}) {
  List<SparkSegment> segmentsOf(MeasurementStackedEntry entry) {
    var offset = 0.0;
    final segments = <SparkSegment>[];
    for (final (index, value) in entry.values.indexed) {
      if (value == null || value <= 0) {
        continue;
      }
      segments.add((from: offset, to: offset + value, colorIndex: index));
      offset += value.toDouble();
    }
    return segments;
  }

  return SparkBarsData(
    slotCount: slotCount,
    bars: _slotted(days, start, slotDays, slotCount, (e) => e.date, segmentsOf),
  );
}

/// One signed bar per week (see `weeklyDeltas`), hanging off the zero line.
SparkBarsData sparkDeltaBars(
  List<MeasurementChartEntry> deltas, {
  required DateTime start,
  required int slotCount,
}) => SparkBarsData(
  slotCount: slotCount,
  signed: true,
  bars: _slotted(
    deltas,
    start,
    7,
    slotCount,
    (e) => e.date,
    (e) => [
      (from: 0, to: e.value, colorIndex: 0),
    ],
  ),
);

/// The entries laid into their slots, [slotDays] calendar days per slot;
/// whatever falls outside the window is dropped.
List<SparkBar> _slotted<T>(
  List<T> entries,
  DateTime start,
  int slotDays,
  int slotCount,
  DateTime Function(T) dateOf,
  List<SparkSegment> Function(T) segments,
) => [
  // Truncating division would fold the days just before the window into slot
  // 0, so the days are bounds-checked before they become a slot
  for (final entry in entries)
    if (daysBetween(start, dateOf(entry)) case final days
        when days >= 0 && days ~/ slotDays < slotCount)
      (slot: days ~/ slotDays, segments: segments(entry)),
];
