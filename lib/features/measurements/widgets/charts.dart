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
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/core/charts.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class MeasurementOverallChangeWidget extends StatelessWidget {
  final MeasurementChartEntry _first;
  final MeasurementChartEntry _last;
  final String _unit;

  const MeasurementOverallChangeWidget(this._first, this._last, this._unit);

  @override
  Widget build(BuildContext context) {
    final delta = _last.value - _first.value;
    String prefix = '';
    if (delta > 0) {
      prefix = '+';
    } else if (delta < 0) {
      prefix = '-';
    }

    return Text(
      '${AppLocalizations.of(context).overallChangeWeight} '
      '$prefix${measurementWithUnit(context, delta.abs(), _unit)}',
    );
  }
}

String weightUnit(bool isMetric, BuildContext context) {
  return isMetric ? AppLocalizations.of(context).kg : AppLocalizations.of(context).lb;
}

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

/// Y-axis tick label that never wraps: a long value+unit combination shrinks
/// to fit the reserved width instead of breaking into overlapping lines.
class _YAxisLabel extends StatelessWidget {
  const _YAxisLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1),
    );
  }
}

class MeasurementChartWidgetFl extends StatefulWidget {
  final List<MeasurementChartSeries> _series;
  final String _unit;
  final List<PlanPeriod> _planPeriods;

  const MeasurementChartWidgetFl(
    this._series,
    this._unit, {
    List<PlanPeriod> planPeriods = const [],
    super.key,
  }) : _planPeriods = planPeriods;

  /// The usual single-measurement chart: the values plus their average and
  /// trend line.
  MeasurementChartWidgetFl.singleMeasurement(
    List<MeasurementChartEntry> entries,
    String unit, {
    List<MeasurementChartEntry>? avgs,
    List<MeasurementChartEntry>? trend,
    List<PlanPeriod> planPeriods = const [],
    super.key,
  }) : _unit = unit,
       _planPeriods = planPeriods,
       _series = [
         MeasurementChartSeries(entries, MeasurementSeriesRole.raw),
         if (avgs != null) MeasurementChartSeries(avgs, MeasurementSeriesRole.average),
         if (trend != null && trend.isNotEmpty)
           MeasurementChartSeries(trend, MeasurementSeriesRole.trend),
       ];

  /// All points of all series, for the shared axis calculations.
  List<MeasurementChartEntry> get _allEntries => _series.expand((s) => s.entries).toList();

  @override
  State<MeasurementChartWidgetFl> createState() => _MeasurementChartWidgetFlState();
}

/// Colour of the [index]-th [MeasurementSeriesRole.component] line. Shared
/// with the legend so a component's colour matches its line.
Color componentColor(BuildContext context, int index) {
  final scheme = Theme.of(context).colorScheme;
  final colors = [scheme.primary, scheme.tertiary, scheme.secondary, scheme.error];
  return colors[index % colors.length];
}

/// A series resolved into what fl_chart needs: the line itself plus, for range
/// series, the two invisible bounds the band is painted between.
class _ResolvedSeries {
  _ResolvedSeries(this.line, this.label, {this.bounds});

  final LineChartBarData line;
  final String? label;
  final (LineChartBarData, LineChartBarData)? bounds;
}

