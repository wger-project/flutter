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
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/log_meals_screen.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/nutrition/nutrition_card.dart';
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
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Modern header with title and chevron
              InkWell(
                onTap: _hasContent
                    ? () {
                        Navigator.of(context).pushNamed(
                          NutritionalPlanScreen.routeName,
                          arguments: _plan,
                        );
                      }
                    : null,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).nutritionalPlan,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_hasContent)
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 28,
                        ),
                    ],
                  ),
                ),
              ),

              // Progress indicators or empty state
              if (_hasContent)
                NutritionGoalsWidget(
                  nutritionalPlan: _plan!,
                  onLogIngredient: () {
                    Navigator.pushNamed(
                      context,
                      FormScreen.routeName,
                      arguments: FormScreenArguments(
                        AppLocalizations.of(context).logIngredient,
                        getIngredientLogForm(_plan!),
                        hasListView: true,
                      ),
                    );
                  },
                  onLogMeal: () {
                    Navigator.of(context).pushNamed(
                      LogMealsScreen.routeName,
                      arguments: _plan,
                    );
                  },
                )
              else
                // Empty state - inviting the user to create their first nutritional plan
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // 3D nutrition plan icon
                      Image.asset(
                        'assets/icons/nutrition-plan.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      // Inviting title
                      Text(
                        AppLocalizations.of(context).noNutritionalPlans,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade300
                              : Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        AppLocalizations.of(context).noNutritionalPlansSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Modern button to create nutritional plan
                      Material(
                        color: wgerAccentColor,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              FormScreen.routeName,
                              arguments: FormScreenArguments(
                                AppLocalizations.of(context).newNutritionalPlan,
                                hasListView: true,
                                PlanForm(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context).newNutritionalPlan,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}
