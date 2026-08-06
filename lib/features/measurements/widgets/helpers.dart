import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/widgets/error.dart';
import 'package:wger/core/widgets/progress_indicator.dart';
import 'package:wger/features/measurements/measurements.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/widgets/chart_range_selector.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

List<Widget> getOverviewWidgets(
  String title,
  List<MeasurementChartEntry> raw,
  List<MeasurementChartEntry> avg,
  String unit,
  BuildContext context, {
  MetricType metricType = MetricType.custom,
  List<PlanPeriod> planPeriods = const [],
  List<MeasurementChartEntry>? trend,
  ChartType chartType = ChartType.auto,
  ChartSettings settings = const ChartSettings(),
  Widget? distribution,
}) {
  return [
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
              avg,
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

List<Widget> getOverviewWidgetsSeries(
  String name,
  List<MeasurementChartEntry> entriesAll,
  List<MeasurementChartEntry> average,
  List<PlanPeriod> planPeriods,
  String unit,
  BuildContext context, {
  MetricType metricType = MetricType.custom,
  String? mainChartTitle,
  ChartType chartType = ChartType.auto,
  ChartSettings settings = const ChartSettings(),
  Widget? distribution,
}) {
  final title = mainChartTitle ?? AppLocalizations.of(context).chartAllTimeTitle(name);

  final resolved = resolveChartTypeForData(metricType, chartType, entriesAll);

  // Neither the heatmap nor the change chart nor the distribution is a line
  // over the range, and all of them bucket the points themselves: condensing
  // would collapse the days (or narrow the spread) they are built from, the
  // extra 30-day chart is a window they already show, and the legend names
  // lines they do not draw
  if (resolved == ChartType.heatmap ||
      resolved == ChartType.delta ||
      resolved == ChartType.distribution) {
    return getOverviewWidgets(
      // The selector right above names the range, so the title says what the
      // bars are instead
      switch (resolved) {
        ChartType.delta => AppLocalizations.of(context).chartWeeklyChangeTitle(name),
        ChartType.distribution => AppLocalizations.of(context).chartDistributionTitle(name),
        _ => title,
      },
      entriesAll,
      // The overall change is the one-number version of the change chart. Over
      // a grid it measures a line that is not drawn, and a summed metric has no
      // level to change.
      resolved == ChartType.delta && !metricType.isSummedPerDay ? average : const [],
      unit,
      context,
      metricType: metricType,
      chartType: chartType,
      settings: settings,
      distribution: distribution,
    );
  }

  // The points arrive condensed, so the trend follows the shape across weeks
  // rather than the swings within a single day
  final summed = metricType.isSummedPerDay;
  final trendAll = summed ? null : smoothedTrendline(entriesAll, period: settings.trend.emaPeriod);
  return [
    ...getOverviewWidgets(
      title,
      entriesAll,
      average,
      unit,
      context,
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
        Indicator(
          color: Theme.of(context).colorScheme.tertiary,
          text: AppLocalizations.of(context).indicatorAvg,
          isSquare: true,
        ),
        if (!metricType.isSummedPerDay)
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

// the start of a "sensible range": something relatively recent, which is most
// relevant for the user to track their progress, but a range should always
// include at least 5 points, and if not we chose a bigger one.
// we return the start of the last 2 months, 4 months, or null for the full history
DateTime? sensibleRangeStart(List<MeasurementChartEntry> entriesAll) {
  final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 61));
  final fourMonthsAgo = DateTime.now().subtract(const Duration(days: 122));

  if (entriesAll.whereDate(twoMonthsAgo, null).length > 4) {
    return twoMonthsAgo;
  }
  if (entriesAll.whereDate(fourMonthsAgo, null).length > 4) {
    return fourMonthsAgo;
  }
  return null;
}

// return the raw and average measurements for a "sensible range", see
// sensibleRangeStart. [averageDays] is the window of the moving average, which
// the category can configure.
(List<MeasurementChartEntry>, List<MeasurementChartEntry>) sensibleRange(
  List<MeasurementChartEntry> entriesAll, {
  int averageDays = 7,
}) {
  final average = movingAverage(entriesAll, days: averageDays);
  final start = sensibleRangeStart(entriesAll);

  if (start == null) {
    return (entriesAll, average);
  }
  return (entriesAll.whereDate(start, null), average.whereDate(start, null));
}

/// Turns stored entries into chart points, converting the value to [targetUnit].
///
/// Entries stored as a daily aggregate keep the range they summarise in
/// `extra_data` (heart rate min/max); it is lifted onto the point so the chart
/// draws a band around the line. Those bounds share the value's unit and are
/// converted along with it.
List<MeasurementChartEntry> chartEntriesFor(
  List<MeasurementEntry> entries, {
  required String targetUnit,
  required String categoryUnit,
}) => entries.map((entry) {
  num? bound(String key) {
    final stored = entry.extraData?[key];
    return stored is num ? entry.boundIn(stored, targetUnit, categoryUnit: categoryUnit) : null;
  }

  return MeasurementChartEntry(
    entry.valueIn(targetUnit, categoryUnit: categoryUnit),
    entry.date,
    min: bound('min'),
    max: bound('max'),
  );
}).toList();

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
      .watch(measurementChartBucketsProvider(category.id!, range.readCutoff, level))
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
      builder: (context, counts) => [_histogram(counts, summed)],
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
  final average = movingAverage(points, days: settings.averageWindow);
  final cutoff = range.cutoff;

  return cutoff == null
      ? (entries: points, average: average)
      : (entries: points.whereDate(cutoff, null), average: average.whereDate(cutoff, null));
}

/// Turns SQL-condensed buckets into chart points, converting to [targetUnit].
///
/// The counterpart of [chartEntriesFor] for the aggregated read path. A bucket
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

  return readings < distributionMinValues ? metricType.defaultChartType : resolved;
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
    trend: trend ?? smoothedTrendline(raw, period: settings.trend.emaPeriod),
    planPeriods: planPeriods,
  );
}
