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
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/log_meals_screen.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';

class DashboardNutritionWidget extends StatefulWidget {
  const DashboardNutritionWidget();

  @override
  _DashboardNutritionWidgetState createState() => _DashboardNutritionWidgetState();
}

class _DashboardNutritionWidgetState extends State<DashboardNutritionWidget> {
  NutritionalPlan? _plan;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _plan = Provider.of<NutritionPlansProvider>(context, listen: false).currentPlan;
    _hasContent = _plan != null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              _hasContent ? _plan!.description : AppLocalizations.of(context).nutritionalPlan,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text(
              _hasContent
                  ? DateFormat.yMd(Localizations.localeOf(context).languageCode)
                      .format(_plan!.creationDate)
                  : '',
            ),
            leading: Icon(
              Icons.restaurant,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
          ),
          if (_hasContent)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                child: FlNutritionalPlanGoalWidget(nutritionalPlan: _plan!),
              ),
            )
          else
            NothingFound(
              AppLocalizations.of(context).noNutritionalPlans,
              AppLocalizations.of(context).newNutritionalPlan,
              PlanForm(),
            ),
          if (_hasContent)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(AppLocalizations.of(context).goToDetailPage),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      NutritionalPlanScreen.routeName,
                      arguments: _plan,
                    );
                  },
                ),
                Expanded(child: Container()),
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
                        IngredientLogForm(_plan!),
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
                    Navigator.of(context).pushNamed(LogMealsScreen.routeName, arguments: _plan);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
