import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/widgets/error.dart';
import 'package:wger/core/widgets/progress_indicator.dart';
import 'package:wger/features/measurements/charts/colors.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// A chart with the overall change below it, for a Column to spread, titled
/// where [title] says something the screen around it does not.
List<Widget> buildChartSection(
  BuildContext context, {
  String? title,
  required List<MeasurementChartEntry> raw,
  required List<MeasurementChartEntry> avg,
  required String unit,
  MetricType metricType = MetricType.custom,
  List<PlanPeriod> planPeriods = const [],
  List<MeasurementChartEntry>? trend,
  ChartType chartType = ChartType.auto,
  ChartSettings settings = const ChartSettings(),
  Widget? distribution,
}) {
  return [
    if (title != null)
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    Container(
      padding: const EdgeInsets.all(15),
      height: 220,
      child: raw.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context).noDataAvailable,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                ),
              ),
            )
          : buildChartForMetricType(
              metricType,
              raw,
              // The average is still computed for the number below, the
              // setting only decides whether the line is drawn
              settings.averageWindow == null ? const [] : avg,
              unit,
              planPeriods: planPeriods,
              trend: trend,
              chartType: chartType,
              settings: settings,
              distribution: distribution,
            ),
    ),
    if (avg.isNotEmpty) MeasurementOverallChangeWidget(avg.first, avg.last, unit),
    const SizedBox(height: 8),
  ];
}

/// The trend over [raw], null when the user turned the trend line off
List<MeasurementChartEntry>? _trendlineFor(
  List<MeasurementChartEntry> raw,
  ChartSettings settings,
) {
  final period = settings.trend.emaPeriod;

  return period == null ? null : smoothedTrendline(raw, period: period);
}

/// The chart of a measurement series: [buildChartSection] for the chart the
/// type resolves to, plus the legend naming the lines it draws.
List<Widget> buildSeriesChartSection(
  BuildContext context, {
  required String name,
  required List<MeasurementChartEntry> entriesAll,
  required List<MeasurementChartEntry> average,
  required String unit,
  List<PlanPeriod> planPeriods = const [],
  MetricType metricType = MetricType.custom,
  ChartType chartType = ChartType.auto,
  ChartSettings settings = const ChartSettings(),
  Widget? distribution,
}) {
  final resolved = resolveChartTypeForData(metricType, chartType, entriesAll);

  // Neither the heatmap nor the change chart nor the distribution is a line
  // over the range, and all of them bucket the points themselves: condensing
  // would collapse the days (or narrow the spread) they are built from, the
  // extra 30-day chart is a window they already show, and the legend names
  // lines they do not draw
  if (resolved == ChartType.heatmap ||
      resolved == ChartType.delta ||
      resolved == ChartType.distribution) {
    return buildChartSection(
      context,
      // The screen names the category and the selector names the range, so a
      // title is only worth its line where it says what the bars are
      title: switch (resolved) {
        ChartType.delta => AppLocalizations.of(context).chartWeeklyChangeTitle(name),
        ChartType.distribution => AppLocalizations.of(context).chartDistributionTitle(name),
        _ => null,
      },
      raw: entriesAll,
      // The overall change is the one-number version of the change chart. Over
      // a grid it measures a line that is not drawn, and a summed metric has no
      // level to change.
      avg: resolved == ChartType.delta && !metricType.isSummedPerDay ? average : const [],
      unit: unit,
      metricType: metricType,
      chartType: chartType,
      settings: settings,
      distribution: distribution,
    );
  }

  // The points arrive condensed, so the trend follows the shape across weeks
  // rather than the swings within a single day
  final summed = metricType.isSummedPerDay;
  final period = settings.trend.emaPeriod;
  final trendAll = summed || period == null ? null : smoothedTrendline(entriesAll, period: period);
  return [
    ...buildChartSection(
      context,
      raw: entriesAll,
      avg: average,
      unit: unit,
      metricType: metricType,
      planPeriods: planPeriods,
      trend: trendAll,
      settings: settings,
    ),
    // legend
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Indicator(
          color: Theme.of(context).colorScheme.primary,
          text: AppLocalizations.of(context).indicatorRaw,
          isSquare: true,
        ),
        if (settings.averageWindow != null)
          Indicator(
            color: Theme.of(context).colorScheme.tertiary,
            text: AppLocalizations.of(context).indicatorAvg,
            isSquare: true,
          ),
        if (trendAll != null)
          Indicator(
            color: Theme.of(context).colorScheme.secondary,
            text: AppLocalizations.of(context).indicatorTrend,
            isSquare: true,
          ),
        if (planPeriods.isNotEmpty)
          Indicator(
            color: planBandColor(context),
            text: AppLocalizations.of(context).nutritionalPlan,
            isSquare: true,
          ),
      ],
    ),
  ];
}

