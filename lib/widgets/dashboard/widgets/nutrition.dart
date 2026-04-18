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
import 'package:intl/intl.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/log_meals_screen.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';

class DashboardNutritionWidget extends ConsumerWidget {
  const DashboardNutritionWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch so the widget rebuilds when plans arrive from the initial fetch.
    // currentPlan is derived from the watched state, so no separate read.
    ref.watch(nutritionProvider);
    final plan = ref.read(nutritionProvider.notifier).currentPlan;
    final hasContent = plan != null;

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              hasContent ? plan.description : AppLocalizations.of(context).nutritionalPlan,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text(
              hasContent
                  ? DateFormat.yMd(
                      Localizations.localeOf(context).languageCode,
                    ).format(plan.creationDate)
                  : '',
            ),
            leading: Icon(
              Icons.restaurant,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
          ),
          if (hasContent)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                child: FlNutritionalPlanGoalWidget(nutritionalPlan: plan),
              ),
            )
          else
            NothingFound(
              AppLocalizations.of(context).noNutritionalPlans,
              AppLocalizations.of(context).newNutritionalPlan,
              PlanForm(),
            ),
          if (hasContent)
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(AppLocalizations.of(context).goToDetailPage),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              NutritionalPlanScreen.routeName,
                              arguments: plan,
                            );
                          },
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const SvgIcon(
                                icon: SvgIconData('assets/icons/ingredient-diary.svg'),
                              ),
                              tooltip: AppLocalizations.of(context).logIngredient,
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  FormScreen.routeName,
                                  arguments: FormScreenArguments(
                                    AppLocalizations.of(context).logIngredient,
                                    getIngredientLogForm(plan),
                                    hasListView: true,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const SvgIcon(
                                icon: SvgIconData('assets/icons/meal-diary.svg'),
                              ),
                              tooltip: AppLocalizations.of(context).logMeal,
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushNamed(LogMealsScreen.routeName, arguments: plan);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
