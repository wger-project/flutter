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

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wger/helpers/colors.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/widgets/measurements/charts.dart';

class FlNutritionalPlanGoalWidget extends StatefulWidget {
  const FlNutritionalPlanGoalWidget({
    super.key,
    required NutritionalPlan nutritionalPlan,
  }) : _nutritionalPlan = nutritionalPlan;

  final NutritionalPlan _nutritionalPlan;

  @override
  State<StatefulWidget> createState() => FlNutritionalPlanGoalWidgetState();
}

// * fl_chart doesn't support horizontal bar charts yet.
//   see https://github.com/imaNNeo/fl_chart/issues/113
//   even if it did, i doubt it would let us put text between the gauges/bars
// * LinearProgressIndicator has no way to visualize going beyond 100%, or
//   using multiple colors to show multiple components such as surplus, deficit
// * here we draw our own simple gauges that can go beyond 100%,
//   and support multiple segments
class FlNutritionalPlanGoalWidgetState extends State<FlNutritionalPlanGoalWidget> {
  // normWidth is the width representing 100% completion
  // note that if val > plan, we will draw beyond this width
  // therefore, caller must set this width to accommodate surpluses.
  // why don't we just handle this inside this function? because it might be
  // *another* gauge that's in surplus and we want to have consistent widths
  // between all gauges
  Widget _diyGauge(
    BuildContext context,
    double normWidth,
    double? plan,
    double val,
  ) {
    Container segment(double width, Color color) {
      return Container(
        height: 16,
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15.0),
        ),
      );
    }

    // paint a simple bar
    if (plan == null || val == plan) {
      return segment(normWidth, LIST_OF_COLORS8[0]);
    }

    // paint a surplus
    if (val > plan) {
      return Stack(children: [
        segment(normWidth * val / plan, COLOR_SURPLUS),
        segment(normWidth, LIST_OF_COLORS8[0]),
      ]);
    }

    // paint a deficit
    return Stack(children: [
      segment(normWidth, Theme.of(context).colorScheme.surface),
      segment(normWidth * val / plan, LIST_OF_COLORS8[0]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget._nutritionalPlan;
    final goals = plan.nutritionalGoals;
    final today = plan.loggedNutritionalValuesToday;

    return LayoutBuilder(builder: (context, constraints) {
      // if any of the bars goes over 100%, find the one that goes over the most
      // that one needs the most horizontal space to show how much it goes over,
      // and therefore reduces the width of "100%" the most, and this width we want
      // to be consistent for all other bars.
      // if none goes over, 100% means fill all available space
      final maxVal = [
        1.0,
        if (goals.energy != null && goals.energy! > 0) today.energy / goals.energy!,
        if (goals.protein != null && goals.protein! > 0) today.protein / goals.protein!,
        if (goals.carbohydrates != null && goals.carbohydrates! > 0)
          today.carbohydrates / goals.carbohydrates!,
        if (goals.fat != null && goals.fat! > 0) today.fat / goals.fat!,
        if (goals.fiber != null && goals.fiber! > 0) today.fiber / goals.fiber!,
      ].reduce(max);

      final normWidth = constraints.maxWidth / maxVal;

      String fmtMacro(String name, double today, double? goal, String unit) {
        return '$name: ${today.toStringAsFixed(0)}${goal == null ? '' : ' / ${goal.toStringAsFixed(0)}'} $unit';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fmtMacro(
            AppLocalizations.of(context).energy,
            today.energy,
            goals.energy,
            AppLocalizations.of(context).kcal,
          )),
          const SizedBox(height: 2),
          _diyGauge(context, normWidth, goals.energy, today.energy),
          const SizedBox(height: 8),
          Text(fmtMacro(
            AppLocalizations.of(context).protein,
            today.protein,
            goals.protein,
            AppLocalizations.of(context).g,
          )),
          const SizedBox(height: 2),
          _diyGauge(context, normWidth, goals.protein, today.protein),
          const SizedBox(height: 8),
          Text(fmtMacro(
            AppLocalizations.of(context).carbohydrates,
            today.carbohydrates,
            goals.carbohydrates,
            AppLocalizations.of(context).g,
          )),
          const SizedBox(height: 2),
          _diyGauge(
            context,
            normWidth,
            goals.carbohydrates,
            today.carbohydrates,
          ),
          const SizedBox(height: 8),
          Text(fmtMacro(
            AppLocalizations.of(context).fat,
            today.fat,
            goals.fat,
            AppLocalizations.of(context).g,
          )),
          const SizedBox(height: 2),
          _diyGauge(context, normWidth, goals.fat, today.fat),
          // optionally display the advanced macro goals:
          if (goals.fiber != null)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              Text(fmtMacro(
                AppLocalizations.of(context).fiber,
                today.fiber,
                goals.fiber,
                AppLocalizations.of(context).g,
              )),
              const SizedBox(height: 2),
              _diyGauge(context, normWidth, goals.fiber, today.fiber),
            ]),
        ],
      );
    });
  }
}