/// The points the chart of [category] draws, over the range it is read for.
///
/// They reach back beyond the range, so the moving average derived from them
/// does not start over at the cutoff. [targetUnit] overrides the category
/// unit, for body weight, which is shown in the profile unit.
AsyncValue<List<MeasurementChartEntry>> chartPointsFor(
  WidgetRef ref,
  MeasurementCategory category,
  ChartRange range, {
  String? targetUnit,
}) {
  final unit = targetUnit ?? category.unit;
  final level = chartBucketLevel(category.metricType, category.chartType);

  return ref
      .watch(measurementChartBucketsProvider(category.id!, range.readCutoff, null, level))
      .whenData(
        (buckets) => chartEntriesForBuckets(
          buckets,
          targetUnit: unit,
          categoryUnit: category.unit,
          summed: category.metricType.isSummedPerDay,
        ),
      );
}

/// Draws a chart from the aggregated queries, keeping what it last drew while
/// another range loads.
///
/// Picking a range watches a different provider, which starts out loading:
/// without this the chart would blank for a frame, which is what the range
/// switch used to look like.
class MeasurementChartArea<T> extends ConsumerStatefulWidget {
  const MeasurementChartArea({
    required this.identity,
    required this.watch,
    required this.builder,
    required this.onError,
    this.loading = const SizedBox(height: 220, child: BoxedProgressIndicator()),
    super.key,
  });

  /// What the kept data belongs to. Another category in the same slot of a
  /// list has nothing to do with what is on screen.
  final Object identity;

  final AsyncValue<T> Function(WidgetRef ref) watch;

  /// Draws the chart for the data that arrived.
  final List<Widget> Function(BuildContext context, T data) builder;

  /// Drawn when nothing could be read and there is nothing to keep: a card
  /// leaves the space empty, a detail screen names the error.
  final List<Widget> Function(BuildContext context, Object error) onError;

  /// Placeholder for the first load, before there is anything to keep.
  final Widget loading;

  @override
  ConsumerState<MeasurementChartArea<T>> createState() => _MeasurementChartAreaState<T>();
}

class _MeasurementChartAreaState<T> extends ConsumerState<MeasurementChartArea<T>> {
  T? _last;

  @override
  void didUpdateWidget(covariant MeasurementChartArea<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identity != widget.identity) {
      _last = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.watch(ref);
    if (data.hasValue) {
      _last = data.value;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: switch ((data, _last)) {
        (_, final T last) => widget.builder(context, last),
        (AsyncError(:final error), _) => widget.onError(context, error),
        _ => [widget.loading],
      },
    );
  }
}

/// The chart points of a group's components, keyed by component id, over the
/// range they are read for.
AsyncValue<Map<String, List<MeasurementChartEntry>>> groupPointsFor(
  WidgetRef ref,
  MeasurementCategory group,
  ChartRange range,
) {
  final level = group.metricType.isSummedPerDay
      ? MeasurementBucketLevel.day
      : MeasurementBucketLevel.auto;

  return ref
      .watch(measurementGroupBucketsProvider(group.id!, range.readCutoff, level))
      .whenData((buckets) => groupComponentPoints(group, buckets, cutoff: range.cutoff));
}

/// The histogram of a category, read as counted values rather than as
/// readings.
///
/// The one chart with its own query: it has no time axis, so it needs every
/// value rather than a condensed series, and counting them is what keeps that
/// from being every row.
class MeasurementDistributionChart extends ConsumerWidget {
  const MeasurementDistributionChart({
    required this.category,
    required this.range,
    required this.unitLabel,
    required this.targetUnit,
    super.key,
  });

  final MeasurementCategory category;
  final ChartRange range;

  /// Label the values are shown with, and the unit they are converted to.
  final String unitLabel;
  final String targetUnit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summed = category.metricType.isSummedPerDay;

    return MeasurementChartArea<List<MeasurementValueCount>>(
      identity: category.id!,
      watch: (ref) =>
          ref.watch(measurementValueCountsProvider(category.id!, range.countCutoff, summed)),
      loading: const CenteredProgressIndicator(),
      // The histogram fills the height it is given; the column around it would
      // otherwise offer it an unbounded one
      builder: (context, counts) => [Expanded(child: _histogram(counts, summed))],
      onError: (_, error) => [StreamErrorIndicator(error.toString())],
    );
  }

  Widget _histogram(List<MeasurementValueCount> counts, bool summed) {
    if (counts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Values are counted per unit they were entered in, so each goes through
    // the conversion helper before equal ones are added up
    num inTargetUnit(MeasurementValueCount count) => convertWeight(
      count.value,
      from: unitOrFallback(count.unit, category.unit),
      to: targetUnit,
    );

    final merged = <num, int>{};
    for (final count in counts) {
      merged.update(
        inTargetUnit(count),
        (existing) => existing + count.count,
        ifAbsent: () => count.count,
      );
    }

    return MeasurementDistributionWidgetFl(
      [for (final MapEntry(:key, :value) in merged.entries) (value: key, count: value)],
      latest: inTargetUnit(counts.reduce((a, b) => b.newest.isAfter(a.newest) ? b : a)),
      unit: unitLabel,
      binWidth: category.metricType.binWidth(targetUnit),
      countsAreDays: summed,
    );
  }
}

