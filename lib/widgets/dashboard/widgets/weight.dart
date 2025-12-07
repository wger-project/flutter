/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/helpers.dart';
import 'package:wger/widgets/weight/forms.dart';

// Helper function for BMI color & category
(Color, String) getBmiInfo(double bmi) {
  if (bmi < 18.5) {
    return (Colors.lightBlueAccent, "Underweight");
  } else if (bmi < 25.0) {
    return (Colors.greenAccent, "Normal weight");
  } else if (bmi < 30.0) {
    return (Colors.orangeAccent, "Overweight");
  } else if (bmi < 35.0) {
    return (Colors.deepOrangeAccent, "Obesity Class I");
  } else if (bmi < 40.0) {
    return (Colors.redAccent, "Obesity Class II");
  } else {
    return (Colors.red, "Obesity Class III");
  }
}

class DashboardWeightWidget extends StatelessWidget {
  const DashboardWeightWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final weightProvider = context.watch<BodyWeightProvider>();

    // Current data for BMI calculation (Info text)
    final newestEntry = weightProvider.getNewestEntry();
    final currentWeight = newestEntry?.weight?.toDouble();

    // Check unit system
    final bool isMetric = profile?.isMetric ?? true;

    // Chart data (Weight only)
    final chartEntries = weightProvider.items
        .map((e) => MeasurementChartEntry(e.weight, e.date))
        .toList();

    final (entriesAll, entries7dAvg) = sensibleRange(chartEntries);

    return Card(
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
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),

          Column(
            children: [
              if (weightProvider.items.isNotEmpty)
                Column(
                  children: [
                    // The Chart (only wight)
                    SizedBox(
                      height: 200,
                      child: MeasurementChartWidgetFl(
                        entriesAll,
                        weightUnit(isMetric, context),
                        avgs: entries7dAvg,
                      ),
                    ),

                    // Change (e.g. -2kg)
                    if (entries7dAvg.isNotEmpty)
                      MeasurementOverallChangeWidget(
                        entries7dAvg.first,
                        entries7dAvg.last,
                        weightUnit(isMetric, context),
                      ),

                    // --- Small BMI Info (Optional) ---
                    // Shows only the current value centered
                    if (profile != null)
                      Builder(builder: (context) {
                        final bmi = profile.calculateBmi(weightOverride: currentWeight);

                        if (bmi > 0) {
                          final (bmiColor, bmiCategory) = getBmiInfo(bmi);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("AKTUELLE BMI WERTE",
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)
                                ),
                                SizedBox(height: 8),
                                Text(
                                  bmi.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: bmiColor,
                                  ),
                                ),
                                Text(
                                  bmiCategory,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: bmiColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    // --- ENDE BMI Info ---

                    Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(
                            AppLocalizations.of(context).goToDetailPage,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(WeightScreen.routeName);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              FormScreen.routeName,
                              arguments: FormScreenArguments(
                                AppLocalizations.of(context).newEntry,
                                WeightForm(
                                  weightProvider.getNewestEntry()?.copyWith(
                                    id: null,
                                    date: DateTime.now(),
                                  ),
                                ),
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
    );
  }
}
