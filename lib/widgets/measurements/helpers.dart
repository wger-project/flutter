import 'package:flutter/material.dart';
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
    if (avg.isNotEmpty) MeasurementOverallChangeWidget(avg.first, avg.last, unit),
    const SizedBox(height: 8),
  ];
}

List<Widget> getOverviewWidgetsSeries(
  String name,
  List<MeasurementChartEntry> entriesAll,
  List<MeasurementChartEntry> entries7dAvg,
  NutritionalPlan? plan,
  String unit,
  BuildContext context,
) {
  final monthAgo = DateTime.now().subtract(const Duration(days: 30));
  return [
    ...getOverviewWidgets(
      '$name all-time',
      entriesAll,
      entries7dAvg,
      unit,
      context,
    ),
    if (plan != null)
      ...getOverviewWidgets(
        '$name during nutritional plan ${plan.description}',
        entriesAll.where((e) => e.date.isAfter(plan.creationDate)).toList(),
        entries7dAvg.where((e) => e.date.isAfter(plan.creationDate)).toList(),
        unit,
        context,
      ),
    // if all time is significantly longer than 30 days (let's say > 75 days)
    // and if there is is a plan and it also was > 75 days,
    // then let's show a separate chart just focusing on the last 30 days
    if (entriesAll.first.date.isBefore(entriesAll.last.date.subtract(const Duration(days: 75))) &&
        (plan == null ||
            entriesAll
                .firstWhere((e) => e.date.isAfter(plan.creationDate))
                .date
                .isBefore(entriesAll.last.date.subtract(const Duration(days: 30)))))
      ...getOverviewWidgets(
        '$name last 30 days',
        entriesAll.where((e) => e.date.isAfter(monthAgo)).toList(),
        entries7dAvg.where((e) => e.date.isAfter(monthAgo)).toList(),
        unit,
        context,
      ),
    // legend
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Indicator(color: Theme.of(context).colorScheme.primary, text: 'raw', isSquare: true),
        Indicator(color: Theme.of(context).colorScheme.tertiary, text: 'avg', isSquare: true),
      ],
    ),
  ];
}
