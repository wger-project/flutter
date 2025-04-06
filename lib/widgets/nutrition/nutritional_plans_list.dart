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
import 'package:wger/l10n/generated/app_localizations.dart';
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: _nutritionProvider.items.length,
                itemBuilder: (context, index) {
                  final currentPlan = _nutritionProvider.items[index];

                  return Dismissible(
                    key: ValueKey(currentPlan.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white, size: 28),
                    ),
                    confirmDismiss: (direction) async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext contextDialog) {
                          return AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: Text(
                              AppLocalizations.of(context).confirmDelete(currentPlan.description),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  MaterialLocalizations.of(context).cancelButtonLabel,
                                ),
                                onPressed: () => Navigator.of(contextDialog).pop(false),
                              ),
                              TextButton(
                                child: Text(
                                  AppLocalizations.of(context).delete,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                ),
                                onPressed: () => Navigator.of(contextDialog).pop(true),
                              ),
                            ],
                          );
                        },
                      );
                      return confirm ?? false;
                    },
                    onDismissed: (_) {
                      _nutritionProvider.deletePlan(currentPlan.id!);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).successfullyDeleted,
                            textAlign: TextAlign.center,
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            NutritionalPlanScreen.routeName,
                            arguments: currentPlan,
                          );
                        },
                        title: Text(
                          currentPlan.getLabel(context),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            DateFormat.yMd(Localizations.localeOf(context).languageCode)
                                .format(currentPlan.creationDate),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: AppLocalizations.of(context).delete,
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext contextDialog) {
                                return AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: Text(
                                    AppLocalizations.of(context)
                                        .confirmDelete(currentPlan.description),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        MaterialLocalizations.of(context).cancelButtonLabel,
                                      ),
                                      onPressed: () => Navigator.of(contextDialog).pop(false),
                                    ),
                                    TextButton(
                                      child: Text(
                                        AppLocalizations.of(context).delete,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                      onPressed: () {
                                        _nutritionProvider.deletePlan(currentPlan.id!);
                                        Navigator.of(contextDialog).pop();

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(context).successfullyDeleted,
                                              textAlign: TextAlign.center,
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
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
                      ),
                    ),
                  );
                },
              ));
  }
}
