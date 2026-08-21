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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/core/charts.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/measurements/charts/colors.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Number of dates to label on the x axis
const X_LABEL_COUNT = 4;

/// Widest a single bar gets, for charts with only a handful of entries
const MAX_BAR_WIDTH = 12.0;

const _hiddenTitles = AxisTitles(sideTitles: SideTitles(showTitles: false));

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

/// The value axis, drawn the same way by every chart of the set.
AxisTitles _valueTitles(BuildContext context, String unit, double? interval) => AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 65,
    interval: interval,
    getTitlesWidget: (value, meta) {
      // Don't show the first and last entries, to avoid overlap
      // see https://stackoverflow.com/questions/73355777/flutter-fl-chart-how-can-we-avoid-the-overlap-of-the-ordinate
      // this is needlessly aggressive if the titles are "sparse", but we should optimize for more busy data
      if (value == meta.min || value == meta.max) {
        return const Text('');
      }

      return _YAxisLabel(measurementWithUnit(context, value, unit));
    },
  ),
);

/// The date axis of the bar charts, which draw one title per group: their x
/// value is a position in [dates] rather than a timestamp, so thinning the
/// labels out has to happen here.
AxisTitles _dateIndexTitles(BuildContext context, List<DateTime> dates) {
  final labelStep = max(1, (dates.length / X_LABEL_COUNT).ceil());
  // keep the labels away from the chart edges
  final labelOffset = labelStep ~/ 2;
  final spansYears = dates.isNotEmpty && dates.first.year != dates.last.year;

  return AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        final index = value.toInt();
        if (index < 0 || index >= dates.length) {
          return const Text('');
        }
        if ((index - labelOffset) % labelStep != 0) {
          return const Text('');
        }
        // if we go across years, show years in the ticks. otherwise leave them out
        final date = dates[index];
        if (spansYears) {
          return Text(localizedDate(context).format(date));
        }
        return Text(DateFormat.Md(Localizations.localeOf(context).languageCode).format(date));
      },
    ),
  );
}

/// Bar width in pixels: the bars share the available width and keep a gap
/// between them, but never go below a hairline. Without it a couple of months
/// of readings overlap into a solid block.
double _barWidth(int count, double availableWidth) =>
    count == 0 ? MAX_BAR_WIDTH : (availableWidth / count * 0.7).clamp(1.0, MAX_BAR_WIDTH);

/// Horizontal lines only: a vertical one per bar would only repeat the bars.
FlGridData _barGrid(BuildContext context) => FlGridData(
  show: true,
  drawVerticalLine: false,
  getDrawingHorizontalLine: (value) =>
      FlLine(color: Theme.of(context).colorScheme.primaryContainer, strokeWidth: 1),
);

FlBorderData _barBorder(BuildContext context) => FlBorderData(
  show: true,
  border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
);

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
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        // Dot size is in pixels, so it has to follow from how many points
        // share the available space, otherwise they merge into a blob
        child: LayoutBuilder(
          builder: (context, constraints) => LineChart(mainData(context, constraints.maxWidth)),
        ),
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
        rightTitles: _hiddenTitles,
        topTitles: _hiddenTitles,
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
        leftTitles: _valueTitles(context, _unit, yAxis?.interval),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      lineBarsData: bars,
    );
  }
}

/// Bar chart for entries that are discrete events rather than a continuous
/// series: daily totals, and the readings of a multi-value group.
///
/// Entries carrying a range (see [MeasurementChartEntry.hasRange]) are drawn
/// as a bar spanning it, so a blood pressure reading appears as one bar from
/// diastolic to systolic. That keeps the pair together as the single event it
/// is, and claims nothing about the time between two readings.
class MeasurementBarChartWidgetFl extends StatelessWidget {
  final List<MeasurementChartEntry> _entries;
  final String _unit;

  /// Whether the values are changes rather than amounts: their bars hang off a
  /// marked zero line and are coloured by their direction.
  final bool _signed;

