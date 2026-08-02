import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:wger/features/measurements/measurements.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
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
            ),
    ),
    if (avg.isNotEmpty) MeasurementOverallChangeWidget(avg.first, avg.last, unit),
    const SizedBox(height: 8),
  ];
}

List<Widget> getOverviewWidgetsSeries(
  String name,
  List<MeasurementChartEntry> entriesAll,
  List<MeasurementChartEntry> entries7dAvg,
  List<PlanPeriod> planPeriods,
  String unit,
  BuildContext context, {
  MetricType metricType = MetricType.custom,
  String? mainChartTitle,
  ChartType chartType = ChartType.auto,
}) {
  final title = mainChartTitle ?? AppLocalizations.of(context).chartAllTimeTitle(name);

  // A heatmap is one grid over the whole range and needs its points per day,
  // so none of what follows applies to it: condensing would collapse days into
  // weeks, the extra 30-day chart is a window the grid already shows, and the
  // legend names lines it does not draw
  if (metricType.resolveChartType(chartType) == ChartType.heatmap) {
    return getOverviewWidgets(
      title,
      entriesAll,
      // No overall change either: it is the distance between two points of a
      // line, which is not what the grid is about
      const [],
      unit,
      context,
      metricType: metricType,
      chartType: chartType,
    );
  }

  final monthAgo = DateTime.now().subtract(const Duration(days: 30));
  // Condensed once and shared: the main chart draws these points directly
  // (condensing again is a no-op), and both charts show slices of the same
  // trend. With dense metrics the full-series passes dominate the build.
  final summed = metricType.isSummedPerDay;
  final points = summed ? entriesAll : downsample(entriesAll);
  final trendAll = summed ? null : smoothedTrendline(points);
  return [
    ...getOverviewWidgets(
      title,
      points,
      entries7dAvg,
      unit,
      context,
      metricType: metricType,
      planPeriods: planPeriods,
      trend: trendAll,
    ),
    // if all time is significantly longer than 30 days (let's say > 75 days)
    // then let's show a separate chart just focusing on the last 30 days,
    // if there is data for it.
    if (entriesAll.isNotEmpty &&
        entriesAll.first.date.isBefore(entriesAll.last.date.subtract(const Duration(days: 75))) &&
        entriesAll.any((e) => e.date.isAfter(monthAgo)))
      ...getOverviewWidgets(
        AppLocalizations.of(context).chart30DaysTitle(name),
        // Sliced from the raw series, not from [points]: the window is
        // condensed on its own so it keeps the finer resolution its shorter
        // span allows
        entriesAll.whereDateWithInterpolation(monthAgo, null),
        entries7dAvg.whereDateWithInterpolation(monthAgo, null),
        unit,
        context,
        metricType: metricType,
        planPeriods: planPeriods,
        // The tail of the full-history trend: recomputing it inside the
        // window would seed the EMA from the window's (possibly interpolated)
        // first point and bend it across half the chart
        trend: trendAll?.whereDate(monthAgo, null),
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
// sensibleRangeStart
(List<MeasurementChartEntry>, List<MeasurementChartEntry>) sensibleRange(
  List<MeasurementChartEntry> entriesAll,
) {
  final entries7dAvg = moving7dAverage(entriesAll);
  final start = sensibleRangeStart(entriesAll);

  if (start == null) {
    return (entriesAll, entries7dAvg);
  }
  return (entriesAll.whereDate(start, null), entries7dAvg.whereDate(start, null));
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

/// The readings of a two-component group as ranges: one point per timestamp,
/// spanning from the lower component to the upper one.
///
/// A reading is one event, so it is drawn as a single bar (diastolic to
/// systolic) rather than as two lines: the components belong together, and
/// nothing was measured between two readings. Components are paired by their
/// shared timestamp, which is how both the importer and the group form write
/// them; an unpaired half-reading is skipped, it has no range.
///
/// Only readings from [cutoff] on are returned; null covers the full history.
List<MeasurementChartEntry> groupRangeEntries(MeasurementCategory group, {DateTime? cutoff}) {
  final byDate = <DateTime, List<num>>{};
  for (final child in group.children) {
    for (final entry in child.entries) {
      byDate
          .putIfAbsent(entry.date, () => [])
          .add(entry.valueIn(child.unit, categoryUnit: child.unit));
    }
  }

  final ranges = [
    for (final MapEntry(key: date, value: values) in byDate.entries)
      if (values.length > 1)
        MeasurementChartEntry(
          values.average,
          date,
          min: values.min,
          max: values.max,
        ),
  ]..sort((a, b) => a.date.compareTo(b.date));

  return cutoff == null ? ranges : ranges.whereDate(cutoff, null);
}

/// One line per component of a multi-value group, in the children's in-group
/// order and named after them.
///
/// All components share the same range, so their lines cover the same span
/// even when one of them has fewer readings. Only readings from [cutoff] on
/// are returned; null covers the full history.
List<MeasurementChartSeries> groupComponentSeries(
  BuildContext context,
  MeasurementCategory group, {
  DateTime? cutoff,
}) {
  List<MeasurementChartEntry> pointsOf(MeasurementCategory child) =>
      chartEntriesFor(child.entries, targetUnit: child.unit, categoryUnit: child.unit);

  return group.children
      .map(
        (child) => MeasurementChartSeries(
          cutoff == null ? pointsOf(child) : pointsOf(child).whereDate(cutoff, null),
          MeasurementSeriesRole.component,
          label: child.displayName(context),
        ),
      )
      .toList();
}

/// The components of [group] that stack into one whole, i.e. everything but a
/// roll-up component (see [MetricType.isGroupTotal]).
List<MeasurementCategory> stackableComponents(MeasurementCategory group) =>
    group.children.where((c) => !c.metricType.isGroupTotal).toList();

/// One stacked bar per day for [components], stacked in the order they are
/// given.
///
/// Only days that any component reported are returned. Values are read through
/// the unit helper, like everywhere else, so a component holding mixed units
/// still stacks correctly. Only readings from [cutoff] on are included; null
/// covers the full history.
List<MeasurementStackedEntry> groupStackedEntries(
  List<MeasurementCategory> components, {
  DateTime? cutoff,
}) {
  final byDay = <DateTime, List<num?>>{};
  for (final (index, child) in components.indexed) {
    for (final entry in child.entries) {
      if (cutoff != null && entry.date.isBefore(cutoff)) {
        continue;
      }
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      final values = byDay.putIfAbsent(day, () => List<num?>.filled(components.length, null));
      final value = entry.valueIn(child.unit, categoryUnit: child.unit);
      // A component can hold several entries for one day (a nap next to the
      // night), and the bar shows the day, so they add up
      values[index] = (values[index] ?? 0) + value;
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
Widget buildGroupChart(BuildContext context, MeasurementCategory group, {DateTime? cutoff}) {
  if (group.metricType.isSummedPerDay) {
    final components = stackableComponents(group);
    final stacked = groupStackedEntries(components, cutoff: cutoff);
    if (stacked.isNotEmpty) {
      return MeasurementStackedBarChartWidgetFl(
        stacked,
        components.map((c) => c.displayName(context)).toList(),
        group.unit,
      );
    }
  }

  final ranges = group.children.length == 2
      ? groupRangeEntries(group, cutoff: cutoff)
      : const <MeasurementChartEntry>[];
  if (ranges.isNotEmpty) {
    return MeasurementBarChartWidgetFl(ranges, group.unit);
  }

  return MeasurementChartWidgetFl(
    groupComponentSeries(context, group, cutoff: cutoff),
    group.unit,
  );
}

/// The readings of a group, newest first: one per timestamp, with what each
/// component holds for it.
///
/// Components are paired by their shared timestamp, which is how the importer
/// and the group form write them. A reading only some components reported is
/// kept, listing what there is: for a group whose parts are optional (a night
/// without deep sleep) that is the normal case, not a broken pair. Only
/// readings from [cutoff] on are included; null covers the full history.
List<(DateTime, Map<String, num>)> groupReadings(MeasurementCategory group, {DateTime? cutoff}) {
  // Keyed by the component id rather than by its name: the name is translated
  // for display, and two components could carry the same one
  final byDate = <DateTime, Map<String, num>>{};
  for (final child in group.children) {
    for (final entry in child.entries) {
      if (cutoff != null && entry.date.isBefore(cutoff)) {
        continue;
      }
      final values = byDate.putIfAbsent(entry.date, () => {});
      final value = entry.valueIn(child.unit, categoryUnit: child.unit);
      values[child.id!] = (values[child.id!] ?? 0) + value;
    }
  }

  return [for (final MapEntry(key: date, value: values) in byDate.entries) (date, values)]
    ..sort((a, b) => b.$1.compareTo(a.$1));
}

/// Whether [group] has anything to draw at all, i.e. any component holds a
/// reading within [cutoff].
bool groupHasData(MeasurementCategory group, {DateTime? cutoff}) => group.children.any(
  (child) => child.entries.any((e) => cutoff == null || !e.date.isBefore(cutoff)),
);

Widget buildChartForMetricType(
  MetricType metricType,
  List<MeasurementChartEntry> raw,
  List<MeasurementChartEntry> avg,
  String unit, {
  List<PlanPeriod> planPeriods = const [],
  List<MeasurementChartEntry>? trend,
  ChartType chartType = ChartType.auto,
}) {
  final summed = metricType.isSummedPerDay;

  // A pick that does not fit the metric type falls back to the derived chart,
  // which is also what a category configured on a newer client gets here
  if (metricType.resolveChartType(chartType) == ChartType.heatmap) {
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
  final points = downsample(raw);
  return MeasurementChartWidgetFl.singleMeasurement(
    points,
    unit,
    avgs: downsample(avg),
    trend: trend ?? smoothedTrendline(points),
    planPeriods: planPeriods,
  );
}