class _MeasurementChartWidgetFlState extends State<MeasurementChartWidgetFl> {
  /// Radius of a dot on a chart with room to spare
  static const MAX_DOT_RADIUS = 4.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        // Dot size is in pixels, so it has to follow from how many points
        // share the available space, otherwise they merge into a blob
        child: LayoutBuilder(
          builder: (context, constraints) => LineChart(mainData(constraints.maxWidth)),
        ),
      ),
    );
  }

  /// Dots shrink as points get denser, so they stay distinguishable instead of
  /// overdrawing each other.
  FlDotData _dotData(double availableWidth) {
    final count = widget._series.map((s) => s.entries.length).fold(0, max);
    if (count == 0) {
      return const FlDotData(show: true);
    }

    final radius = (availableWidth / count / 2).clamp(0.5, MAX_DOT_RADIUS);
    return FlDotData(
      show: true,
      getDotPainter: (spot, percent, barData, index) =>
          FlDotCirclePainter(radius: radius, color: barData.color ?? Colors.transparent),
    );
  }

  List<FlSpot> _spots(
    List<MeasurementChartEntry> entries, [
    num Function(MeasurementChartEntry)? y,
  ]) => entries
      .map(
        (e) => FlSpot(
          e.date.millisecondsSinceEpoch.toDouble(),
          (y == null ? e.value : y(e)).toDouble(),
        ),
      )
      .toList();

  /// Turns the series into fl_chart lines, styled by their role.
  List<_ResolvedSeries> _resolveSeries(double availableWidth) {
    final scheme = Theme.of(context).colorScheme;
    final dots = _dotData(availableWidth);
    var componentIndex = 0;

    return widget._series.map((series) {
      final spots = _spots(series.entries);
      final LineChartBarData line;

      switch (series.role) {
        case MeasurementSeriesRole.raw:
          line = LineChartBarData(
            spots: spots,
            isCurved: false,
            color: scheme.primary,
            barWidth: 0,
            isStrokeCapRound: true,
            dotData: dots,
          );
        case MeasurementSeriesRole.average:
          line = LineChartBarData(
            spots: spots,
            isCurved: false,
            color: scheme.tertiary,
            barWidth: 1,
            dotData: const FlDotData(show: false),
          );
        case MeasurementSeriesRole.trend:
          line = LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.4,
            color: scheme.secondary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          );
        case MeasurementSeriesRole.component:
          line = LineChartBarData(
            spots: spots,
            isCurved: false,
            color: componentColor(context, componentIndex++),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: dots,
          );
      }

      // Points that summarise a range get a band between their bounds. The
      // bounds themselves are invisible; only the fill between them shows.
      //
      // Only for the measured series: a band says "this is the spread of the
      // measurements", which a derived line has none of. Condensing attaches a
      // range to every point, so an average that got downsampled along with
      // its values would otherwise be given a second band of its own.
      final carriesSpread =
          series.role == MeasurementSeriesRole.raw ||
          series.role == MeasurementSeriesRole.component;
      final ranged = carriesSpread
          ? series.entries.where((e) => e.hasRange).toList()
          : const <MeasurementChartEntry>[];
      return _ResolvedSeries(
        line,
        series.label,
        bounds: ranged.length == series.entries.length && ranged.isNotEmpty
            ? (
                LineChartBarData(
                  spots: _spots(ranged, (e) => e.min!),
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: _spots(ranged, (e) => e.max!),
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: const FlDotData(show: false),
                ),
              )
            : null,
      );
    }).toList();
  }

  /// Names of the plans whose period contains [date].
  List<String> _planNamesAt(DateTime date) => [
    for (final p in widget._planPeriods)
      if (!date.isBefore(p.range.start) && !date.isAfter(p.range.end)) p.name,
  ];

  /// The plan periods as translucent full-height bands, clamped to the span
  /// of the data so they never draw outside the axes.
  RangeAnnotations _planBands(List<DateTime> dates) {
    if (dates.isEmpty || widget._planPeriods.isEmpty) {
      return const RangeAnnotations();
    }

    final bounds = DateTimeRange(start: dates.first, end: dates.last);
    return RangeAnnotations(
      verticalRangeAnnotations: [
        for (final range in clampPeriods([for (final p in widget._planPeriods) p.range], bounds))
          VerticalRangeAnnotation(
            x1: range.start.millisecondsSinceEpoch.toDouble(),
            x2: range.end.millisecondsSinceEpoch.toDouble(),
            color: planBandColor(context),
          ),
      ],
    );
  }

  /// [hidden] holds the indices of the invisible band bounds, which must not
  /// show up as tooltip lines; [labels] names the series that have a name.
  LineTouchData tooltipData(Set<int> hidden, Map<int, String?> labels) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.primaryContainer,
        getTooltipItems: (touchedSpots) {
          // The plan context belongs to the touched date, not to a series, so
          // it goes below the last tooltip line instead of onto every line
          final lastVisible = touchedSpots.lastWhereOrNull(
            (s) => !hidden.contains(s.barIndex),
          );

          return touchedSpots.map((touchedSpot) {
            if (hidden.contains(touchedSpot.barIndex)) {
              return null;
            }
            final msSinceEpoch = touchedSpot.x.toInt();
            final DateTime date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
            final dateStr = DateFormat.Md(
              Localizations.localeOf(context).languageCode,
            ).format(date);

            // Check if this is an interpolated point (milliseconds ending with 123)
            final bool isInterpolated = msSinceEpoch % 1000 == INTERPOLATION_MARKER;
            final String interpolatedMarker = isInterpolated ? ' (interpolated)' : '';
            final label = labels[touchedSpot.barIndex];
            final prefix = label == null ? '' : '$label ';

            final planNames = identical(touchedSpot, lastVisible)
                ? _planNamesAt(date)
                : const <String>[];
            return LineTooltipItem(
              '$prefix$dateStr: '
              '${measurementWithUnit(context, touchedSpot.y, widget._unit)}$interpolatedMarker',
              TextStyle(color: touchedSpot.bar.color),
              children: [
                for (final name in planNames)
                  TextSpan(
                    text: '\n$name',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
              ],
            );
          }).toList();
        },
      ),
    );
  }

  LineChartData mainData(double availableWidth) {
    final allEntries = widget._allEntries;
    final dates = allEntries.map((e) => e.date).toList()..sort();

    // The bounds of a band reach past the line they wrap, so the axis follows
    // every value that is drawn, not just the plotted ones
    final drawn = <num>[
      for (final entry in allEntries) ...[
        entry.value,
        if (entry.min != null) entry.min!,
        if (entry.max != null) entry.max!,
      ],
    ];
    final yAxis = drawn.isEmpty
        ? null
        : durationAxis(widget._unit, drawn.reduce(min), drawn.reduce(max));

    // Flatten the series into fl_chart's flat bar list, remembering which
    // indices are band bounds (invisible) and which carry a name.
    final bars = <LineChartBarData>[];
    final bands = <BetweenBarsData>[];
    final hidden = <int>{};
    final labels = <int, String?>{};
    for (final resolved in _resolveSeries(availableWidth)) {
      if (resolved.bounds != null) {
        final lower = bars.length;
        bars.add(resolved.bounds!.$1);
        final upper = bars.length;
        bars.add(resolved.bounds!.$2);
        hidden
          ..add(lower)
          ..add(upper);
        bands.add(
          BetweenBarsData(
            fromIndex: lower,
            toIndex: upper,
            color: resolved.line.color?.withValues(alpha: 0.15),
          ),
        );
      }
      labels[bars.length] = resolved.label;
      bars.add(resolved.line);
    }

    return LineChartData(
      minY: yAxis?.min,
      maxY: yAxis?.max,
      lineTouchData: tooltipData(hidden, labels),
      betweenBarsData: bands,
      rangeAnnotations: _planBands(dates),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        // horizontalInterval: 1,
        // verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.outlineVariant, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.outlineVariant, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              // Don't show the first and last entries, to avoid overlap
              // see https://stackoverflow.com/questions/73355777/flutter-fl-chart-how-can-we-avoid-the-overlap-of-the-ordinate
              // this is needlessly aggressive if the titles are "sparse", but we should optimize for more busy data
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }
              final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              // if we go across years, show years in the ticks. otherwise leave them out
              if (DateTime.fromMillisecondsSinceEpoch(meta.min.toInt()).year !=
                  DateTime.fromMillisecondsSinceEpoch(meta.max.toInt()).year) {
                return Text(
                  localizedDate(context).format(date),
                );
              }
              return Text(
                DateFormat.Md(Localizations.localeOf(context).languageCode).format(date),
              );
            },
            interval: dates.isNotEmpty
                ? chartGetInterval(dates.first, dates.last)
                : CHART_MILLISECOND_FACTOR,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 65,
            interval: yAxis?.interval,
            getTitlesWidget: (value, meta) {
              // Don't show the first and last entries, to avoid overlap
              // see https://stackoverflow.com/questions/73355777/flutter-fl-chart-how-can-we-avoid-the-overlap-of-the-ordinate
              // this is needlessly aggressive if the titles are "sparse", but we should optimize for more busy data
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }

              return _YAxisLabel(measurementWithUnit(context, value, widget._unit));
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      lineBarsData: bars,
    );
  }
}

