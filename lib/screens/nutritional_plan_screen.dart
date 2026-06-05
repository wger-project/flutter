/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/log_meals_screen.dart';
import 'package:wger/widgets/core/object_gone_redirect.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/nutritional_plan_detail.dart';

enum NutritionalPlanOptions {
  edit,
  delete,
}

class NutritionalPlanScreen extends ConsumerWidget {
  const NutritionalPlanScreen();

  static const routeName = '/nutritional-plan-detail';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planId = ModalRoute.of(context)!.settings.arguments as String;
    const appBarForeground = Colors.white;

    // Wait for the catalogue to stream in, then resolve the plan by id. A loaded
    // state that no longer has it means the plan was deleted (here or on another
    // device): leave, rather than render a phantom plan whose meal/diary writes
    // would orphan against a missing plan.
    final state = ref.watch(nutritionProvider).value;
    if (state == null) {
      return const Scaffold(body: Center(child: BoxedProgressIndicator()));
    }
    final nutritionalPlan = state.findByIdOrNull(planId);
    if (nutritionalPlan == null) {
      return objectGoneRedirect(context);
    }
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
                  getIngredientLogForm(nutritionalPlan),
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
                  switch (value) {
                    case NutritionalPlanOptions.edit:
                      Navigator.pushNamed(
                        context,
                        FormScreen.routeName,
                        arguments: FormScreenArguments(
                          AppLocalizations.of(context).edit,
                          PlanForm(nutritionalPlan),
                          hasListView: true,
                        ),
                      );
                      break;
                    case NutritionalPlanOptions.delete:
                      ref.read(nutritionProvider.notifier).deletePlan(nutritionalPlan.id!);
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
                nutritionalPlan.getLabel(context),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: appBarForeground),
              ),
            ),
          ),
          NutritionalPlanDetailWidget(nutritionalPlan),
        ],
      ),
    );
  }
}
