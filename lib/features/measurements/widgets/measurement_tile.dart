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

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/measurements/charts/calendar.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/charts/spark.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Height of a tile in the overview grid, shared with the grid delegate.
///
/// Holds the rows a tile stacks (name, value, spark, axis, chip) with room to
/// spare: they are laid out at their natural heights, so a tile sized to
/// exactly fit them overflows as soon as the text does not render at the size
/// it was measured at.
const measurementTileExtent = 172.0;

/// Height of the spark chart inside a tile.
const _sparkHeight = 40.0;

/// Height of a heatmap spark: it has no axis row, its grid takes that room
/// instead, which is what makes the cells legible.
const _heatmapHeight = 58.0;

/// One category of the overview grid: latest value as the hero, a spark chart
/// as context over the range the filter selects. A tap opens the category's
/// entries screen; everything beyond a glance lives there.
class MeasurementTile extends ConsumerWidget {
  const MeasurementTile(this.category, {this.range = defaultChartRange, super.key});

  final MeasurementCategory category;
  final ChartRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestMeasurementEntriesProvider).value ?? const {};

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          MeasurementEntriesScreen.routeName,
          arguments: category.id,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // How old the reading is rides on the name's line: it qualifies
              // the value below, but a row of its own costs the tile more
              // height than it can spare, and next to the value it would push
              // a wide reading (a blood pressure) into an ellipsis
              Row(
                children: [
                  // Expanded, not Flexible: the name keeps the width the date
                  // leaves, which pushes the date to the far edge instead of
                  // crowding it against the name
                  Expanded(
                    child: Text(
                      category.displayName(context),
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _MeasuredAt(_newestOf(latest)),
                ],
              ),
              _heroValue(context, latest),
              const Spacer(),
              if (category.hasChildren) _groupSpark(latest) else _leafSpark(latest),
            ],
          ),
        ),
      ),
    );
  }

  /// The latest reading, large: the one thing the tile exists to show. A
  /// group is quoted through the shared rule, see [quoteGroupReading], so the
  /// tile and the entries screen behind it read the same.
  Widget _heroValue(BuildContext context, Map<String, MeasurementEntry> latest) {
    String format(num value) => measurementValue(
      context,
      value,
      category.unit,
      decimals: category.metricType.displayDecimals,
    );

    final String value;
    if (category.hasChildren) {
      final values = {
        for (final child in category.children)
          if (latest[child.id] case final MeasurementEntry entry)
            child.id!: entry.valueIn(child.unit, categoryUnit: child.unit),
      };
      value = values.isEmpty ? '—' : quoteGroupReading(category, values, format);
    } else {
      final latestValue = latest[category.id]?.valueIn(category.unit, categoryUnit: category.unit);
      value = latestValue == null ? '—' : format(latestValue);
    }

    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        text: value,
        style: theme.textTheme.headlineSmall,
        children: [
          if (category.unit.isNotEmpty)
            TextSpan(
              text: ' ${measurementUnit(category.unit)}',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  static const _emptySpark = [_SparkArea(child: SizedBox())];

  /// The spark of a leaf category, honoring its chart type wherever the format
  /// survives miniaturisation, see [sparkKindFor]. Keeps what it last drew
  /// while another range loads, like the full-size charts.
  Widget _leafSpark(Map<String, MeasurementEntry> latest) {
    final kind = sparkKindFor(category.metricType, category.chartType);
    final window = sparkWindowFor(kind, cutoff: range.countCutoff);
    final level = kind == SparkKind.delta
        ? MeasurementBucketLevel.week
        : MeasurementBucketLevel.day;

    return MeasurementChartArea<List<MeasurementChartEntry>>(
      identity: category.id!,
      loading: const _SparkArea(child: SizedBox()),
      watch: (ref) => ref
          .watch(measurementChartBucketsProvider(category.id!, window.start, null, level))
          .whenData(
            (buckets) => chartEntriesForBuckets(
              buckets,
              targetUnit: category.unit,
              categoryUnit: category.unit,
              summed: category.metricType.isSummedPerDay,
            ),
          ),
      builder: (context, points) => _leafRows(context, kind, window, points, latest),
      onError: (_, _) => _emptySpark,
    );
  }

  List<Widget> _leafRows(
    BuildContext context,
    SparkKind kind,
    SparkWindow window,
    List<MeasurementChartEntry> points,
    Map<String, MeasurementEntry> latest,
  ) {
    switch (kind) {
      case SparkKind.heatmap:
        return [
          SizedBox(
            height: _heatmapHeight,
            width: double.infinity,
            child: SparkHeatmap(points, weeks: window.slotCount!),
          ),
          // The same footer its kind would get elsewhere: a level for the
          // summed types, a direction for the sample ones
          if (category.metricType.isSummedPerDay)
            _AverageChip(
              points: points,
              unit: category.unit,
              decimals: category.metricType.displayDecimals,
            )
          else
            _TrendChip(
              points: points,
              unit: category.unit,
              decimals: category.metricType.displayDecimals,
            ),
        ];

      case SparkKind.delta:
        return [
          _SparkArea(
            child: SparkBarChart(
              sparkDeltaBars(
                weeklyDeltas(points, summed: category.metricType.isSummedPerDay),
                start: window.start!,
                slotCount: window.slotCount!,
              ),
            ),
          ),
          _MonthAxis(window.start!),
        ];

      case SparkKind.bars:
        final data = window.weekly
            ? sparkBars(
                sparkWeeklyPoints(points),
                start: window.start!,
                slotCount: window.slotCount!,
                slotDays: 7,
              )
            : sparkBars(points, start: window.start!, slotCount: window.slotCount!);
        return [
          _SparkArea(child: SparkBarChart(data)),
          _axis(window.start!, window.days!, weekly: window.weekly),
          _AverageChip(
            points: points,
            unit: category.unit,
            decimals: category.metricType.displayDecimals,
          ),
        ];

      case SparkKind.line:
        // A full-history window has no fixed start; the data provides it
        final start = window.start ?? dayOf(points.map((e) => e.date).minOrNull ?? DateTime.now());
        final days = window.days ?? daysBetween(start, DateTime.now()) + 1;
        final sparse = sparkIsSparse(points);
        return [
          _SparkArea(
            child: SparkLineChart(points, start: start, days: days, dots: sparse),
          ),
          _axis(start, days, weekly: false),
          _TrendChip(
            points: points,
            unit: category.unit,
            decimals: category.metricType.displayDecimals,
          ),
        ];
    }
  }

  /// The spark of a group, which keeps its structural form: sleep stacks,
  /// blood pressure floats, anything else falls back to a line of its first
  /// component with data.
  Widget _groupSpark(Map<String, MeasurementEntry> latest) {
    final window = sparkWindowFor(SparkKind.bars, cutoff: range.countCutoff);

    return MeasurementChartArea<Map<String, List<MeasurementChartEntry>>>(
      identity: category.id!,
      loading: const _SparkArea(child: SizedBox()),
      watch: (ref) => ref
          .watch(
            measurementGroupBucketsProvider(category.id!, window.start, MeasurementBucketLevel.day),
          )
          .whenData((buckets) => groupComponentPoints(category, buckets)),
      builder: (context, points) => _groupRows(context, window, points, latest),
      onError: (_, _) => _emptySpark,
    );
  }

  List<Widget> _groupRows(
    BuildContext context,
    SparkWindow window,
    Map<String, List<MeasurementChartEntry>> points,
    Map<String, MeasurementEntry> latest,
  ) {
    final start = window.start!;
    final slotCount = window.slotCount!;

    if (category.metricType.isSummedPerDay) {
      final components = stackableComponents(category);
      final stacked = groupStackedEntries(components, points);
      final data = window.weekly
          ? sparkStackedBars(
              sparkWeeklyStacks(stacked),
              start: start,
              slotCount: slotCount,
              slotDays: 7,
            )
          : sparkStackedBars(stacked, start: start, slotCount: slotCount);
      return [
        _SparkArea(child: SparkBarChart(data)),
        _axis(start, window.days!, weekly: window.weekly),
        _AverageChip(
          points: [for (final day in stacked) MeasurementChartEntry(day.total, day.date)],
          unit: category.unit,
          decimals: category.metricType.displayDecimals,
        ),
      ];
    }

    final ranges = category.children.length == 2
        ? groupRangeEntries(points)
        : const <MeasurementChartEntry>[];
    if (ranges.isNotEmpty) {
      final data = window.weekly
          ? sparkFloatingBars(
              sparkWeeklyPoints(ranges),
              start: start,
              slotCount: slotCount,
              slotDays: 7,
            )
          : sparkFloatingBars(ranges, start: start, slotCount: slotCount);
      return [
        _SparkArea(child: SparkBarChart(data)),
        _axis(start, window.days!, weekly: window.weekly),
        // A range spans a reading rather than tracking a level, so the spread
        // is what a chip could quote; the hero already says how recent it is
        const SizedBox.shrink(),
      ];
    }

    final fallback = category.children
        .map((c) => points[c.id])
        .firstWhereOrNull(
          (p) => p != null && p.isNotEmpty,
        );
    return [
      _SparkArea(
        child: SparkLineChart(fallback ?? const [], start: start, days: window.days!),
      ),
      _axis(start, window.days!, weekly: window.weekly),
      const SizedBox.shrink(),
    ];
  }

  /// The entry the hero value comes from: the category's own for a leaf, the
  /// newest of the components for a group.
  MeasurementEntry? _newestOf(Map<String, MeasurementEntry> latest) {
    final candidates = category.hasChildren
        ? category.children.map((child) => latest[child.id])
        : [latest[category.id]];

    return candidates.nonNulls.fold(
      null,
      (newest, entry) => newest == null || entry.date.isAfter(newest.date) ? entry : newest,
    );
  }
}

/// The axis row under a spark: one weekday letter per day where the window is
/// exactly one week of daily slots, the months it spans otherwise.
Widget _axis(DateTime start, int days, {required bool weekly}) =>
    !weekly && days == DateTime.daysPerWeek ? _WeekdayAxis(start) : _MonthAxis(start);

/// One narrow letter per day of a one-week window, today highlighted.
class _WeekdayAxis extends StatelessWidget {
  const _WeekdayAxis(this.start);

  final DateTime start;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final format = DateFormat('EEEEE', Localizations.localeOf(context).toString());
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Row(
      children: [
        for (var day = 0; day < DateTime.daysPerWeek; day++)
          Expanded(
            child: Text(
              format.format(DateTime(start.year, start.month, start.day + day)),
              textAlign: TextAlign.center,
              style: DateTime(start.year, start.month, start.day + day) == today
                  ? theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )
                  : theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
      ],
    );
  }
}

/// The fixed-height box every spark variant draws into, so the rows above and
/// below it line up across the grid.
class _SparkArea extends StatelessWidget {
  const _SparkArea({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: _sparkHeight, width: double.infinity, child: child);
  }
}

/// What stretch of the calendar the spark covers: its months or, over more
/// than a year, its years. Kept to a few labels, the tile is narrow.
class _MonthAxis extends StatelessWidget {
  const _MonthAxis(this.start);

  final DateTime start;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final today = DateTime.now();

    final monthFormat = DateFormat.MMM(locale);
    final months = <String>[];
    var cursor = DateTime(start.year, start.month);
    while (!cursor.isAfter(today)) {
      months.add(monthFormat.format(cursor));
      cursor = DateTime(cursor.year, cursor.month + 1);
    }

    final yearFormat = DateFormat.y(locale);
    final labels = switch (months.length) {
      > 12 => [
        for (var year = start.year; year <= today.year; year++) yearFormat.format(DateTime(year)),
      ],
      > 4 => [months.first, months[months.length ~/ 2], months.last],
      _ => months,
    };

    return Text(
      labels.join(' · '),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

/// A neutral fact in chip form, see [_TrendChip] and [_AverageChip]. States
/// what the numbers do, never whether that is good: which direction is the
/// good one depends on the goal, and the tile should not assert one.
class _FooterChip extends StatelessWidget {
  const _FooterChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: theme.textTheme.labelSmall, maxLines: 1),
    );
  }
}

/// Which way the window's values go, as a weekly rate ("↘ 0.3 kg/week"), or
/// "stable" when the change is within noise of the value itself, or below
/// what [decimals] can even show: a chip claiming "0.0 kg/week" says stable,
/// only worse.
class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.points, required this.unit, required this.decimals});

  final List<MeasurementChartEntry> points;
  final String unit;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const SizedBox.shrink();
    }

    final i18n = AppLocalizations.of(context);
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
    final first = sorted.first;
    final last = sorted.last;
    final days = daysBetween(first.date, last.date);
    if (days == 0) {
      return const SizedBox.shrink();
    }

    final perWeek = (last.value - first.value) / days * 7;
    final scale = last.value.abs();
    final roundsToZero = perWeek.abs() < 0.5 / pow(10, decimals);
    if (scale == 0 || roundsToZero || perWeek.abs() / scale < 0.01) {
      return _FooterChip('→ ${i18n.sparkTrendStable}');
    }

    final arrow = perWeek < 0 ? '↘' : '↗';
    return _FooterChip(
      '$arrow '
      '${i18n.sparkTrendPerWeek(measurementWithUnit(context, perWeek.abs(), unit, decimals: decimals))}',
    );
  }
}

/// The average over the window's measured days, for the summed types, whose
/// per-day totals have a typical level rather than a trend.
class _AverageChip extends StatelessWidget {
  const _AverageChip({required this.points, required this.unit, required this.decimals});

  final List<MeasurementChartEntry> points;
  final String unit;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final mean = points.map((e) => e.value).average;
    return _FooterChip(
      AppLocalizations.of(
        context,
      ).sparkAverage(measurementWithUnit(context, mean, unit, decimals: decimals)),
    );
  }
}

/// How long ago the value below was measured: for a category the health sync
/// feeds every now and then, this is what says an old-looking chart is not a
/// broken one.
///
/// Sizes to its text, so the row it sits in decides what happens when the
/// two do not fit; it cannot ellipsify itself.
class _MeasuredAt extends StatelessWidget {
  const _MeasuredAt(this.entry);

  final MeasurementEntry? entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entry == null) {
      return const SizedBox.shrink();
    }

    return Text(
      relativeDate(context, entry!.date),
      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
