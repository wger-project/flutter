/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2025 wger Team
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

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/log.dart';

class MuscleGroup {
  final String name;
  final double percentage;
  final Color color;

  MuscleGroup(this.name, this.percentage, this.color);
}

class MuscleGroupsCard extends StatelessWidget {
  final List<Log> logs;

  const MuscleGroupsCard(this.logs, {super.key});

  List<MuscleGroup> _getMuscleGroups(BuildContext context) {
    final allMuscles = logs
        .expand((log) => [...log.exercise.muscles, ...log.exercise.musclesSecondary])
        .toList();
    if (allMuscles.isEmpty) {
      return [];
    }
    final muscleCounts = allMuscles.groupListsBy((muscle) => muscle.nameTranslated(context));
    final total = allMuscles.length;

    int colorIndex = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.deepOrange,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
      Colors.lime,
      Colors.amber,
      Colors.lightGreen,
      Colors.deepPurple,
    ];

    return muscleCounts.entries.map((entry) {
      final percentage = (entry.value.length / total) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return MuscleGroup(entry.key, percentage, color);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final muscles = _getMuscleGroups(context);
    final theme = Theme.of(context);
    final i18n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              i18n.muscles,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: muscles.map((muscle) {
                    return PieChartSectionData(
                      color: muscle.color,
                      value: muscle.percentage,
                      title: i18n.percentValue(muscle.percentage.toStringAsFixed(0)),
                      radius: 50,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: muscles.map((muscle) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: muscle.color,
                    ),
                    const SizedBox(width: 8),
                    Text(muscle.name),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
