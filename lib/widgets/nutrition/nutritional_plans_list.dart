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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/core/text_prompt.dart';

class NutritionalPlansList extends StatefulWidget {
  @override
  _NutritionalPlansListState createState() => _NutritionalPlansListState();
}

class _NutritionalPlansListState extends State<NutritionalPlansList> {
  List<NutritionalPlan> _plans = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    final stream =
        Provider.of<NutritionPlansProvider>(context, listen: false).watchNutritionPlans();
    _subscription = stream.listen((plans) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        _plans = plans;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NutritionPlansProvider>(context, listen: false);

    return _plans.isEmpty
        ? const TextPrompt()
        : ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final currentPlan = _plans[index];
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      NutritionalPlanScreen.routeName,
                      arguments: currentPlan.id,
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
                        await showDialog(
                          context: context,
                          builder: (BuildContext contextDialog) {
                            return AlertDialog(
                              content: Text(
                                AppLocalizations.of(context).confirmDelete(currentPlan.description),
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
                                    provider.deletePlan(currentPlan.id!);
                                    Navigator.of(contextDialog).pop();
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
          );
  }
}
