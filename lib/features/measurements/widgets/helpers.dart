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
                'No data available',
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
}) {
  final monthAgo = DateTime.now().subtract(const Duration(days: 30));
  // Condensed once and shared: the main chart draws these points directly
  // (condensing again is a no-op), and both charts show slices of the same
  // trend. With dense metrics the full-series passes dominate the build.
  final summed = metricType.isSummedPerDay;
  final points = summed ? entriesAll : downsample(entriesAll);
  final trendAll = summed ? null : smoothedTrendline(points);
  return [
    ...getOverviewWidgets(
      mainChartTitle ?? AppLocalizations.of(context).chartAllTimeTitle(name),
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
List<MeasurementChartEntry> groupRangeEntries(MeasurementCategory group) {
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

  final start = sensibleRangeStart(ranges);
  return start == null ? ranges : ranges.whereDate(start, null);
}

/// One line per component of a multi-value group, in the children's in-group
/// order and named after them.
///
/// All components share the same range, so their lines cover the same span
/// even when one of them has fewer readings.
List<MeasurementChartSeries> groupComponentSeries(MeasurementCategory group) {
  List<MeasurementChartEntry> pointsOf(MeasurementCategory child) =>
      chartEntriesFor(child.entries, targetUnit: child.unit, categoryUnit: child.unit);

  final start = sensibleRangeStart(group.children.expand(pointsOf).toList());
  return group.children
      .map(
        (child) => MeasurementChartSeries(
          start == null ? pointsOf(child) : pointsOf(child).whereDate(start, null),
          MeasurementSeriesRole.component,
          label: child.name,
        ),
      )
      .toList();
}

Widget buildChartForMetricType(
  MetricType metricType,
  List<MeasurementChartEntry> raw,
  List<MeasurementChartEntry> avg,
  String unit, {
  List<PlanPeriod> planPeriods = const [],
  List<MeasurementChartEntry>? trend,
}) {
  if (metricType.isSummedPerDay) {
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