class MeasurementChartEntry {
  num value;
  DateTime date;

  /// Lower and upper bound of the values [value] summarises. Set for metrics
  /// stored as a daily aggregate (heart rate min/max); the chart then draws a
  /// band around the line. Both are null for a plain sample.
  num? min;
  num? max;

  MeasurementChartEntry(this.value, this.date, {this.min, this.max});

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

/// For each point, the average of all the points in the [days] preceding it.
List<MeasurementChartEntry> movingAverage(List<MeasurementChartEntry> vals, {int days = 7}) {
  var start = 0;
  var end = 0;
  final List<MeasurementChartEntry> out = <MeasurementChartEntry>[];

  // first make sure our list is in ascending order
  vals.sort((a, b) => a.date.compareTo(b.date));

  // The window total is carried along instead of re-summing the window for
  // every point: with densely sampled metrics the window holds thousands of
  // values, and re-adding them each time makes this quadratic
  num sum = 0;

  while (end < vals.length) {
    sum += vals[end].value;

    // since users can log measurements several days, or minutes apart,
    // we can't make assumptions.  We have to manually advance 'start'
    // such that it is always the first point within our desired range.
    // posibly start == end (when there is only one point in the range)
    final intervalStart = vals[end].date.subtract(Duration(days: days));
    while (start < end && vals[start].date.isBefore(intervalStart)) {
      sum -= vals[start].value;
      start++;
    }

    out.add(MeasurementChartEntry(sum / (end - start + 1), vals[end].date));

    end++;
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

/// Colour of a change bar, by which way it points. Theme colours rather than
/// green and red: which direction is the good one depends on the goal (losing
/// weight, building muscle), and the chart should not assert one.
Color deltaColor(BuildContext context, num delta) =>
    delta < 0 ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary;

/// Bar chart for entries that are discrete events rather than a continuous
/// series: daily totals, and the readings of a multi-value group.
///
/// Entries carrying a range (see [MeasurementChartEntry.hasRange]) are drawn
/// as a bar spanning it, so a blood pressure reading appears as one bar from
/// diastolic to systolic. That keeps the pair together as the single event it
/// is, and claims nothing about the time between two readings.
class MeasurementBarChartWidgetFl extends StatefulWidget {
  final List<MeasurementChartEntry> _entries;
  final String _unit;

  /// Whether the values are changes rather than amounts: their bars hang off a
  /// marked zero line and are coloured by their direction.
  final bool _signed;

  const MeasurementBarChartWidgetFl(this._entries, this._unit, {bool signed = false})
    : _signed = signed;

  @override
  State<MeasurementBarChartWidgetFl> createState() => _MeasurementBarChartWidgetFlState();
}

class _MeasurementBarChartWidgetFlState extends State<MeasurementBarChartWidgetFl> {
  /// Number of dates to label on the x axis
  static const X_LABEL_COUNT = 4;

  /// Widest a single bar gets, for charts with only a handful of entries
  static const MAX_BAR_WIDTH = 12.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        // Bar width is in pixels, so it has to follow from how many bars share
        // the available space, otherwise a couple of months of readings
        // overlap into a solid block
        child: LayoutBuilder(
          builder: (context, constraints) => BarChart(mainData(constraints.maxWidth)),
        ),
      ),
    );
  }

  BarTouchData tooltipData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => Theme.of(context).colorScheme.primaryContainer,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          if (groupIndex < 0 || groupIndex >= widget._entries.length) {
            return null;
          }
          final entry = widget._entries[groupIndex];
          final dateStr = DateFormat.Md(
            Localizations.localeOf(context).languageCode,
          ).format(entry.date);
          // A range is quoted as high over low, the way a blood pressure
          // reading is written. A change carries its sign, and the plus has to
          // be added: only the minus comes out of the number format
          final value = entry.hasRange
              ? '${measurementValue(context, entry.max!, widget._unit)}'
                    '/${measurementValue(context, entry.min!, widget._unit)}'
              : '${widget._signed && rod.toY > 0 ? '+' : ''}'
                    '${measurementValue(context, rod.toY, widget._unit)}';

