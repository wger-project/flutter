import 'package:flutter/material.dart';
import 'package:wger/helpers/measurements.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/widgets/measurements/charts.dart';

List<Widget> getOverviewWidgets(
  String title,
  List<MeasurementChartEntry> raw,
  List<MeasurementChartEntry> avg,
  String unit,
  BuildContext context,
) {
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
          : MeasurementChartWidgetFl(raw, unit, avgs: avg),
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
  BuildContext context,
) {
  final monthAgo = DateTime.now().subtract(const Duration(days: 30));
  return [
    ...getOverviewWidgets(
      AppLocalizations.of(context).chartAllTimeTitle(name),
      entriesAll,
      entries7dAvg,
      unit,
      context,
    ),
    // Show overview widgets for each plan in plans
    for (final plan in plans)
      ...getOverviewWidgets(
        AppLocalizations.of(context).chartDuringPlanTitle(name, plan.description),
        entriesAll.whereDateWithInterpolation(plan.startDate, plan.endDate),
        entries7dAvg.whereDateWithInterpolation(plan.startDate, plan.endDate),
        unit,
        context,
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
      ],
    ),
  ];
}

// return the raw and average measurements for a "sensible range"
// a sensible range is something relatively recent, which is most relevant
// for the user to track their progress, but a range should always include
// at least 5 points, and if not we chose a bigger one.
// we return a range of the last 2 months, 4 months, or the full history
(List<MeasurementChartEntry>, List<MeasurementChartEntry>) sensibleRange(
  List<MeasurementChartEntry> entriesAll,
) {
  final entries7dAvg = moving7dAverage(entriesAll);
  final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 61));
  final fourMonthsAgo = DateTime.now().subtract(const Duration(days: 122));

  if (entriesAll.whereDate(twoMonthsAgo, null).length > 4) {
    return (
      entriesAll.whereDate(twoMonthsAgo, null),
      entries7dAvg.whereDate(twoMonthsAgo, null),
    );
  }
  if (entriesAll.whereDate(fourMonthsAgo, null).length > 4) {
    return (
      entriesAll.whereDate(fourMonthsAgo, null),
      entries7dAvg.whereDate(fourMonthsAgo, null),
    );
  }
  return (entriesAll, entries7dAvg);
}