  const MeasurementBarChartWidgetFl(this._entries, this._unit, {bool signed = false, super.key})
    : _signed = signed;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) => BarChart(mainData(context, constraints.maxWidth)),
        ),
      ),
    );
  }

  BarTouchData tooltipData(BuildContext context) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        // Kept inside the chart, else the bars near an edge show a
        // tooltip that is cut off by it, or lies outside it entirely
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipColor: (group) => Theme.of(context).colorScheme.primaryContainer,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          if (groupIndex < 0 || groupIndex >= _entries.length) {
            return null;
          }
          final entry = _entries[groupIndex];
          final dateStr = DateFormat.Md(
            Localizations.localeOf(context).languageCode,
          ).format(entry.date);
          // A range is quoted as high over low, the way a blood pressure
          // reading is written. A change carries its sign, and the plus has to
          // be added: only the minus comes out of the number format
          final value = entry.hasRange
              ? '${measurementValue(context, entry.max!, _unit)}'
                    '/${measurementValue(context, entry.min!, _unit)}'
              : '${_signed && rod.toY > 0 ? '+' : ''}'
                    '${measurementValue(context, rod.toY, _unit)}';

          return BarTooltipItem(
            '$dateStr: ${unitSuffixed(value, _unit)}',
            TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          );
        },
      ),
    );
  }

  BarChartData mainData(BuildContext context, double availableWidth) {
    // A range bar spans from its lower to its upper bound, so both decide the
    // axis; a plain bar grows from zero
    final drawn = <num>[
      0,
      for (final entry in _entries) ...[
        entry.value,
        if (entry.min != null) entry.min!,
        if (entry.max != null) entry.max!,
      ],
    ];
    final yAxis = valueAxis(_unit, drawn.reduce(min), drawn.reduce(max));
    final barWidth = _barWidth(_entries.length, availableWidth);

    return BarChartData(
      minY: yAxis?.min,
      maxY: yAxis?.max,
      barTouchData: tooltipData(context),
      gridData: _barGrid(context),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: _hiddenTitles,
        topTitles: _hiddenTitles,
        bottomTitles: _dateIndexTitles(context, [for (final entry in _entries) entry.date]),
        leftTitles: _valueTitles(context, _unit, yAxis?.interval),
      ),
      borderData: _barBorder(context),
      // The line the change bars hang off. Without it a chart of only
      // decreases reads as a normal bar chart pointing the wrong way
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          if (_signed)
            HorizontalLine(y: 0, color: Theme.of(context).colorScheme.outline, strokeWidth: 1),
        ],
      ),
      barGroups: _entries
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
                  color: _signed
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

/// Stacked bar chart for a group whose components are parts of one whole, e.g.
/// the sleep stages of a night.
///
/// One bar per day, split into a segment per component in the components' own
/// order, so the bar's height is the night and its segments are how it was
/// spent. Colours come from [componentColor] by position, which is what ties a
/// segment to its legend entry.
class MeasurementStackedBarChartWidgetFl extends StatelessWidget {
  final List<MeasurementStackedEntry> _entries;
  final List<String> _labels;
  final String _unit;

  const MeasurementStackedBarChartWidgetFl(this._entries, this._labels, this._unit, {super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) => BarChart(mainData(context, constraints.maxWidth)),
        ),
      ),
    );
  }

  /// The whole bar with its parts, since a single segment says little without
  /// the night it belongs to.
  BarTouchData tooltipData(BuildContext context) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        // Kept inside the chart, else the bars near an edge show a
        // tooltip that is cut off by it, or lies outside it entirely
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipColor: (group) => Theme.of(context).colorScheme.primaryContainer,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          if (groupIndex < 0 || groupIndex >= _entries.length) {
            return null;
          }
          final entry = _entries[groupIndex];
          final dateStr = DateFormat.Md(
            Localizations.localeOf(context).languageCode,
          ).format(entry.date);
          final parts = [
            for (final (index, value) in entry.values.indexed)
              if (value != null) '${_labels[index]}: ${measurementValue(context, value, _unit)}',
          ];

          return BarTooltipItem(
            '$dateStr: ${measurementWithUnit(context, entry.total, _unit)}'
            '${parts.isEmpty ? '' : '\n${parts.join('\n')}'}',
            TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          );
        },
      ),
    );
  }

  BarChartData mainData(BuildContext context, double availableWidth) {
    // The bar is as tall as its segments together, so that is what the axis
    // has to cover
    final yAxis = valueAxis(_unit, 0, _entries.map((e) => e.total).fold<num>(0, max));
    final barWidth = _barWidth(_entries.length, availableWidth);

    return BarChartData(
      minY: yAxis?.min,
      maxY: yAxis?.max,
      barTouchData: tooltipData(context),
      gridData: _barGrid(context),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: _hiddenTitles,
        topTitles: _hiddenTitles,
        bottomTitles: _dateIndexTitles(context, [for (final entry in _entries) entry.date]),
        leftTitles: _valueTitles(context, _unit, yAxis?.interval),
      ),
      borderData: _barBorder(context),
      barGroups: _entries.asMap().entries.map((e) {
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