          return BarTooltipItem(
            '$dateStr: $value ${measurementUnit(widget._unit)}',
            TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          );
        },
      ),
    );
  }

  BarChartData mainData(double availableWidth) {
    // Leave a gap between neighbouring bars, but never go below a hairline
    final barWidth = widget._entries.isEmpty
        ? MAX_BAR_WIDTH
        : (availableWidth / widget._entries.length * 0.7).clamp(1.0, MAX_BAR_WIDTH);

    // A range bar spans from its lower to its upper bound, so both decide the
    // axis; a plain bar grows from zero
    final drawn = <num>[
      0,
      for (final entry in widget._entries) ...[
        entry.value,
        if (entry.min != null) entry.min!,
        if (entry.max != null) entry.max!,
      ],
    ];
    final yAxis = durationAxis(widget._unit, drawn.reduce(min), drawn.reduce(max));

    // A bar chart draws one bottom title per group (the x value is a group key,
    // not a position), so thinning out the labels has to happen here.
    final labelStep = max(1, (widget._entries.length / X_LABEL_COUNT).ceil());
    // keep the labels away from the chart edges
    final labelOffset = labelStep ~/ 2;
    final spansYears =
        widget._entries.isNotEmpty &&
        widget._entries.first.date.year != widget._entries.last.date.year;

    return BarChartData(
      minY: yAxis?.min,
      maxY: yAxis?.max,
      barTouchData: tooltipData(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.primaryContainer, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= widget._entries.length) {
                return const Text('');
              }
              if ((index - labelOffset) % labelStep != 0) {
                return const Text('');
              }
              final DateTime date = widget._entries[index].date;
              // if we go across years, show years in the ticks. otherwise leave them out
              if (spansYears) {
                return Text(localizedDate(context).format(date));
              }
              return Text(DateFormat.Md(Localizations.localeOf(context).languageCode).format(date));
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 65,
            interval: yAxis?.interval,
            getTitlesWidget: (value, meta) {
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }
              return _YAxisLabel(measurementWithUnit(context, value, widget._unit));
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      // The line the change bars hang off. Without it a chart of only
      // decreases reads as a normal bar chart pointing the wrong way
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          if (widget._signed)
            HorizontalLine(y: 0, color: Theme.of(context).colorScheme.outline, strokeWidth: 1),
        ],
      ),
      barGroups: widget._entries
          .asMap()
          .entries
          .map(
            (e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  // A range spans its bounds, a plain value grows from zero
                  fromY: e.value.hasRange ? e.value.min!.toDouble() : 0,
                  toY: e.value.hasRange ? e.value.max!.toDouble() : e.value.value.toDouble(),
                  color: widget._signed
                      ? deltaColor(context, e.value.value)
                      : Theme.of(context).colorScheme.primary,
                  width: barWidth,
                  borderRadius: e.value.hasRange
                      ? BorderRadius.circular(2)
                      // The rounded end is the one away from the baseline, so
                      // a bar pointing down is capped at the bottom
                      : BorderRadius.vertical(
                          top: e.value.value < 0 ? Radius.zero : const Radius.circular(2),
                          bottom: e.value.value < 0 ? const Radius.circular(2) : Radius.zero,
                        ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
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

/// Stacked bar chart for a group whose components are parts of one whole, e.g.
/// the sleep stages of a night.
///
/// One bar per day, split into a segment per component in the components' own
/// order, so the bar's height is the night and its segments are how it was
/// spent. Colours come from [componentColor] by position, which is what ties a
/// segment to its legend entry.
class MeasurementStackedBarChartWidgetFl extends StatefulWidget {
  final List<MeasurementStackedEntry> _entries;
  final List<String> _labels;
  final String _unit;

  const MeasurementStackedBarChartWidgetFl(this._entries, this._labels, this._unit);

  @override
  State<MeasurementStackedBarChartWidgetFl> createState() =>
      _MeasurementStackedBarChartWidgetFlState();
}

class _MeasurementStackedBarChartWidgetFlState extends State<MeasurementStackedBarChartWidgetFl> {
  /// Number of dates to label on the x axis
  static const X_LABEL_COUNT = 4;

  /// Widest a single bar gets, for charts with only a handful of entries
  static const MAX_BAR_WIDTH = 12.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) => BarChart(mainData(constraints.maxWidth)),
        ),
      ),
    );
  }

  /// The whole bar with its parts, since a single segment says little without
  /// the night it belongs to.
  BarTouchData tooltipData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => Theme.of(context).colorScheme.primaryContainer,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          if (groupIndex < 0 || groupIndex >= widget._entries.length) {
            return null;
          }
          final entry = widget._entries[groupIndex];
          final dateStr = DateFormat.Md(
            Localizations.localeOf(context).languageCode,
          ).format(entry.date);
          final parts = [
            for (final (index, value) in entry.values.indexed)
              if (value != null)
                '${widget._labels[index]}: ${measurementValue(context, value, widget._unit)}',
          ];

          return BarTooltipItem(
            '$dateStr: ${measurementWithUnit(context, entry.total, widget._unit)}'
            '${parts.isEmpty ? '' : '\n${parts.join('\n')}'}',
            TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          );
        },
      ),
    );
  }

  BarChartData mainData(double availableWidth) {
    final barWidth = widget._entries.isEmpty
        ? MAX_BAR_WIDTH
        : (availableWidth / widget._entries.length * 0.7).clamp(1.0, MAX_BAR_WIDTH);

    // The bar is as tall as its segments together, so that is what the axis
    // has to cover
    final yAxis = durationAxis(
      widget._unit,
      0,
      widget._entries.map((e) => e.total).fold<num>(0, max),
    );
    final labelStep = max(1, (widget._entries.length / X_LABEL_COUNT).ceil());
    final labelOffset = labelStep ~/ 2;
    final spansYears =
        widget._entries.isNotEmpty &&
        widget._entries.first.date.year != widget._entries.last.date.year;

    return BarChartData(
      minY: yAxis?.min,
      maxY: yAxis?.max,
      barTouchData: tooltipData(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.primaryContainer, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= widget._entries.length) {
                return const Text('');
              }
              if ((index - labelOffset) % labelStep != 0) {
                return const Text('');
              }
              final DateTime date = widget._entries[index].date;
              if (spansYears) {
                return Text(localizedDate(context).format(date));
              }
              return Text(DateFormat.Md(Localizations.localeOf(context).languageCode).format(date));
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 65,
            interval: yAxis?.interval,
            getTitlesWidget: (value, meta) {
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }
              return _YAxisLabel(measurementWithUnit(context, value, widget._unit));
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      barGroups: widget._entries.asMap().entries.map((e) {
        // fl_chart stacks by absolute offsets rather than by segment heights,
        // so each part is placed on top of what came before it
        var offset = 0.0;
        final stack = <BarChartRodStackItem>[];
        for (final (index, value) in e.value.values.indexed) {
          if (value == null || value <= 0) {
            continue;
          }
          stack.add(
            BarChartRodStackItem(offset, offset + value.toDouble(), componentColor(context, index)),
          );
          offset += value.toDouble();
        }

        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: offset,
              width: barWidth,
              rodStackItems: stack,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            ),
          ],
        );
      }).toList(),
    );
  }
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
  // Calendar arithmetic, not Duration: a DST day is 23 or 25 hours long
  DateTime dayOf(DateTime date) => DateTime(date.year, date.month, date.day);
  DateTime shift(DateTime day, int days) => DateTime(day.year, day.month, day.day + days);
  DateTime mondayOf(DateTime date) => shift(date, -(date.weekday - 1));
  int daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  final values = {for (final day in days) dayOf(day.date): day.value};
  final now = dayOf(today ?? DateTime.now());

  if (values.isEmpty) {
    return MeasurementHeatmapGrid(
      start: shift(mondayOf(now), -7 * (maxWeeks - 1)),
      weeks: maxWeeks,
      values: const {},
      maxValue: 0,
    );
  }

  final first = values.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  final last = values.keys.reduce((a, b) => a.isAfter(b) ? a : b);
  final oldestVisible = shift(mondayOf(now), -7 * (maxWeeks - 1));
  final end = mondayOf(last).isBefore(oldestVisible) ? last : now;

  final endMonday = mondayOf(end);
  final weeks = min(maxWeeks, daysBetween(mondayOf(first), endMonday) ~/ 7 + 1);
  final start = shift(endMonday, -7 * (weeks - 1));
  final lastDay = shift(start, 7 * weeks - 1);

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

