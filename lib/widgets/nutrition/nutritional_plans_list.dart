/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/measurements.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/core/text_prompt.dart';
import 'package:wger/widgets/measurements/charts.dart';

class NutritionalPlansList extends StatelessWidget {
  final NutritionPlansProvider _nutritionProvider;

  const NutritionalPlansList(this._nutritionProvider);

  /// Builds the weight change information for a nutritional plan period
  Widget _buildWeightChangeInfo(BuildContext context, DateTime startDate, DateTime? endDate) {
    final provider = Provider.of<BodyWeightProvider>(context, listen: false);

    final entriesAll = provider.items.map((e) => MeasurementChartEntry(e.weight, e.date)).toList();
    final entries7dAvg = moving7dAverage(entriesAll).whereDateWithInterpolation(startDate, endDate);
    if (entries7dAvg.length < 2) {
      return const SizedBox.shrink();
    }

    // Calculate weight change
    final firstWeight = entries7dAvg.first;
    final lastWeight = entries7dAvg.last;
    final weightDifference = lastWeight.value - firstWeight.value;

    // Format the weight change text and determine color
    final String weightChangeText;
    final Color weightChangeColor;
    final profile = context.read<UserProvider>().profile;

    final unit = weightUnit(profile!.isMetric, context);

    if (weightDifference > 0) {
      weightChangeText = '+${weightDifference.toStringAsFixed(1)} $unit';
      weightChangeColor = Colors.red;
    } else if (weightDifference < 0) {
      weightChangeText = '${weightDifference.toStringAsFixed(1)} $unit';
      weightChangeColor = Colors.green;
    } else {
      weightChangeText = '0 $unit';
      weightChangeColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Text(
            '${AppLocalizations.of(context).weight} change: ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            weightChangeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: weightChangeColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _nutritionProvider.fetchAndSetAllPlansSparse(),
      edgeOffset: MediaQuery.of(context).padding.top + kToolbarHeight,
      child: _nutritionProvider.items.isEmpty
          ? const TextPrompt()
          : ListView.builder(
              padding: getAppBarBodyPadding(context, left: 10, right: 10, bottom: 10, extraTop: 10, includeToolbarHeight: false),
              itemCount: _nutritionProvider.items.length,
              itemBuilder: (context, index) {
                final currentPlan = _nutritionProvider.items[index];
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        NutritionalPlanScreen.routeName,
                        arguments: currentPlan,
                      );
                    },
                    title: Text(currentPlan.getLabel(context)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentPlan.endDate != null
                              ? 'from ${DateFormat.yMd(
                                  Localizations.localeOf(context).languageCode,
                                ).format(currentPlan.startDate)} to ${DateFormat.yMd(
                                  Localizations.localeOf(context).languageCode,
                                ).format(currentPlan.endDate!)}'
                              : 'from ${DateFormat.yMd(
                                  Localizations.localeOf(context).languageCode,
                                ).format(currentPlan.startDate)} (open ended)',
                        ),
                        _buildWeightChangeInfo(context, currentPlan.startDate, currentPlan.endDate),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const VerticalDivider(),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: AppLocalizations.of(context).delete,
                          onPressed: () async {
                            // Delete the plan from DB
                            await showDialog(
                              context: context,
                              builder: (BuildContext contextDialog) {
                                return AlertDialog(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).confirmDelete(currentPlan.description),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        MaterialLocalizations.of(context).cancelButtonLabel,
                                      ),
                                      onPressed: () => Navigator.of(contextDialog).pop(),
                                    ),
                                    TextButton(
                                      child: Text(
                                        AppLocalizations.of(context).delete,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                      onPressed: () {
                                        // Confirmed, delete the plan
                                        _nutritionProvider.deletePlan(currentPlan.id!);

                                        // Close the popup
                                        Navigator.of(contextDialog).pop();

                                        // and inform the user
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(context).successfullyDeleted,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
