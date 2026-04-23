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
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/log_meals_screen.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/core/async_value_widget.dart';
import 'package:wger/widgets/core/error.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';

class DashboardNutritionWidget extends ConsumerWidget {
  const DashboardNutritionWidget();

  /// Renders the dashboard card shell so loading / error / empty / data
  /// states all share the same outline (icon + title) instead of the card
  /// hopping around. The trailing widget changes per state.
  Widget _shell(
    BuildContext context, {
    required String title,
    required String subtitle,
    Widget? trailing,
    Widget? child,
  }) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
            subtitle: Text(subtitle),
            leading: Icon(
              Icons.restaurant,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
            trailing: trailing,
          ),
          ?child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final notifier = ref.read(nutritionProvider.notifier);

    return AsyncValueWidget<List<NutritionalPlan>>(
      value: ref.watch(nutritionProvider),
      loggerName: 'DashboardNutritionWidget',
      loading: _shell(
        context,
        title: i18n.nutritionalPlan,
        subtitle: '',
        trailing: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorBuilder: (e, st) => _shell(
        context,
        title: i18n.nutritionalPlan,
        subtitle: i18n.anErrorOccurred,
        trailing: const Icon(Icons.error_outline, color: Colors.red),
        child: StreamErrorIndicator(e, stacktrace: st),
      ),
      data: (_) {
        // currentPlan is derived from the notifier (it filters by date), so we
        // pull it from the notifier rather than the raw plan list.
        final plan = notifier.currentPlan;
        if (plan == null) {
          return _shell(
            context,
            title: i18n.nutritionalPlan,
            subtitle: '',
            child: NothingFound(
              i18n.noNutritionalPlans,
              i18n.newNutritionalPlan,
              PlanForm(),
            ),
          );
        }

        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text(plan.description, style: Theme.of(context).textTheme.headlineSmall),
                subtitle: Text(
                  DateFormat.yMd(
                    Localizations.localeOf(context).languageCode,
                  ).format(plan.creationDate),
                ),
                leading: Icon(
                  Icons.restaurant,
                  color: Theme.of(context).textTheme.headlineSmall!.color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                  child: FlNutritionalPlanGoalWidget(nutritionalPlan: plan),
                ),
              ),
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
                            child: Text(i18n.goToDetailPage),
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
                                tooltip: i18n.logIngredient,
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    FormScreen.routeName,
                                    arguments: FormScreenArguments(
                                      i18n.logIngredient,
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
                                tooltip: i18n.logMeal,
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
      },
    );
  }
}
