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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/colors.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/widgets/measurements/charts.dart';

class NutritionData {
  final String name;
  final double value;

  NutritionData(this.name, this.value);
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
        const SizedBox(
          height: 18,
        ),
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
                borderData: FlBorderData(
                  show: false,
                ),
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
            Indicator(
              color: LIST_OF_COLORS3[0],
              text: AppLocalizations.of(context).carbohydrates,
              isSquare: true,
            ),
            const SizedBox(
              height: 4,
            ),
            Indicator(
              color: LIST_OF_COLORS3[1],
              text: AppLocalizations.of(context).protein,
              isSquare: true,
            ),
            const SizedBox(
              height: 4,
            ),
            Indicator(
              color: LIST_OF_COLORS3[2],
              text: AppLocalizations.of(context).fat,
              isSquare: true,
            ),
          ],
        ),
        const SizedBox(
          width: 28,
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 92.0 : 80.0;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: LIST_OF_COLORS3[0],
            value: widget.nutritionalValues.carbohydrates,
            title: '${widget.nutritionalValues.carbohydrates.toStringAsFixed(0)}g',
            titlePositionPercentageOffset: 0.5,
            radius: radius,
            titleStyle: const TextStyle(color: Colors.white70),
          );

        case 1:
          return PieChartSectionData(
            color: LIST_OF_COLORS3[1],
            value: widget.nutritionalValues.protein,
            title: '${widget.nutritionalValues.protein.toStringAsFixed(0)}g',
            titlePositionPercentageOffset: 0.5,
            radius: radius,
          );
        case 2:
          return PieChartSectionData(
            color: LIST_OF_COLORS3[2],
            value: widget.nutritionalValues.fat,
            title: '${widget.nutritionalValues.fat.toStringAsFixed(0)}g',
            titlePositionPercentageOffset: 0.5,
            radius: radius,
          );

        default:
          throw Error();
      }
    });
  }
}

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
    final planned = widget._nutritionalPlan.plannedNutritionalValues;
    final loggedToday = widget._nutritionalPlan.loggedNutritionalValuesToday;
    final logged7DayAvg = widget._nutritionalPlan.loggedNutritionalValues7DayAvg;

    final [colorPlanned, colorLoggedToday, colorLogged7Day] = LIST_OF_COLORS3;

    BarChartGroupData barchartGroup(int x, double barsSpace, double barsWidth, String prop) {
      final plan = planned.prop(prop);

      BarChartRodData barChartRodData(double plan, double val, Color color) {
        // paint a simple bar
        if (plan == 0 || val == plan) {
          return BarChartRodData(
            toY: val,
            color: color,
            width: barsWidth,
          );
        }

        // paint a surplus
        if (val > plan) {
          return BarChartRodData(
            toY: val,
            color: colorLoggedToday,
            width: barsWidth,
            rodStackItems: [
              BarChartRodStackItem(0, plan, color),
              BarChartRodStackItem(plan, val, Colors.red),
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

    return AspectRatio(
      aspectRatio: 1.66,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barsSpace = 6.0 * constraints.maxWidth / 400;
            final barsWidth = 12.0 * constraints.maxWidth / 400;
            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                barTouchData: BarTouchData(
                  enabled: false,
                ),
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
                borderData: FlBorderData(
                  show: false,
                ),
                groupsSpace: 30,
                barGroups: [
                  barchartGroup(0, barsSpace, barsWidth, 'protein'),
                  barchartGroup(1, barsSpace, barsWidth, 'carbohydrates'),
                  barchartGroup(2, barsSpace, barsWidth, 'carbohydratesSugar'),
                  barchartGroup(3, barsSpace, barsWidth, 'fat'),
                  barchartGroup(4, barsSpace, barsWidth, 'fatSaturated'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

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
    String text;
    switch (value.toInt()) {
      case 0:
        text = AppLocalizations.of(context).protein;
        break;
      case 1:
        text = AppLocalizations.of(context).carbohydrates;
        break;
      case 2:
        text = AppLocalizations.of(context).fat;
        break;
      case 3:
        text = AppLocalizations.of(context).energy;
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: const TextStyle(fontSize: 10),
      ),
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
                barTouchData: BarTouchData(
                  enabled: false,
                ),
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

class FlNutritionalDiaryChartWidget extends StatefulWidget {
  final NutritionalPlan _nutritionalPlan;

  const FlNutritionalDiaryChartWidget({
    super.key,
    required NutritionalPlan nutritionalPlan,
  }) : _nutritionalPlan = nutritionalPlan;

  final Color barColor = Colors.red;
  final Color touchedBarColor = Colors.deepOrange;

  @override
  State<StatefulWidget> createState() => FlNutritionalDiaryChartWidgetState();
}

class FlNutritionalDiaryChartWidgetState extends State<FlNutritionalDiaryChartWidget> {
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.66,
      child: BarChart(
        mainBarData(),
        swapAnimationDuration: animDuration,
      ),
    );
  }

  List<DateTime> getDatesBetween(DateTime startDate, DateTime endDate) {
    final List<DateTime> dateList = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      dateList.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dateList;
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 1.5,
    List<int> showTooltips = const [],
  }) {
    barColor ??= widget.barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? widget.touchedBarColor : barColor,
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.black54)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            // color: Colors.black,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() {
    final logEntries = widget._nutritionalPlan.logEntriesValues;
    final List<BarChartGroupData> out = [];
    final dateList = getDatesBetween(logEntries.keys.first, logEntries.keys.last);

    for (final date in dateList.reversed) {
      out.add(
        makeGroupData(
          date.millisecondsSinceEpoch,
          logEntries.containsKey(date) ? logEntries[date]!.energy : 0,
          isTouched: date.millisecondsSinceEpoch == touchedIndex,
        ),
      );
    }

    return out;
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    const style = TextStyle(
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        AppLocalizations.of(context).kcalValue(meta.formattedValue),
        style: style,
      ),
    );
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final date = DateTime.fromMillisecondsSinceEpoch(group.x);

            return BarTooltipItem(
              '${DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(date)}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: AppLocalizations.of(context).kcalValue((rod.toY - 1).toStringAsFixed(0)),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: leftTitles,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Colors.grey,
          strokeWidth: 1,
        ),
        drawVerticalLine: false,
      ),
      barGroups: showingGroups(),
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
      animDuration + const Duration(milliseconds: 50),
    );
  }
}