/// Calendar heatmap: one cell per day, coloured by that day's value.
///
/// Where a line or a bar answers how much, this answers how regularly, which
/// for steps or sleep is often the more interesting question. It is also the
/// only chart of the set where a gap is visible: a day without a measurement
/// is an empty cell instead of a line segment that silently spans it.
///
/// Takes one entry per calendar day; how a day's readings became that value
/// (summed, averaged) is decided by the caller, see [aggregatePerDay] and
/// [averagePerDay].
class MeasurementHeatmapWidgetFl extends StatefulWidget {
  /// One entry per calendar day, see [aggregatePerDay] and [averagePerDay].
  final List<MeasurementChartEntry> days;
  final String unit;

  const MeasurementHeatmapWidgetFl(this.days, this.unit);

  @override
  State<MeasurementHeatmapWidgetFl> createState() => _MeasurementHeatmapWidgetFlState();
}

class _MeasurementHeatmapWidgetFlState extends State<MeasurementHeatmapWidgetFl> {
  /// Day the user tapped, read out above the grid. A heatmap has no axis to
  /// read a value off, so this is what the tooltip is on the other charts.
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final grid = buildHeatmapGrid(widget.days);
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 20,
          child: Text(
            _readout(grid),
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = _HeatmapLayout(constraints.biggest, grid.weeks);

              return GestureDetector(
                onTapDown: (details) {
                  final day = layout.dayAt(details.localPosition, grid);
                  setState(() => _selected = day == _selected ? null : day);
                },
                child: CustomPaint(
                  size: constraints.biggest,
                  painter: _HeatmapPainter(
                    grid: grid,
                    layout: layout,
                    selected: _selected,
                    filled: theme.colorScheme.primary,
                    empty: theme.colorScheme.surfaceContainerHighest,
                    outline: theme.colorScheme.outline,
                    labelStyle:
                        theme.textTheme.bodySmall?.copyWith(fontSize: 9) ??
                        const TextStyle(fontSize: 9),
                    locale: Localizations.localeOf(context).toString(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// The line above the grid: the tapped day, or the span the grid covers
  /// while nothing is selected.
  String _readout(MeasurementHeatmapGrid grid) {
    final dateFormat = localizedDate(context);
    final selected = _selected;
    if (selected == null) {
      // The grid is whole weeks and its last one usually runs past today, so
      // the span it covers ends today rather than on that Sunday
      final today = DateTime.now();
      final last = grid.dayAt(grid.weeks - 1, DateTime.daysPerWeek - 1);
      final end = last.isAfter(today) ? today : last;
      return '${dateFormat.format(grid.start)} - ${dateFormat.format(end)}';
    }

    final value = grid.values[selected];
    if (value == null) {
      return '${dateFormat.format(selected)}: ${AppLocalizations.of(context).noDataAvailable}';
    }

    return '${dateFormat.format(selected)}: '
        '${measurementWithUnit(context, value, widget.unit)}';
  }
}

/// Where the cells of a heatmap sit, shared by the painter and the hit test so
/// a tap lands on the cell it looks like it lands on.
class _HeatmapLayout {
  /// Room for the weekday labels on the left and the month labels on top.
  static const weekdayLabelWidth = 22.0;
  static const monthLabelHeight = 12.0;

  /// Smallest a cell and its gap may get before the grid is unreadable rather
  /// than merely dense.
  static const minCell = 4.0;

  final double step;
  final double cell;
  final double left;
  final double top;

  factory _HeatmapLayout(Size size, int weeks) {
    final available = Size(
      size.width - weekdayLabelWidth,
      size.height - monthLabelHeight,
    );
    // Square cells, so the grid keeps the calendar's proportions whatever box
    // it is given. A year of columns is limited by the width, a quarter by the
    // height
    final step = max(
      minCell,
      min(available.width / max(weeks, 1), available.height / DateTime.daysPerWeek),
    );
    // The gap follows the cell size: a fixed one is a hairline on a wide grid
    // and half the cell on a year of columns, where it turns the squares into
    // scattered dots
    final gap = (step * 0.18).clamp(1.0, 3.0);

    return _HeatmapLayout._(
      step: step,
      cell: step - gap,
      left: weekdayLabelWidth,
      // A year of columns is wider than it is tall, so it would otherwise sit
      // against the top edge with the rest of the box empty below it
      top: monthLabelHeight + max(0.0, available.height - step * DateTime.daysPerWeek) / 2,
    );
  }

  const _HeatmapLayout._({
    required this.step,
    required this.cell,
    required this.left,
    required this.top,
  });

  Offset originOf(int week, int weekday) => Offset(left + week * step, top + weekday * step);

  /// The day at [position], null when the tap missed the grid.
  DateTime? dayAt(Offset position, MeasurementHeatmapGrid grid) {
    final week = ((position.dx - left) / step).floor();
    final weekday = ((position.dy - top) / step).floor();
    if (week < 0 || week >= grid.weeks || weekday < 0 || weekday >= DateTime.daysPerWeek) {
      return null;
    }
    return grid.dayAt(week, weekday);
  }
}

class _HeatmapPainter extends CustomPainter {
  final MeasurementHeatmapGrid grid;
  final _HeatmapLayout layout;
  final DateTime? selected;
  final Color filled;
  final Color empty;
  final Color outline;
  final TextStyle labelStyle;
  final String locale;

  _HeatmapPainter({
    required this.grid,
    required this.layout,
    required this.selected,
    required this.filled,
    required this.empty,
    required this.outline,
    required this.labelStyle,
    required this.locale,
  });

  /// Colour of a cell holding [value].
  ///
  /// A day without a measurement is neutral, everything else is tinted by how
  /// large its value is within the grid. The scale is continuous and starts
  /// well above transparent: a day that was measured has to read as measured
  /// even when its value is the smallest one.
  Color _cellColor(num? value) {
    if (value == null) {
      return empty;
    }
    final share = grid.maxValue <= 0 ? 1.0 : (value / grid.maxValue).clamp(0.0, 1.0);
    return Color.lerp(filled.withValues(alpha: 0.3), filled, share)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final today = DateTime.now();
    final endOfToday = DateTime(today.year, today.month, today.day);

    for (var week = 0; week < grid.weeks; week++) {
      for (var weekday = 0; weekday < DateTime.daysPerWeek; weekday++) {
        final day = grid.dayAt(week, weekday);
        // The grid is whole weeks, so the last one runs past today. Those days
        // have not happened yet and are left blank rather than drawn as a gap
        if (day.isAfter(endOfToday)) {
          continue;
        }

        final rect = RRect.fromRectAndRadius(
          layout.originOf(week, weekday) & Size(layout.cell, layout.cell),
          // Rounded, but never so much that a small cell becomes a dot
          Radius.circular(min(2, layout.cell / 4)),
        );
        canvas.drawRRect(rect, paint..color = _cellColor(grid.valueAt(week, weekday)));

        if (day == selected) {
          canvas.drawRRect(
            rect,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = outline,
          );
        }
      }
    }

    _paintWeekdayLabels(canvas);
    _paintMonthLabels(canvas);
  }

  /// Every other weekday, the way a calendar heatmap is usually labelled:
  /// naming all seven needs more room than the rows have.
  void _paintWeekdayLabels(Canvas canvas) {
    final format = DateFormat.E(locale);
    for (var weekday = 0; weekday < DateTime.daysPerWeek; weekday += 2) {
      final origin = layout.originOf(0, weekday);
      _paintText(
        canvas,
        format.format(grid.dayAt(0, weekday)),
        Offset(0, origin.dy + layout.cell / 2),
        maxWidth: _HeatmapLayout.weekdayLabelWidth - 2,
        centered: true,
      );
    }
  }

  /// The month above the column it starts in, which is what says where in the
  /// year the grid is without a date axis.
  void _paintMonthLabels(Canvas canvas) {
    final format = DateFormat.MMM(locale);
    var previous = -1;
    for (var week = 0; week < grid.weeks; week++) {
      final month = grid.dayAt(week, 0).month;
      if (month == previous) {
        continue;
      }
      previous = month;
      _paintText(
        canvas,
        format.format(grid.dayAt(week, 0)),
        // Sits right above the first column of the month
        Offset(
          layout.originOf(week, 0).dx,
          layout.top - _HeatmapLayout.monthLabelHeight,
        ),
        maxWidth: layout.step * 4,
      );
    }
  }

  /// Draws [text] at [at], which is its top left corner or, with [centered],
  /// the middle of its left edge.
  void _paintText(
    Canvas canvas,
    String text,
    Offset at, {
    required double maxWidth,
    bool centered = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
      ellipsis: '',
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, centered ? at.translate(0, -painter.height / 2) : at);
  }

  @override
  bool shouldRepaint(_HeatmapPainter oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.grid != grid;
}

/// Fewest values a distribution says anything about: below this a histogram
/// is noise with gaps, and the chart falls back to the derived default. Same
/// principle as a group whose readings are all unpaired falling back to
/// lines: never an empty or misleading card.
const distributionMinValues = 15;

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

/// Histogram of how often each value occurred: the values of the selected
/// range binned by size, with the median and the newest value marked.
///
/// The one chart of the set without a time axis. It answers what is normal
/// and what is an outlier, which no chart over time shows, and the marked
/// newest value places today within that. Painted by hand like the heatmap:
/// fl_chart's BarChart cannot draw the vertical marker lines.
class MeasurementDistributionWidgetFl extends StatefulWidget {
  /// The values with how often each occurred, and where the user stands today.
  final List<ValueCount> values;
  final num latest;
  final String unit;

  /// Width of one bin, null to derive it from the data.
  final num? binWidth;

  /// Whether a bin's count is a number of days (the summed types) rather than
  /// a number of readings, which is how the readout words it.
  final bool countsAreDays;

  const MeasurementDistributionWidgetFl(
    this.values, {
    required this.latest,
    required this.unit,
    this.binWidth,
    this.countsAreDays = false,
  });

  @override
  State<MeasurementDistributionWidgetFl> createState() => _MeasurementDistributionWidgetFlState();
}

class _MeasurementDistributionWidgetFlState extends State<MeasurementDistributionWidgetFl> {
  /// Bin the user tapped, read out above the bars like the heatmap's day.
  int? _selected;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return const SizedBox.shrink();
    }

    final histogram = buildWeightedHistogram(
      widget.values,
      latest: widget.latest,
      binWidth: widget.binWidth,
    );
    final theme = Theme.of(context);
    // Tapping outside the grid clears the selection, so a stale bin does not
    // stick around after the histogram underneath changed
    if (_selected != null && _selected! >= histogram.counts.length) {
      _selected = null;
    }

    return Column(
      children: [
        SizedBox(height: 20, child: _readout(histogram, theme)),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = _DistributionLayout(constraints.biggest, histogram.counts.length);

              return GestureDetector(
                onTapDown: (details) {
                  final bin = layout.binAt(details.localPosition, histogram.counts.length);
                  setState(() => _selected = bin == _selected ? null : bin);
                },
                child: CustomPaint(
                  size: constraints.biggest,
                  painter: _DistributionPainter(
                    histogram: histogram,
                    layout: layout,
                    selected: _selected,
                    bar: theme.colorScheme.primary,
                    median: theme.colorScheme.tertiary,
                    latest: theme.colorScheme.secondary,
                    grid: theme.colorScheme.outlineVariant,
                    outline: theme.colorScheme.outline,
                    labelStyle:
                        theme.textTheme.bodySmall?.copyWith(fontSize: 9) ??
                        const TextStyle(fontSize: 9),
                    formatValue: (value) => measurementValue(context, value, widget.unit),
                    formatCount: (count) => localizedNumberFormat(context).format(count),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// The line above the bars: the tapped bin as its range and count, or the
  /// median and newest value while nothing is selected, coloured like their
  /// marker lines so the numbers say what the lines only place.
  Widget _readout(MeasurementHistogram histogram, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final selected = _selected;

    if (selected != null) {
      final count = histogram.counts[selected];
      return Text(
        '${measurementValue(context, histogram.lowerEdgeOf(selected), widget.unit)}'
        '-${measurementWithUnit(context, histogram.upperEdgeOf(selected), widget.unit)}: '
        '${widget.countsAreDays ? l10n.distributionDayCount(count) : l10n.distributionEntryCount(count)}',
        style: theme.textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text.rich(
      TextSpan(
        style: theme.textTheme.bodySmall,
        children: [
          TextSpan(
            text:
                '${l10n.distributionMedian}: '
                '${measurementWithUnit(context, histogram.median, widget.unit)}',
            style: TextStyle(color: theme.colorScheme.tertiary),
          ),
          const TextSpan(text: '  ·  '),
          TextSpan(
            text:
                '${l10n.distributionLatest}: '
                '${measurementWithUnit(context, histogram.latest, widget.unit)}',
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Where the bars of a histogram sit, shared by the painter and the hit test
/// so a tap lands on the bin it looks like it lands on.
class _DistributionLayout {
  /// Room for the count labels on the left and the edge labels below.
  static const countLabelWidth = 30.0;
  static const edgeLabelHeight = 14.0;

  final double left;
  final double plotWidth;
  final double plotHeight;

  /// Width of one bin on screen, gap included.
  final double step;

  factory _DistributionLayout(Size size, int bins) {
    final plotWidth = max(1.0, size.width - countLabelWidth);
    return _DistributionLayout._(
      left: countLabelWidth,
      plotWidth: plotWidth,
      plotHeight: max(1.0, size.height - edgeLabelHeight),
      step: plotWidth / max(bins, 1),
    );
  }

  const _DistributionLayout._({
    required this.left,
    required this.plotWidth,
    required this.plotHeight,
    required this.step,
  });

  double xOfEdge(num edge) => left + edge * step;

  /// The bin at [position], null when the tap missed the bars.
  int? binAt(Offset position, int bins) {
    final bin = ((position.dx - left) / step).floor();
    if (bin < 0 || bin >= bins || position.dy > plotHeight) {
      return null;
    }
    return bin;
  }
}

class _DistributionPainter extends CustomPainter {
  final MeasurementHistogram histogram;
  final _DistributionLayout layout;
  final int? selected;
  final Color bar;
  final Color median;
  final Color latest;
  final Color grid;
  final Color outline;
  final TextStyle labelStyle;
  final String Function(num) formatValue;
  final String Function(int) formatCount;

  _DistributionPainter({
    required this.histogram,
    required this.layout,
    required this.selected,
    required this.bar,
    required this.median,
    required this.latest,
    required this.grid,
    required this.outline,
    required this.labelStyle,
    required this.formatValue,
    required this.formatCount,
  });

  /// Number of labelled gridlines and bin edges the chart aims for.
  static const _tickCount = 4;

  /// The x pixel of [value] on the value axis the bins tile.
  double _xOf(num value) => layout.xOfEdge((value - histogram.firstEdge) / histogram.binWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final counts = histogram.counts;
    final maxCount = counts.max;

    // The count axis climbs in round steps, and its top is the tick strictly
    // above the tallest bin, so the tallest bar keeps headroom instead of
    // ending flush at the canvas edge
    final interval = max(1, niceBinWidth(0, maxCount, targetBins: _tickCount)).toInt();
    final top = (maxCount ~/ interval + 1) * interval;
    double yOf(num count) => layout.plotHeight * (1 - count / top);

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    const countLabelRight = _DistributionLayout.countLabelWidth - 4;
    for (var tick = 0; tick <= top; tick += interval) {
      final y = yOf(tick);
      canvas.drawLine(Offset(layout.left, y), Offset(layout.left + layout.plotWidth, y), gridPaint);
      if (tick > 0) {
        // Right-aligned against the plot, centred on its gridline
        final label = _layoutLabel(formatCount(tick), maxWidth: countLabelRight);
        label.paint(canvas, Offset(countLabelRight - label.width, y - label.height / 2));
      }
    }

    // The gap follows the bin width on screen, like the bar charts leave a
    // gap between neighbouring bars but never go below a hairline
    final gap = (layout.step * 0.15).clamp(0.5, 2.0);
    final barPaint = Paint()..color = bar;
    for (final (bin, count) in counts.indexed) {
      if (count == 0) {
        continue;
      }
      final rect = Rect.fromLTRB(
        layout.xOfEdge(bin) + gap / 2,
        yOf(count),
        layout.xOfEdge(bin + 1) - gap / 2,
        layout.plotHeight,
      );
      canvas.drawRect(rect, barPaint);

      if (bin == selected) {
        canvas.drawRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = outline,
        );
      }
    }

    // The markers sit at the exact value, not on a bin: that precision is why
    // the histogram is painted by hand
    _paintMarker(canvas, histogram.median, median);
    _paintMarker(canvas, histogram.latest, latest, tipped: true);

    _paintEdgeLabels(canvas, size, counts.length);
  }

  /// A vertical line at [value], with a small tip for the marker that means a
  /// single point rather than a summary, so the two stay apart when they
  /// coincide.
  void _paintMarker(Canvas canvas, num value, Color color, {bool tipped = false}) {
    final x = _xOf(value);
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, layout.plotHeight),
      Paint()
        ..color = color
        ..strokeWidth = 1.5,
    );

    if (tipped) {
      canvas.drawPath(
        Path()
          ..moveTo(x - 4, 0)
          ..lineTo(x + 4, 0)
          ..lineTo(x, 6)
          ..close(),
        Paint()..color = color,
      );
    }
  }

  /// Every k-th bin edge, labelled with its value: the edges are the round
  /// numbers the bins were aligned to, so they are the natural ticks.
  void _paintEdgeLabels(Canvas canvas, Size size, int bins) {
    final labelEvery = max(1, (bins / _tickCount).ceil());
    for (var edge = 0; edge <= bins; edge += labelEvery) {
      final label = _layoutLabel(
        formatValue(histogram.lowerEdgeOf(edge)),
        maxWidth: layout.step * labelEvery,
      );
      // Centred on its edge, but kept inside the canvas
      final x = (layout.xOfEdge(edge) - label.width / 2).clamp(0.0, size.width - label.width);
      label.paint(canvas, Offset(x, layout.plotHeight + 2));
    }
  }

  /// Lays [text] out as a single unwrapped line; the call sites position it.
  TextPainter _layoutLabel(String text, {required double maxWidth}) => TextPainter(
    text: TextSpan(text: text, style: labelStyle),
    textDirection: ui.TextDirection.ltr,
    maxLines: 1,
    ellipsis: '',
  )..layout(maxWidth: maxWidth);

  @override
  bool shouldRepaint(_DistributionPainter oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.histogram != histogram;
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

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.marginRight = 15,
    this.textColor,
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final double marginRight;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: textColor)),
        SizedBox(width: marginRight),
      ],
    );
  }
}
