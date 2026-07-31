/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:math';

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
      '$prefix${delta.abs().toStringAsFixed(1)} $_unit',
    );
  }
}

String weightUnit(bool isMetric, BuildContext context) {
  return isMetric ? AppLocalizations.of(context).kg : AppLocalizations.of(context).lb;
}

class MeasurementChartWidgetFl extends StatefulWidget {
  final List<MeasurementChartSeries> _series;
  final String _unit;

  const MeasurementChartWidgetFl(this._series, this._unit);

  /// The usual single-measurement chart: the values plus their average and
  /// trend line.
  MeasurementChartWidgetFl.singleMeasurement(
    List<MeasurementChartEntry> entries,
    String unit, {
    List<MeasurementChartEntry>? avgs,
    List<MeasurementChartEntry>? trend,
    super.key,
  }) : _unit = unit,
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
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: LineChart(mainData()),
      ),
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
  List<_ResolvedSeries> _resolveSeries() {
    final scheme = Theme.of(context).colorScheme;
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
            dotData: const FlDotData(show: true),
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
            dotData: const FlDotData(show: true),
          );
      }

      // Points that summarise a range get a band between their bounds. The
      // bounds themselves are invisible; only the fill between them shows.
      final ranged = series.entries.where((e) => e.hasRange).toList();
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

  /// [hidden] holds the indices of the invisible band bounds, which must not
  /// show up as tooltip lines; [labels] names the series that have a name.
  LineTouchData tooltipData(Set<int> hidden, Map<int, String?> labels) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.primaryContainer,
        getTooltipItems: (touchedSpots) {
          final numberFormat = localizedNumberFormat(context);

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

            return LineTooltipItem(
              '$prefix$dateStr: ${numberFormat.format(touchedSpot.y)} '
              '${widget._unit}$interpolatedMarker',
              TextStyle(color: touchedSpot.bar.color),
            );
          }).toList();
        },
      ),
    );
  }

  LineChartData mainData() {
    final numberFormat = localizedNumberFormat(context);
    final allEntries = widget._allEntries;
    final dates = allEntries.map((e) => e.date).toList()..sort();

    // Flatten the series into fl_chart's flat bar list, remembering which
    // indices are band bounds (invisible) and which carry a name.
    final bars = <LineChartBarData>[];
    final bands = <BetweenBarsData>[];
    final hidden = <int>{};
    final labels = <int, String?>{};
    for (final resolved in _resolveSeries()) {
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
      lineTouchData: tooltipData(hidden, labels),
      betweenBarsData: bands,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        // horizontalInterval: 1,
        // verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.primaryContainer, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.primaryContainer, strokeWidth: 1);
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
            getTitlesWidget: (value, meta) {
              // Don't show the first and last entries, to avoid overlap
              // see https://stackoverflow.com/questions/73355777/flutter-fl-chart-how-can-we-avoid-the-overlap-of-the-ordinate
              // this is needlessly aggressive if the titles are "sparse", but we should optimize for more busy data
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }

              return Text('${numberFormat.format(value)} ${widget._unit}');
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
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

// for each point, return the average of all the points in the 7 days preceding it
List<MeasurementChartEntry> moving7dAverage(List<MeasurementChartEntry> vals) {
  var start = 0;
  var end = 0;
  final List<MeasurementChartEntry> out = <MeasurementChartEntry>[];

  // first make sure our list is in ascending order
  vals.sort((a, b) => a.date.compareTo(b.date));

  while (end < vals.length) {
    // since users can log measurements several days, or minutes apart,
    // we can't make assumptions.  We have to manually advance 'start'
    // such that it is always the first point within our desired range.
    // posibly start == end (when there is only one point in the range)
    final intervalStart = vals[end].date.subtract(const Duration(days: 7));
    while (start < end && vals[start].date.isBefore(intervalStart)) {
      start++;
    }

    final sub = vals.sublist(start, end + 1).map((e) => e.value);
    final sum = sub.reduce((val, el) => val + el);
    out.add(MeasurementChartEntry(sum / sub.length, vals[end].date));

    end++;
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

class MeasurementBarChartWidgetFl extends StatefulWidget {
  final List<MeasurementChartEntry> _entries;
  final String _unit;

  const MeasurementBarChartWidgetFl(this._entries, this._unit);

  @override
  State<MeasurementBarChartWidgetFl> createState() => _MeasurementBarChartWidgetFlState();
}

class _MeasurementBarChartWidgetFlState extends State<MeasurementBarChartWidgetFl> {
  /// Number of dates to label on the x axis
  static const X_LABEL_COUNT = 4;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: BarChart(mainData()),
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
          final numberFormat = NumberFormat.decimalPattern(
            Localizations.localeOf(context).toString(),
          );
          final DateTime date = widget._entries[groupIndex].date;
          final dateStr = DateFormat.Md(Localizations.localeOf(context).languageCode).format(date);

          return BarTooltipItem(
            '$dateStr: ${numberFormat.format(rod.toY)} ${widget._unit}',
            TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          );
        },
      ),
    );
  }

  BarChartData mainData() {
    final String locale = Localizations.localeOf(context).toString();
    final NumberFormat numberFormat = NumberFormat.decimalPattern(locale);

    // A bar chart draws one bottom title per group (the x value is a group key,
    // not a position), so thinning out the labels has to happen here.
    final labelStep = max(1, (widget._entries.length / X_LABEL_COUNT).ceil());
    // keep the labels away from the chart edges
    final labelOffset = labelStep ~/ 2;
    final spansYears =
        widget._entries.isNotEmpty &&
        widget._entries.first.date.year != widget._entries.last.date.year;

    return BarChartData(
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
            getTitlesWidget: (value, meta) {
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }
              return Text('${numberFormat.format(value)} ${widget._unit}');
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      barGroups: widget._entries
          .asMap()
          .entries
          .map(
            (e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
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