class NutritionData {
  final String name;
  final double value;

  const NutritionData(this.name, this.value);
}

class FlNutritionalPlanPieChartWidget extends StatefulWidget {
  final NutritionalValues nutritionalValues;

  const FlNutritionalPlanPieChartWidget(this.nutritionalValues);

  @override
  State<StatefulWidget> createState() => FlNutritionalPlanPieChartState();
}

class FlNutritionalPlanPieChartState extends State<FlNutritionalPlanPieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(height: 18),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: showingSections(),
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (AppLocalizations.of(context).protein, LIST_OF_COLORS3[1]),
            (AppLocalizations.of(context).carbohydrates, LIST_OF_COLORS3[0]),
            (AppLocalizations.of(context).fat, LIST_OF_COLORS3[2]),
          ]
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Indicator(color: e.$2, text: e.$1, isSquare: true),
                  ))
              .toList(),
        ),
        const SizedBox(width: 28),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      (0, LIST_OF_COLORS3[1], widget.nutritionalValues.protein),
      (1, LIST_OF_COLORS3[0], widget.nutritionalValues.carbohydrates),
      (2, LIST_OF_COLORS3[2], widget.nutritionalValues.fat),
    ].map((e) {
      final isTouched = e.$1 == touchedIndex;
      final radius = isTouched ? 92.0 : 80.0;

      return PieChartSectionData(
        color: e.$2,
        value: e.$3,
        title: '${e.$3.toStringAsFixed(0)}g',
        titlePositionPercentageOffset: 0.5,
        radius: radius,
      );
    }).toList();
  }
}

/// Shows results vs plan of common macros, for today and last 7 days, as barchart
class NutritionalDiaryChartWidgetFl extends StatefulWidget {
  const NutritionalDiaryChartWidgetFl({
    super.key,
    required NutritionalPlan nutritionalPlan,
  }) : _nutritionalPlan = nutritionalPlan;

  final NutritionalPlan _nutritionalPlan;

  @override
  State<StatefulWidget> createState() => NutritionalDiaryChartWidgetFlState();
}

class NutritionalDiaryChartWidgetFlState extends State<NutritionalDiaryChartWidgetFl> {
  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    final String text = switch (value.toInt()) {
      0 => AppLocalizations.of(context).protein,
      1 => AppLocalizations.of(context).carbohydrates,
      2 => AppLocalizations.of(context).sugars,
      3 => AppLocalizations.of(context).fat,
      4 => AppLocalizations.of(context).saturatedFat,
      5 => AppLocalizations.of(context).fiber,
      _ => '',
    };
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        AppLocalizations.of(context).gValue(meta.formattedValue),
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planned = widget._nutritionalPlan.nutritionalGoals;
    final loggedToday = widget._nutritionalPlan.loggedNutritionalValuesToday;
    final logged7DayAvg = widget._nutritionalPlan.loggedNutritionalValues7DayAvg;

    final [colorPlanned, colorLoggedToday, colorLogged7Day] = LIST_OF_COLORS3;

