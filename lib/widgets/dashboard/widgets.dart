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

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/log_meal_screen.dart';
import 'package:wger/screens/log_meals_screen.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/measurements/categories_card.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/forms.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/helpers.dart';
import 'package:wger/widgets/weight/forms.dart';
import 'package:wger/widgets/workouts/forms.dart';

enum viewMode { base, withMeals, withMealsDetails }

class DashboardNutritionWidget extends StatefulWidget {
  const DashboardNutritionWidget();
  @override
  _DashboardNutritionWidgetState createState() => _DashboardNutritionWidgetState();
}

class _DashboardNutritionWidgetState extends State<DashboardNutritionWidget> {
  NutritionalPlan? _plan;
  var _viewMode = viewMode.base;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _plan = Provider.of<NutritionPlansProvider>(context, listen: false).currentPlan;
    _hasContent = _plan != null;
  }

  List<Widget> getContent() {
    final List<Widget> out = [];

    if (!_hasContent) {
      return out;
    }

    if (_viewMode == viewMode.withMealsDetails || _viewMode == viewMode.withMeals) {
      for (final meal in _plan!.meals) {
        out.add(
          Row(
            children: [
              Expanded(
                child: Text(
                  meal.time!.format(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  //textAlign: TextAlign.left,
                ),
              ),
              MutedText(getShortNutritionValues(
                meal.plannedNutritionalValues,
                context,
              )),
              IconButton(
                icon: const SvgIcon(
                  icon: SvgIconData('assets/icons/meal-diary.svg'),
                ),
                color: wgerPrimaryButtonColor,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    LogMealScreen.routeName,
                    arguments: LogMealArguments(meal, false),
                  );
                },
              ),
            ],
          ),
        );
        out.add(const SizedBox(height: 5));

        if (_viewMode == viewMode.withMealsDetails) {
          for (final item in meal.mealItems) {
            out.add(
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.ingredient.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${item.amount.toStringAsFixed(0)} ${AppLocalizations.of(context).g}',
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          out.add(const SizedBox(height: 10));
        }
        out.add(const Divider());
      }
    }

    return out;
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
            trailing: _hasContent
                ? Tooltip(
                    message: AppLocalizations.of(context).toggleDetails,
                    child: switch (_viewMode) {
                      viewMode.base => const Icon(Icons.info_outline),
                      viewMode.withMeals => const Icon(Icons.info),
                      viewMode.withMealsDetails => const Icon(Icons.info),
                    },
                  )
                : const SizedBox(),
            onTap: () {
              setState(() {
                _viewMode = switch (_viewMode) {
                  viewMode.base => viewMode.withMeals,
                  viewMode.withMeals => viewMode.withMealsDetails,
                  viewMode.withMealsDetails => viewMode.base,
                };
              });
            },
          ),
          if (_hasContent)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  ...getContent(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    child: FlNutritionalPlanGoalWidget(nutritionalPlan: _plan!),
                  ),
                ],
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

class DashboardWeightWidget extends StatefulWidget {
  const DashboardWeightWidget();
  @override
  _DashboardWeightWidgetState createState() => _DashboardWeightWidgetState();
}

