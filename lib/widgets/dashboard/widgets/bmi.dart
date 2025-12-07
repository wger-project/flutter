import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/widgets/measurements/charts.dart';

(Color, String) getBmiCategory(double bmi) {
  if (bmi < 18.5) return (Colors.lightBlueAccent, "Underweight");
  if (bmi < 25.0) return (Colors.greenAccent, "Normal weight");
  if (bmi < 30.0) return (Colors.orangeAccent, "Overweight");
  if (bmi < 35.0) return (Colors.deepOrangeAccent, "Obesity I");
  if (bmi < 40.0) return (Colors.redAccent, "Obesity II");
  return (Colors.red, "Obesity III");
}

class DashboardBmiWidget extends StatelessWidget {
  const DashboardBmiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final weightProvider = context.watch<BodyWeightProvider>();

    if (profile == null) return const SizedBox.shrink();

    final newestWeight = weightProvider.getNewestEntry()?.weight?.toDouble();
    final currentBmi = profile.calculateBmi(weightOverride: newestWeight);
    final (bmiColor, bmiText) = getBmiCategory(currentBmi);

    final spots = <FlSpot>[];
    final dates = <DateTime>[];
    double minBmi = 100;
    double maxBmi = 0;

    final entries = weightProvider.items.take(7).toList().reversed.toList();

    int index = 0;
    for (var entry in entries) {
      final rawBmi = profile.calculateBmi(weightOverride: entry.weight.toDouble());

      if (rawBmi > 0) {
        final bmi = double.parse(rawBmi.toStringAsFixed(1));
        spots.add(FlSpot(index.toDouble(), bmi));
        dates.add(entry.date);

        if (bmi < minBmi) minBmi = bmi;
        if (bmi > maxBmi) maxBmi = bmi;
      }
      index++;
    }

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              "BMI History",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            leading: FaIcon(
              FontAwesomeIcons.chartLine,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: LineChart(
                    LineChartData(
                      // --- NEU: Interaktiver Tooltip ---
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              // Hole das passende Datum zum Punkt
                              final date = dates[spot.x.toInt()];
                              final dateStr = DateFormat('dd.MM.').format(date);

                              return LineTooltipItem(
                                '${spot.y}\n', // BMI Wert
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                                children: [
                                  TextSpan(
                                    text: dateStr, // Datum drunter
                                    style: const TextStyle(
                                      color: Colors.white70, // Etwas blasser
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                          // Farbe des Tooltips anpassen (dunkelgrau passt meistens gut)
                          // tooltipBgColor: Colors.blueGrey, // Veraltet in neueren Versionen, nutzen wir default
                        ),
                      ),
                      // ---------------------------------

                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final int i = value.toInt();
                              if (i >= 0 && i < dates.length) {
                                // Smart Date Logic:
                                // 1. Check total range
                                final bool showYear = dates.last.difference(dates.first).inDays > 365;

                                // 2. Formatter
                                final formatter = showYear ? DateFormat('MM/yy') : DateFormat('dd.MM');

                                // 3. Show Strategy (First, Last, Middle)
                                if (i == 0 || i == dates.length - 1 || (dates.length > 4 && i == (dates.length / 2).round())) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      formatter.format(dates[i]),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context).textTheme.bodySmall?.color
                                      ),
                                    ),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: bmiColor,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                      minY: (minBmi - 2).clamp(0, 100),
                      maxY: (maxBmi + 2).clamp(0, 100),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Current: ",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      currentBmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: bmiColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bmiColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: bmiColor),
                      ),
                      child: Text(
                        bmiText,
                        style: TextStyle(
                          color: bmiColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