    BarChartGroupData barchartGroup(
      int x,
      double barsSpace,
      double barsWidth,
      String prop,
    ) {
      final plan = planned.prop(prop);

      BarChartRodData barChartRodData(double? plan, double val, Color color) {
        // paint a simple bar
        if (plan == null || val == plan) {
          return BarChartRodData(toY: val, color: color, width: barsWidth);
        }

        // paint a surplus
        if (val > plan) {
          return BarChartRodData(
            toY: val,
            color: colorLoggedToday,
            width: barsWidth,
            rodStackItems: [
              BarChartRodStackItem(0, plan, color),
              BarChartRodStackItem(plan, val, COLOR_SURPLUS),
            ],
          );
        }

        // paint a deficit
        return BarChartRodData(
          toY: plan,
          color: colorLoggedToday,
          width: barsWidth,
          rodStackItems: [
            BarChartRodStackItem(0, val, color),
            BarChartRodStackItem(val, plan, colorPlanned),
          ],
        );
      }

      return BarChartGroupData(
        x: x,
        barsSpace: barsSpace,
        barRods: [
          barChartRodData(plan, loggedToday.prop(prop), colorLoggedToday),
          barChartRodData(plan, logged7DayAvg.prop(prop), colorLogged7Day),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final barsSpace = 6.0 * constraints.maxWidth / 400;
        final barsWidth = 12.0 * constraints.maxWidth / 400;
        return Column(
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: bottomTitles,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    checkToShowHorizontalLine: (value) => value % 10 == 0,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: Colors.black,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  groupsSpace: 30,
                  barGroups: [
                    barchartGroup(0, barsSpace, barsWidth, 'protein'),
                    barchartGroup(1, barsSpace, barsWidth, 'carbohydrates'),
                    barchartGroup(
                      2,
                      barsSpace,
                      barsWidth,
                      'carbohydratesSugar',
                    ),
                    barchartGroup(3, barsSpace, barsWidth, 'fat'),
                    barchartGroup(4, barsSpace, barsWidth, 'fatSaturated'),
                    if (widget._nutritionalPlan.nutritionalGoals.fiber != null)
                      barchartGroup(5, barsSpace, barsWidth, 'fiber'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 25, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (AppLocalizations.of(context).deficit, colorPlanned),
                  (AppLocalizations.of(context).surplus, COLOR_SURPLUS),
                  (AppLocalizations.of(context).today, colorLoggedToday),
                  (AppLocalizations.of(context).weekAverage, colorLogged7Day),
                ]
                    .map(
                      (e) => Indicator(
                        color: e.$2,
                        text: e.$1,
                        isSquare: true,
                        marginRight: 0,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Barchart widget for what's logged today, energy and macros
class MealDiaryBarChartWidget extends StatefulWidget {
  const MealDiaryBarChartWidget({
    super.key,
    required NutritionalValues logged,
    required NutritionalValues planned,
  })  : _logged = logged,
        _planned = planned;

  final NutritionalValues _logged;
  final NutritionalValues _planned;

  @override
  State<StatefulWidget> createState() => MealDiaryBarChartWidgetState();
}

class MealDiaryBarChartWidgetState extends State<MealDiaryBarChartWidget> {
  Widget bottomTitles(double value, TitleMeta meta) {
    final String text = switch (value.toInt()) {
      0 => AppLocalizations.of(context).protein,
      1 => AppLocalizations.of(context).carbohydrates,
      2 => AppLocalizations.of(context).fat,
      3 => AppLocalizations.of(context).energy,
      _ => '',
    };
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) => SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          AppLocalizations.of(context).percentValue(value.toStringAsFixed(0)),
          style: const TextStyle(fontSize: 10),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.5,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barsSpace = 1.0 * constraints.maxWidth / 400;
            final barsWidth = 10.0 * constraints.maxWidth / 400;
            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: bottomTitles,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: leftTitles,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Colors.black,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                groupsSpace: 60,
                // groupsSpace: barsSpace,
                barGroups: [
                  BarChartGroupData(
                    x: 3,
                    barsSpace: barsSpace,
                    barRods: [
                      BarChartRodData(
                        toY: widget._logged.energy / widget._planned.energy * 100,
                        color: LIST_OF_COLORS3.first,
                        width: barsWidth,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 0,
                    barsSpace: barsSpace,
                    barRods: [
                      BarChartRodData(
                        toY: widget._logged.protein / widget._planned.protein * 100,
                        color: LIST_OF_COLORS3.first,
                        width: barsWidth,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barsSpace: barsSpace,
                    barRods: [
                      BarChartRodData(
                        toY: widget._logged.carbohydrates / widget._planned.carbohydrates * 100,
                        color: LIST_OF_COLORS3.first,
                        width: barsWidth,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barsSpace: barsSpace,
                    barRods: [
                      BarChartRodData(
                        toY: widget._logged.fat / widget._planned.fat * 100,
                        color: LIST_OF_COLORS3.first,
                        width: barsWidth,
                      ),
                    ],
                  ),
                ],
                // barGroups: getData(barsWidth, barsSpace),
              ),
            );
          },
        ),
      ),
    );
  }
}
