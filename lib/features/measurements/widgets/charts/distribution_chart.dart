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
import 'package:flutter/material.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

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
    super.key,
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