class _DashboardWeightWidgetState extends State<DashboardWeightWidget> {
  @override
  Widget build(BuildContext context) {
    final profile = context.read<UserProvider>().profile;
    final weightProvider = context.read<BodyWeightProvider>();

    return Consumer<BodyWeightProvider>(
      builder: (context, workoutProvider, child) => Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context).weight,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              leading: FaIcon(
                FontAwesomeIcons.weightScale,
                color: Theme.of(context).textTheme.headlineSmall!.color,
              ),
            ),
            Column(
              children: [
                if (weightProvider.items.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: MeasurementChartWidgetFl(
                          weightProvider.items
                              .map((e) => MeasurementChartEntry(e.weight, e.date))
                              .toList(),
                          unit: profile!.isMetric
                              ? AppLocalizations.of(context).kg
                              : AppLocalizations.of(context).lb,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: Text(
                              AppLocalizations.of(context).goToDetailPage,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed(WeightScreen.routeName);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              Navigator.pushNamed(
                                context,
                                FormScreen.routeName,
                                arguments: FormScreenArguments(
                                  AppLocalizations.of(context).newEntry,
                                  WeightForm(weightProvider.getNewestEntry()?.copyWith(id: null)),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  NothingFound(
                    AppLocalizations.of(context).noWeightEntries,
                    AppLocalizations.of(context).newEntry,
                    WeightForm(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMeasurementWidget extends StatefulWidget {
  const DashboardMeasurementWidget();
  @override
  _DashboardMeasurementWidgetState createState() => _DashboardMeasurementWidgetState();
}

class _DashboardMeasurementWidgetState extends State<DashboardMeasurementWidget> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MeasurementProvider>(context, listen: false);

    final items =
        provider.categories.map<Widget>((item) => CategoriesCard(item, elevation: 0)).toList();
    if (items.isNotEmpty) {
      items.add(
        NothingFound(
          AppLocalizations.of(context).moreMeasurementEntries,
          AppLocalizations.of(context).newEntry,
          MeasurementCategoryForm(),
        ),
      );
    }
    return Consumer<MeasurementProvider>(
      builder: (context, workoutProvider, child) => Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context).measurements,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              leading: FaIcon(
                FontAwesomeIcons.chartLine,
                color: Theme.of(context).textTheme.headlineSmall!.color,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => Navigator.pushNamed(
                  context,
                  MeasurementCategoriesScreen.routeName,
                ),
              ),
            ),
            Column(
              children: [
                if (items.isNotEmpty)
                  Column(
                    children: [
                      CarouselSlider(
                        items: items,
                        carouselController: _controller,
                        options: CarouselOptions(
                          autoPlay: false,
                          enlargeCenterPage: false,
                          viewportFraction: 1,
                          enableInfiniteScroll: false,
                          aspectRatio: 1.1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: items.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () => _controller.animateToPage(entry.key),
                              child: Container(
                                width: 12.0,
                                height: 12.0,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Theme.of(context).textTheme.headlineSmall!.color!.withOpacity(
                                            _current == entry.key ? 0.9 : 0.4,
                                          ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                else
                  NothingFound(
                    AppLocalizations.of(context).noMeasurementEntries,
                    AppLocalizations.of(context).newEntry,
                    MeasurementCategoryForm(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardWorkoutWidget extends StatefulWidget {
  const DashboardWorkoutWidget();
  @override
  _DashboardWorkoutWidgetState createState() => _DashboardWorkoutWidgetState();
}

class _DashboardWorkoutWidgetState extends State<DashboardWorkoutWidget> {
  var _showDetail = false;
  bool _hasContent = false;

  WorkoutPlan? _workoutPlan;

  @override
  void initState() {
    super.initState();
    _workoutPlan = context.read<WorkoutPlansProvider>().activePlan;
    _hasContent = _workoutPlan != null;
  }

  List<Widget> getContent() {
    final List<Widget> out = [];

    if (!_hasContent) {
      return out;
    }

    for (final day in _workoutPlan!.days) {
      out.add(SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Text(
                day.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: MutedText(day.getDaysText, textAlign: TextAlign.right),
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              color: wgerPrimaryButtonColor,
              onPressed: () {
                Navigator.of(context).pushNamed(GymModeScreen.routeName, arguments: day);
              },
            ),
          ],
        ),
      ));

      for (final set in day.sets) {
        out.add(SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...set.settingsFiltered.map((s) {
                return _showDetail
                    ? Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.exerciseObj
                                  .getExercise(Localizations.localeOf(context).languageCode)
                                  .name),
                              const SizedBox(width: 10),
                              MutedText(
                                set.getSmartRepr(s.exerciseObj).join('\n'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      )
                    : Container();
              }),
            ],
          ),
        ));
      }
      out.add(const Divider());
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              _hasContent ? _workoutPlan!.name : AppLocalizations.of(context).labelWorkoutPlan,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text(
              _hasContent
                  ? DateFormat.yMd(Localizations.localeOf(context).languageCode)
                      .format(_workoutPlan!.creationDate)
                  : '',
            ),
            leading: Icon(
              Icons.fitness_center,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
            trailing: _hasContent
                ? Tooltip(
                    message: AppLocalizations.of(context).toggleDetails,
                    child: _showDetail ? const Icon(Icons.info) : const Icon(Icons.info_outline),
                  )
                : const SizedBox(),
            onTap: () {
              setState(() {
                _showDetail = !_showDetail;
              });
            },
          ),
          if (_hasContent)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(children: [...getContent()]),
            )
          else
            NothingFound(
              AppLocalizations.of(context).noWorkoutPlans,
              AppLocalizations.of(context).newWorkout,
              WorkoutForm(WorkoutPlan.empty()),
            ),
          if (_hasContent)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  child: Text(AppLocalizations.of(context).goToDetailPage),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      WorkoutPlanScreen.routeName,
                      arguments: _workoutPlan,
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class NothingFound extends StatelessWidget {
  final String _title;
  final String _titleForm;
  final Widget _form;

  const NothingFound(this._title, this._titleForm, this._form);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_title),
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.add_box, color: wgerPrimaryButtonColor),
            onPressed: () async {
              Navigator.pushNamed(
                context,
                FormScreen.routeName,
                arguments: FormScreenArguments(
                  _titleForm,
                  hasListView: true,
                  _form,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