/// The chart a multi-value group gets, which follows from what its components
/// are to each other.
///
/// Components that are parts of one whole (the sleep stages) stack into one
/// bar per day. Two components that are the ends of a reading (blood pressure)
/// become one floating bar spanning them. Everything else, and anything the
/// first two have no data for, falls back to one line per component so the
/// card never goes blank while there is something to show.
Widget buildGroupChart(
  BuildContext context,
  MeasurementCategory group,
  Map<String, List<MeasurementChartEntry>> points,
) {
  if (group.metricType.isSummedPerDay) {
    final components = stackableComponents(group);
    final stacked = groupStackedEntries(components, points);
    if (stacked.isNotEmpty) {
      return MeasurementStackedBarChartWidgetFl(
        stacked,
        components.map((c) => c.displayName(context)).toList(),
        group.unit,
      );
    }
  }

  final ranges = group.children.length == 2
      ? groupRangeEntries(points)
      : const <MeasurementChartEntry>[];
  if (ranges.isNotEmpty) {
    return MeasurementBarChartWidgetFl(ranges, group.unit);
  }

  return MeasurementChartWidgetFl(groupComponentSeries(context, group, points), group.unit);
}

Widget buildChartForMetricType(
  MetricType metricType,
  List<MeasurementChartEntry> raw,
  List<MeasurementChartEntry> avg,
  String unit, {
  List<PlanPeriod> planPeriods = const [],
  List<MeasurementChartEntry>? trend,
  ChartType chartType = ChartType.auto,
  ChartSettings settings = const ChartSettings(),
  Widget? distribution,
}) {
  final summed = metricType.isSummedPerDay;

  // A pick that does not fit the metric type falls back to the derived chart,
  // which is also what a category configured on a newer client gets here
  final resolved = resolveChartTypeForData(metricType, chartType, raw);

  if (resolved == ChartType.distribution) {
    // Its own query, since a histogram needs every value and the points here
    // are condensed. What is counted mirrors the heatmap's split: the summed
    // types distribute their daily totals, the sample types every reading.
    return distribution ?? const SizedBox.shrink();
  }

  if (resolved == ChartType.delta) {
    // Not condensed: a week is already the bucket, and the deltas are what the
    // chart draws rather than the values they were derived from
    return MeasurementBarChartWidgetFl(weeklyDeltas(raw, summed: summed), unit, signed: true);
  }

  if (resolved == ChartType.heatmap) {
    // The cells are days, so how a day's readings become one value has to be
    // decided here: the summed types are a daily total, the sample types are
    // repeated readings of the same thing and average
    return MeasurementHeatmapWidgetFl(summed ? aggregatePerDay(raw) : averagePerDay(raw), unit);
  }

  if (summed) {
    return MeasurementBarChartWidgetFl(aggregatePerDay(raw), unit);
  }

  // Condense before anything is derived from the points: a trend line over
  // raw samples follows the swings within a single day instead of the trend
  // across weeks, and the average is as dense as the values it summarises
  return MeasurementChartWidgetFl.singleMeasurement(
    raw,
    unit,
    avgs: avg,
    trend: trend ?? _trendlineFor(raw, settings),
    planPeriods: planPeriods,
  );
}

/// One row per component of [group]: a colour dot tying the row to its part
/// of the group chart, the component's name, and [trailing]; tapping opens
/// the component's entries.
///
/// The stacked chart draws only the components that are parts of the whole,
/// so a row's colour comes from that list rather than from its position among
/// all children, and a roll-up component gets no dot. [showDots] turns them
/// off wholesale, for a range chart whose single bar needs no legend.
class GroupComponentRows extends StatelessWidget {
  const GroupComponentRows(this.group, {required this.trailing, this.showDots = true});

  final MeasurementCategory group;

  /// Built per component: the latest value on the card, a chevron on the
  /// detail screen.
  final Widget? Function(BuildContext context, MeasurementCategory child) trailing;

  final bool showDots;

  @override
  Widget build(BuildContext context) {
    final stacked = group.metricType.isSummedPerDay ? stackableComponents(group) : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: group.children.mapIndexed((index, child) {
        final colorIndex = stacked == null ? index : stacked.indexWhere((c) => c.id == child.id);

        return ListTile(
          dense: true,
          leading: !showDots || colorIndex < 0
              ? null
              : Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: componentColor(context, colorIndex),
                  ),
                ),
          title: Text(child.displayName(context)),
          trailing: trailing(context, child),
          onTap: () => Navigator.pushNamed(
            context,
            MeasurementEntriesScreen.routeName,
            arguments: child.id,
          ),
        );
      }).toList(),
    );
  }
}
