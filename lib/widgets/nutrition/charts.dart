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

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wger/helpers/colors.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/charts.dart';

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
              text: AppLocalizations.of(context).fat,
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
              text: AppLocalizations.of(context).carbohydrates,
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
    final colors = generateChartColors(3).iterator;

    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 92.0 : 80.0;
      colors.moveNext();

      switch (i) {
        case 0:
          return PieChartSectionData(
              color: colors.current,
              value: widget.nutritionalValues.fat,
              title: '${widget.nutritionalValues.fat.toStringAsFixed(0)}g',
              titlePositionPercentageOffset: 0.5,
              radius: radius,
              titleStyle: const TextStyle(color: Colors.white70));
        case 1:
          return PieChartSectionData(
            color: colors.current,
            value: widget.nutritionalValues.protein,
            title: '${widget.nutritionalValues.protein.toStringAsFixed(0)}g',
            titlePositionPercentageOffset: 0.5,
            radius: radius,
          );
        case 2:
          return PieChartSectionData(
            color: colors.current,
            value: widget.nutritionalValues.carbohydrates,
            title: '${widget.nutritionalValues.carbohydrates.toStringAsFixed(0)}g',
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
    Key? key,
    required NutritionalPlan nutritionalPlan,
  })  : _nutritionalPlan = nutritionalPlan,
        super(key: key);

  final NutritionalPlan _nutritionalPlan;

  @override
  State<StatefulWidget> createState() => NutritionalDiaryChartWidgetFlState();
}

class NutritionalDiaryChartWidgetFlState extends State<NutritionalDiaryChartWidgetFl> {
  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = AppLocalizations.of(context).protein;
        break;
      case 1:
        text = AppLocalizations.of(context).carbohydrates;
        break;
      case 2:
        text = AppLocalizations.of(context).sugars;
        break;
      case 3:
        text = AppLocalizations.of(context).fat;
        break;
      case 4:
        text = AppLocalizations.of(context).saturatedFat;
        break;

      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
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
        meta.formattedValue,
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NutritionalValues planned = widget._nutritionalPlan.nutritionalValues;
    final NutritionalValues loggedToday = widget._nutritionalPlan.nutritionalValuesToday;
    final NutritionalValues logged7DayAvg = widget._nutritionalPlan.nutritionalValues7DayAvg;

    final colorPlanned = LIST_OF_COLORS3[0];
    final colorLoggedToday = LIST_OF_COLORS3[1];
    final colorLogged7Day = LIST_OF_COLORS3[2];

    return AspectRatio(
      aspectRatio: 1.66,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barsSpace = 4.0 * constraints.maxWidth / 400;
            final barsWidth = 8.0 * constraints.maxWidth / 400;
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
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 10 == 0,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.black,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                groupsSpace: 30,
                // groupsSpace: barsSpace,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barsSpace: barsSpace,
                    barRods: [
                      BarChartRodData(
                        toY: planned.protein,
                        color: colorPlanned,
                        width: barsWidth,
                      ),
                      BarChartRodData(
                        toY: loggedToday.protein,
                        color: colorLoggedToday,
                        width: barsWidth,
                      ),
                      BarChartRodData(
                        toY: logged7DayAvg.protein,
                        color: colorLogged7Day,
                        width: barsWidth,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barsSpace: barsSpace,
                    barRods: [
                      BarChartRodData(
                        toY: planned.carbohydrates,
                        color: colorPlanned,
                        width: barsWidth,
                      ),
                      BarChartRodData(
                        toY: loggedToday.carbohydrates,
                        color: colorLoggedToday,
                        width: barsWidth,
                      ),
                      BarChartRodData(
                        toY: logged7DayAvg.carbohydrates,
                        color: colorLogged7Day,
                        width: barsWidth,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barsSpace: barsSpace,
                    barRods: [
                      BarChartRodData(
                        toY: planned.carbohydratesSugar,
                        color: colorPlanned,
                        width: barsWidth,
                      ),
                      BarChartRodData(
                        toY: loggedToday.carbohydratesSugar,
                        color: colorLoggedToday,
                        width: barsWidth,
                      ),
                      BarChartRodData(
                        toY: logged7DayAvg.carbohydratesSugar,
                        color: colorLogged7Day,
                        width: barsWidth,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barsSpace: barsSpace,
                    barRods: [
                      BarChartRodData(
                        toY: planned.fat,
                        color: colorPlanned,
                        width: barsWidth,
                      ),
                      BarChartRodData(
                        toY: loggedToday.fat,
                        color: colorLoggedToday,
                        width: barsWidth,
                      ),
                      BarChartRodData(
                        toY: logged7DayAvg.fat,
                        color: colorLogged7Day,
                        width: barsWidth,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barsSpace: barsSpace,
                    barRods: [
                      BarChartRodData(
                        toY: planned.fatSaturated,
                        color: colorPlanned,
                        width: barsWidth,
                      ),
                      BarChartRodData(
                        toY: loggedToday.fatSaturated,
                        color: colorLoggedToday,
                        width: barsWidth,
                      ),
                      BarChartRodData(
                        toY: logged7DayAvg.fatSaturated,
                        color: colorLogged7Day,
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

class NutritionalDiaryChartWidget extends StatelessWidget {
  const NutritionalDiaryChartWidget({
    Key? key,
    required NutritionalPlan nutritionalPlan,
  })  : _nutritionalPlan = nutritionalPlan,
        super(key: key);

  final NutritionalPlan _nutritionalPlan;

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      [
        charts.Series<List<dynamic>, DateTime>(
          id: 'NutritionDiary',
          colorFn: (datum, index) => wgerChartSecondaryColor,
          domainFn: (datum, index) => datum[1],
          measureFn: (datum, index) => datum[0].energy,
          data: _nutritionalPlan.logEntriesValues.keys
              .map((e) => [_nutritionalPlan.logEntriesValues[e], e])
              .toList(),
        )
      ],
      defaultRenderer: charts.BarRendererConfig<DateTime>(),
      behaviors: [
        charts.RangeAnnotation([
          charts.LineAnnotationSegment(
            _nutritionalPlan.nutritionalValues.energy,
            charts.RangeAnnotationAxisType.measure,
            strokeWidthPx: 2,
            color: charts.MaterialPalette.gray.shade600,
          ),
        ]),
      ],
    );
  }
}
