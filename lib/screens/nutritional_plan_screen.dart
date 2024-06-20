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

class NutritionalPlanScreen extends StatelessWidget {
  const NutritionalPlanScreen();
  static const routeName = '/nutritional-plan-detail';

  Future<NutritionalPlan> _loadFullPlan(BuildContext context, int planId) {
    return Provider.of<NutritionPlansProvider>(context, listen: false).fetchAndSetPlanFull(planId);
  }

  @override
  Widget build(BuildContext context) {
    const appBarForeground = Colors.white;
    final nutritionalPlan = ModalRoute.of(context)!.settings.arguments as NutritionalPlan;

    return Scaffold(
      //appBar: getAppBar(nutritionalPlan),
      floatingActionButton: Row(
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
                  IngredientLogForm(nutritionalPlan),
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
                arguments: nutritionalPlan,
              );
            },
            child: const SvgIcon(
              icon: SvgIconData('assets/icons/meal-diary.svg'),
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            foregroundColor: appBarForeground,
            pinned: true,
            iconTheme: const IconThemeData(color: appBarForeground),
            actions: [
              if (!nutritionalPlan.onlyLogging)
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
                        MealForm(nutritionalPlan.id!),
                      ),
                    );
                  },
                ),
              PopupMenuButton<NutritionalPlanOptions>(
                icon: const Icon(Icons.more_vert, color: appBarForeground),
                onSelected: (value) {
                  if (value == NutritionalPlanOptions.edit) {
                    Navigator.pushNamed(
                      context,
                      FormScreen.routeName,
                      arguments: FormScreenArguments(
                        AppLocalizations.of(context).edit,
                        PlanForm(nutritionalPlan),
                        hasListView: true,
                      ),
                    );
                  } else if (value == NutritionalPlanOptions.delete) {
                    Provider.of<NutritionPlansProvider>(context, listen: false)
                        .deletePlan(nutritionalPlan.id!);
                    Navigator.of(context).pop();
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
                nutritionalPlan.getLabel(context),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: appBarForeground),
              ),
            ),
          ),
          FutureBuilder(
            future: _loadFullPlan(context, nutritionalPlan.id!),
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
                            NutritionalPlanDetailWidget(nutritionalPlan),
                      ),
          ),
        ],
      ),
    );
  }
}
