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
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:wger/core/charts.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/measurements/charts/colors.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/widgets/charts/fl_axes.dart';

/// A series resolved into what fl_chart needs: the line itself plus, for range
/// series, the two invisible bounds the band is painted between.
class _ResolvedSeries {
  _ResolvedSeries(this.line, this.label, {this.bounds});

  final LineChartBarData line;
  final String? label;
  final (LineChartBarData, LineChartBarData)? bounds;
}

class MeasurementChartWidgetFl extends StatelessWidget {
  /// Radius of a dot on a chart with room to spare
  static const MAX_DOT_RADIUS = 4.0;

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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      // Dot size is in pixels, so it has to follow from how many points share
      // the available space, otherwise they merge into a blob
      child: LayoutBuilder(
        builder: (context, constraints) => LineChart(mainData(context, constraints.maxWidth)),
      ),
    );
  }

  /// Dots shrink as points get denser, so they stay distinguishable instead of
  /// overdrawing each other.
  FlDotData _dotData(double availableWidth) {
    final count = _series.map((s) => s.entries.length).fold(0, max);
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
  List<_ResolvedSeries> _resolveSeries(BuildContext context, double availableWidth) {
    final scheme = Theme.of(context).colorScheme;
    final dots = _dotData(availableWidth);
    var componentIndex = 0;

    return _series.map((series) {
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
      final hasSpread = carriesSpread && series.entries.any((e) => e.hasRange);
      return _ResolvedSeries(
        line,
        series.label,
        // A point without a spread (a day with a single measurement) pinches
        // the band to the line instead of switching it off for the series
        bounds: hasSpread
            ? (
                LineChartBarData(
                  spots: _spots(series.entries, (e) => e.min ?? e.value),
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: _spots(series.entries, (e) => e.max ?? e.value),
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
    for (final p in _planPeriods)
      if (!date.isBefore(p.range.start) && !date.isAfter(p.range.end)) p.name,
  ];

  /// The plan periods as translucent full-height bands, clamped to the span
  /// of the data so they never draw outside the axes.
  RangeAnnotations _planBands(BuildContext context, List<DateTime> dates) {
    if (dates.isEmpty || _planPeriods.isEmpty) {
      return const RangeAnnotations();
    }

    final bounds = DateTimeRange(start: dates.first, end: dates.last);
    return RangeAnnotations(
      verticalRangeAnnotations: [
        for (final range in clampPeriods([for (final p in _planPeriods) p.range], bounds))
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
  LineTouchData tooltipData(BuildContext context, Set<int> hidden, Map<int, String?> labels) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        // Kept inside the chart, else the points near an edge show a tooltip
        // that is cut off by it, or lies outside it entirely
        fitInsideHorizontally: true,
        fitInsideVertically: true,
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
              '${measurementWithUnit(context, touchedSpot.y, _unit)}$interpolatedMarker',
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

  LineChartData mainData(BuildContext context, double availableWidth) {
    final allEntries = _allEntries;
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
    final yAxis = drawn.isEmpty ? null : valueAxis(_unit, drawn.reduce(min), drawn.reduce(max));

    // Flatten the series into fl_chart's flat bar list, remembering which
    // indices are band bounds (invisible) and which carry a name.
    final bars = <LineChartBarData>[];
    final bands = <BetweenBarsData>[];
    final hidden = <int>{};
    final labels = <int, String?>{};
    for (final resolved in _resolveSeries(context, availableWidth)) {
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
      lineTouchData: tooltipData(context, hidden, labels),
      betweenBarsData: bands,
      rangeAnnotations: _planBands(context, dates),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.outlineVariant, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.outlineVariant, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: hiddenTitles,
        topTitles: hiddenTitles,
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
        leftTitles: valueTitles(context, _unit, yAxis?.interval),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      lineBarsData: bars,
    );
  }
}
