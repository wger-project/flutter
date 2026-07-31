import 'package:flutter/material.dart';
import 'package:wger/features/measurements/measurements.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/nutrition/models/nutritional_plan.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

List<Widget> getOverviewWidgets(
  String title,
  List<MeasurementChartEntry> raw,
  List<MeasurementChartEntry> avg,
  String unit,
  BuildContext context, {
  MetricType metricType = MetricType.custom,
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
          : buildChartForMetricType(metricType, raw, avg, unit),
    ),
    if (avg.isNotEmpty) MeasurementOverallChangeWidget(avg.first, avg.last, unit),
    const SizedBox(height: 8),
  ];
}

List<Widget> getOverviewWidgetsSeries(
  String name,
  List<MeasurementChartEntry> entriesAll,
  List<MeasurementChartEntry> entries7dAvg,
  List<NutritionalPlan> plans,
  String unit,
  BuildContext context, {
  MetricType metricType = MetricType.custom,
  String? mainChartTitle,
}) {
  final monthAgo = DateTime.now().subtract(const Duration(days: 30));
  return [
    ...getOverviewWidgets(
      mainChartTitle ?? AppLocalizations.of(context).chartAllTimeTitle(name),
      entriesAll,
      entries7dAvg,
      unit,
      context,
      metricType: metricType,
    ),
    // Show overview widgets for each plan in plans
    for (final plan in plans)
      ...getOverviewWidgets(
        AppLocalizations.of(context).chartDuringPlanTitle(name, plan.description),
        entriesAll.whereDateWithInterpolation(plan.startDate, plan.endDate),
        entries7dAvg.whereDateWithInterpolation(plan.startDate, plan.endDate),
        unit,
        context,
        metricType: metricType,
      ),
    // if all time is significantly longer than 30 days (let's say > 75 days)
    // then let's show a separate chart just focusing on the last 30 days,
    // if there is data for it.
    if (entriesAll.isNotEmpty &&
        entriesAll.first.date.isBefore(entriesAll.last.date.subtract(const Duration(days: 75))) &&
        entriesAll.any((e) => e.date.isAfter(monthAgo)))
      ...getOverviewWidgets(
        AppLocalizations.of(context).chart30DaysTitle(name),
        entriesAll.whereDateWithInterpolation(monthAgo, null),
        entries7dAvg.whereDateWithInterpolation(monthAgo, null),
        unit,
        context,
        metricType: metricType,
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
/// draws a band around the line. Those bounds are written in the category unit
/// alongside the value, and aggregates never carry a per-entry unit.
List<MeasurementChartEntry> chartEntriesFor(
  List<MeasurementEntry> entries, {
  required String targetUnit,
  required String categoryUnit,
}) => entries
    .map(
      (e) => MeasurementChartEntry(
        e.valueIn(targetUnit, categoryUnit: categoryUnit),
        e.date,
        min: e.extraData?['min'] as num?,
        max: e.extraData?['max'] as num?,
      ),
    )
    .toList();

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
  String unit,
) {
  if (metricType.isSummedPerDay) {
    return MeasurementBarChartWidgetFl(aggregatePerDay(raw), unit);
  }
  // if (metricType.isRangeType) {
  //   return buildRangeChartForMetricType(metricType, raw, unit);
  // }
  return MeasurementChartWidgetFl.singleMeasurement(
    raw,
    unit,
    avgs: avg,
    trend: smoothedTrendline(raw),
  );
}
