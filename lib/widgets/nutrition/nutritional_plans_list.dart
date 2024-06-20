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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/core/text_prompt.dart';

class NutritionalPlansList extends StatelessWidget {
  final NutritionPlansProvider _nutritionProvider;

  const NutritionalPlansList(this._nutritionProvider);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _nutritionProvider.fetchAndSetAllPlansSparse(),
      child: _nutritionProvider.items.isEmpty
          ? const TextPrompt()
          : ListView.builder(
              padding: const EdgeInsets.all(10.0),
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
                    subtitle: Text(
                      DateFormat.yMd(
                        Localizations.localeOf(context).languageCode,
                      ).format(currentPlan.creationDate),
                    ),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
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
                                  AppLocalizations.of(context)
                                      .confirmDelete(currentPlan.description),
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
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
