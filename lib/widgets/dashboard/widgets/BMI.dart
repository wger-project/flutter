import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/widgets/measurements/charts.dart';

// Helper for BMI colors (English)
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

    // Get current BMI
    final newestWeight = weightProvider.getNewestEntry()?.weight?.toDouble();
    final currentBmi = profile.calculateBmi(weightOverride: newestWeight);
    final (bmiColor, bmiText) = getBmiCategory(currentBmi);

    // Calculate history for the chart
    final spots = <FlSpot>[];
    double minBmi = 100;
    double maxBmi = 0;

    // Take last 7 entries for the curve
    final entries = weightProvider.items.take(7).toList().reversed;

    int index = 0;
    for (var entry in entries) {
      final rawBmi = profile.calculateBmi(weightOverride: entry.weight.toDouble());

      if (rawBmi > 0) {
        // Round to 1 decimal place
        final bmi = double.parse(rawBmi.toStringAsFixed(1));

        spots.add(FlSpot(index.toDouble(), bmi));

        if (bmi < minBmi) minBmi = bmi;
        if (bmi > maxBmi) maxBmi = bmi;
      }
      index++;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.chartLine), // Icon
                const SizedBox(width: 10),
                Text(
                  "BMI History", // ENGLISH
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Chart & Value Row
            Row(
              children: [
                // Left: Chart
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 120,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: bmiColor, // Line color matches current status
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                        minY: (minBmi - 2).clamp(0, 100),
                        maxY: (maxBmi + 2).clamp(0, 100),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // Right: Current Value
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Current BMI", // ENGLISH
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        currentBmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: bmiColor,
                        ),
                      ),
                      Text(
                        bmiText, // English text from helper
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: bmiColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
