import 'package:flutter/material.dart';
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
      child: MeasurementChartWidgetFl(raw, unit, avgs: avg),
    ),
    if (avg.isNotEmpty)
      MeasurementOverallChangeWidget(avg.first, avg.last, unit),
    const SizedBox(height: 8),
  ];
}

// TODO(dieter): i'm not sure if this handles well the case where weights were not logged consistently
// e.g. if the plan runs for a month, but the first point is after 3 weeks.
// and the last (non-included) point was *right* before the startDate.
// wouldn't it be better to interpolate the missing points?
List<Widget> getOverviewWidgetsSeries(
  String name,
  List<MeasurementChartEntry> entriesAll,
  List<MeasurementChartEntry> entries7dAvg,
  NutritionalPlan? plan,
  String unit,
  BuildContext context,
) {
  final monthAgo = DateTime.now().subtract(const Duration(days: 30));
  final showPlan = plan != null &&
      entriesAll.any((e) =>
          e.date.isAfter(plan.startDate) &&
          (plan.endDate == null || e.date.isBefore(plan.endDate!)));

  return [
    ...getOverviewWidgets(
      AppLocalizations.of(context).chartAllTimeTitle(name),
      entriesAll,
      entries7dAvg,
      unit,
      context,
    ),
    if (showPlan)
      ...getOverviewWidgets(
        AppLocalizations.of(context)
            .chartDuringPlanTitle(name, plan.description),
        entriesAll
            .where((e) =>
                e.date.isAfter(plan.startDate) &&
                (plan.endDate == null || e.date.isBefore(plan.endDate!)))
            .toList(),
        entries7dAvg
            .where((e) =>
                e.date.isAfter(plan.startDate) &&
                (plan.endDate == null || e.date.isBefore(plan.endDate!)))
            .toList(),
        unit,
        context,
      ),
    // if all time is significantly longer than 30 days (let's say > 75 days)
    // and any plan was also > 75 days,
    // then let's show a separate chart just focusing on the last 30 days,
    // if there is data for it.
    if (entriesAll.isNotEmpty &&
        entriesAll.first.date.isBefore(
            entriesAll.last.date.subtract(const Duration(days: 75))) &&
        (plan == null ||
            (showPlan &&
                entriesAll
                    .firstWhere((e) => e.date.isAfter(plan.startDate))
                    .date
                    .isBefore(entriesAll.last.date
                        .subtract(const Duration(days: 30))))) &&
        entriesAll.any((e) => e.date.isAfter(monthAgo)))
      ...getOverviewWidgets(
        AppLocalizations.of(context).chart30DaysTitle(name),
        entriesAll.where((e) => e.date.isAfter(monthAgo)).toList(),
        entries7dAvg.where((e) => e.date.isAfter(monthAgo)).toList(),
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

  if (entriesAll.where((e) => e.date.isAfter(twoMonthsAgo)).length > 4) {
    return (
      entriesAll.where((e) => e.date.isAfter(twoMonthsAgo)).toList(),
      entries7dAvg.where((e) => e.date.isAfter(twoMonthsAgo)).toList(),
    );
  }
  if (entriesAll.where((e) => e.date.isAfter(fourMonthsAgo)).length > 4) {
    return (
      entriesAll.where((e) => e.date.isAfter(fourMonthsAgo)).toList(),
      entries7dAvg.where((e) => e.date.isAfter(fourMonthsAgo)).toList(),
    );
  }
  return (entriesAll, entries7dAvg);
}
