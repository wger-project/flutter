/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/form_screen.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/measurements/charts/colors.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import 'charts.dart';
import 'forms.dart';

class CategoriesCard extends ConsumerWidget {
  final MeasurementCategory currentCategory;
  final double? elevation;
  final ChartRange range;

  /// Name the card is titled with, `category.displayName` by default. Body
  /// weight is titled like the screen it leads to.
  final String? title;

  /// Unit the values are converted to, `category.unit` by default. Body weight
  /// is shown in the profile unit, since its entries can be stored in either.
  final String? displayUnit;

  /// Label for [displayUnit], the unit itself by default. The two differ where
  /// the unit is translated (kg reads كغم in Arabic).
  final String? displayUnitLabel;

  /// Form the add action opens, [MeasurementEntryForm] by default. Body weight
  /// has one of its own, with quick steppers and a unit dropdown.
  final Widget? newEntryForm;

  /// What the detail link opens, the entries screen of the category by
  /// default. Body weight has a screen of its own.
  final VoidCallback? onShowDetails;

  const CategoriesCard(
    this.currentCategory, {
    this.elevation,
    this.range = ChartRange.last3Months,
    this.title,
    this.displayUnit,
    this.displayUnitLabel,
    this.newEntryForm,
    this.onShowDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (currentCategory.hasChildren) {
      return _buildGroupCard(context, ref);
    }

    return Card(
      elevation: elevation,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                title ?? currentCategory.displayName(context),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            MeasurementChartArea<List<MeasurementChartEntry>>(
              identity: currentCategory.id!,
              watch: (ref) => chartPointsFor(ref, currentCategory, range, targetUnit: displayUnit),
              builder: _chart,
              // The card is one of many on the overview; a failing query takes
              // its chart, not the way into the category
              onError: (_, _) => const [SizedBox(height: 220)],
            ),
            const Divider(),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed:
                              onShowDetails ??
                              () {
                                Navigator.pushNamed(
                                  context,
                                  MeasurementEntriesScreen.routeName,
                                  arguments: currentCategory.id,
                                );
                              },
                          child: Text(AppLocalizations.of(context).goToDetailPage),
                        ),
                        IconButton(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              FormScreen.routeName,
                              arguments: FormScreenArguments(
                                AppLocalizations.of(context).newEntry,
                                newEntryForm ?? MeasurementEntryForm(currentCategory.id!),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// The chart itself and the one-number change below it.
  List<Widget> _chart(BuildContext context, List<MeasurementChartEntry> allPoints) {
    final settings = currentCategory.chartSettings;
    final (:entries, :average) = chartSeriesFor(allPoints, range, settings);
    final unit = displayUnit ?? currentCategory.unit;
    final unitLabel = displayUnitLabel ?? unit;

    return [
      Container(
        padding: const EdgeInsets.all(10),
        height: 220,
        child: buildChartForMetricType(
          currentCategory.metricType,
          entries,
          average,
          unitLabel,
          chartType: currentCategory.chartType,
          settings: settings,
          distribution: MeasurementDistributionChart(
            category: currentCategory,
            range: range,
            unitLabel: unitLabel,
            targetUnit: unit,
          ),
        ),
      ),
      if (average.isNotEmpty && !currentCategory.metricType.isSummedPerDay)
        MeasurementOverallChangeWidget(
          average.first,
          average.last,
          unitLabel,
        ),
    ];
  }

  /// The group's chart and one row per component with its latest reading.
  List<Widget> _groupChartAndRows(
    BuildContext context,
    Map<String, List<MeasurementChartEntry>> points,
  ) {
    // A range is a single bar whose ends speak for themselves, and a stacked
    // bar's segments carry the component colours; only the line chart needs
    // the dots on the rows below to tie a component to its line.
    final asRange = currentCategory.children.length == 2 && groupRangeEntries(points).isNotEmpty;
    // The stacked chart draws only the components that are parts of the whole,
    // so a row's colour has to come from that list rather than from its
    // position among all children
    final stacked = currentCategory.metricType.isSummedPerDay
        ? stackableComponents(currentCategory)
        : null;

    return [
      if (groupHasData(points))
        Container(
          padding: const EdgeInsets.all(10),
          height: 220,
          child: buildGroupChart(context, currentCategory, points),
        ),
      // One watch for all the rows: every emission rebuilds them together
      // anyway. Read separately from the chart above, whose points cover the
      // charted range, while a component measured less often than that still
      // has a last known value worth showing.
      Consumer(
        builder: (context, ref, _) {
          final latest = ref.watch(latestMeasurementEntriesProvider).value ?? const {};

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: currentCategory.children.mapIndexed((index, child) {
              final colorIndex = stacked == null
                  ? index
                  : stacked.indexWhere((c) => c.id == child.id);
              final value = latest[child.id];

              return ListTile(
                dense: true,
                // The dot ties the row to its part of the chart above. A range
                // is a single bar, where the ends speak for themselves, and a
                // roll-up component is no segment of the stack.
                leading: asRange || colorIndex < 0
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
                trailing: Text(
                  value != null
                      ? measurementWithUnit(
                          context,
                          value.valueIn(child.unit, categoryUnit: child.unit),
                          child.unit,
                          decimals: child.metricType.displayDecimals,
                        )
                      : '—',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  MeasurementEntriesScreen.routeName,
                  arguments: child.id,
                ),
              );
            }).toList(),
          );
        },
      ),
    ];
  }

  /// Card for a multi-value group (e.g. blood pressure): all components in one
  /// chart, then one row per component with its latest reading; new readings
  /// are entered for all components at once.
  Widget _buildGroupCard(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: elevation,
      // Scrolls like the leaf card above: a group of five components (the
      // sleep stages) is taller than the box the dashboard carousel gives it
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                currentCategory.displayName(context),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            MeasurementChartArea<Map<String, List<MeasurementChartEntry>>>(
              identity: currentCategory.id!,
              watch: (ref) => groupPointsFor(ref, currentCategory, range),
              builder: _groupChartAndRows,
              // The rows are the way into the components, so a failing query
              // takes the chart above them and nothing else
              onError: (context, _) => _groupChartAndRows(context, const {}),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text(AppLocalizations.of(context).goToDetailPage),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      MeasurementEntriesScreen.routeName,
                      arguments: currentCategory.id,
                    );
                  },
                ),
                IconButton(
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      FormScreen.routeName,
                      arguments: FormScreenArguments(
                        AppLocalizations.of(context).newEntry,
                        GroupMeasurementEntryForm(currentCategory),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
