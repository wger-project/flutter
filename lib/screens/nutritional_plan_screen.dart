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
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/log_meals_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/nutritional_plan_detail.dart';

enum NutritionalPlanOptions {
  edit,
  delete,
}

class NutritionalPlanScreen extends StatefulWidget {
  const NutritionalPlanScreen();
  static const routeName = '/nutritional-plan-detail';

  @override
  _NutritionalPlanScreenState createState() => _NutritionalPlanScreenState();
}

class _NutritionalPlanScreenState extends State<NutritionalPlanScreen> {
  NutritionalPlan? _plan;
  StreamSubscription? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as String;
    //final id = 111;

    final stream =
        Provider.of<NutritionPlansProvider>(context, listen: false).watchNutritionPlan(id);
    _subscription = stream.listen((plan) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        _plan = plan;
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
    const appBarForeground = Colors.white;

    return Scaffold(
      //appBar: getAppBar(nutritionalPlan),
      floatingActionButton: _plan == null
          ? const Offstage()
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: null,
                  tooltip: AppLocalizations.of(context).logIngredient,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      FormScreen.routeName,
                      arguments: FormScreenArguments(
                        AppLocalizations.of(context).logIngredient,
                        IngredientLogForm(_plan!),
                        hasListView: true,
                      ),
                    );
                  },
                  child: const SvgIcon(
                    icon: SvgIconData('assets/icons/ingredient-diary.svg'),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  heroTag: null,
                  tooltip: AppLocalizations.of(context).logMeal,
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      LogMealsScreen.routeName,
                      arguments: _plan,
                    );
                  },
                  child: const SvgIcon(
                    icon: SvgIconData('assets/icons/meal-diary.svg'),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
      body: _plan == null
          ? const Text('plan not found')
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  foregroundColor: appBarForeground,
                  pinned: true,
                  iconTheme: const IconThemeData(color: appBarForeground),
                  actions: [
                    if (!_plan!.onlyLogging)
                      IconButton(
                        icon: const SvgIcon(
                          icon: SvgIconData('assets/icons/meal-add.svg'),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            FormScreen.routeName,
                            arguments: FormScreenArguments(
                              AppLocalizations.of(context).addMeal,
                              MealForm(_plan!.id!),
                            ),
                          );
                        },
                      ),
                    PopupMenuButton<NutritionalPlanOptions>(
                      icon: const Icon(Icons.more_vert, color: appBarForeground),
                      onSelected: (value) {
                        switch (value) {
                          case NutritionalPlanOptions.edit:
                            Navigator.pushNamed(
                              context,
                              FormScreen.routeName,
                              arguments: FormScreenArguments(
                                AppLocalizations.of(context).edit,
                                PlanForm(_plan),
                                hasListView: true,
                              ),
                            );
                            break;
                          case NutritionalPlanOptions.delete:
                            Provider.of<NutritionPlansProvider>(context, listen: false)
                                .deletePlan(_plan!.id!);
                            Navigator.of(context).pop();
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<NutritionalPlanOptions>(
                            value: NutritionalPlanOptions.edit,
                            child: ListTile(
                              leading: const Icon(Icons.edit),
                              title: Text(AppLocalizations.of(context).edit),
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem<NutritionalPlanOptions>(
                            value: NutritionalPlanOptions.delete,
                            child: ListTile(
                              leading: const Icon(Icons.delete),
                              title: Text(AppLocalizations.of(context).delete),
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.fromLTRB(56, 0, 56, 16),
                    title: Text(
                      _plan!.getLabel(context),
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(color: appBarForeground),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: NutritionalPlan.read(_plan!.id!),
                  builder: (context, AsyncSnapshot<NutritionalPlan> snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  const SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Consumer<NutritionPlansProvider>(
                              builder: (context, value, child) =>
                                  NutritionalPlanDetailWidget(_plan!),
                            ),
                ),
              ],
            ),
    );
  }
}
