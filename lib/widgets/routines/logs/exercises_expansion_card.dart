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
import 'package:wger/helpers/i18n.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/trophies/user_trophy.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session_api.dart';

class ExercisesCard extends StatelessWidget {
  final WorkoutSessionApi session;
  final List<UserTrophy> userPrTrophies;

  const ExercisesCard(this.session, this.userPrTrophies, {super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = session.exercises;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).exercises,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...exercises.map((exercise) {
              final logs = session.logs.where((log) => log.exerciseId == exercise.id).toList();
              return _ExerciseExpansionTile(
                exercise: exercise,
                logs: logs,
                userPrTrophies: userPrTrophies,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ExerciseExpansionTile extends StatelessWidget {
  const _ExerciseExpansionTile({
    required this.exercise,
    required this.logs,
    required this.userPrTrophies,
  });

  final List<UserTrophy> userPrTrophies;
  final Exercise exercise;
  final List<Log> logs;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final i18n = AppLocalizations.of(context);

    final topSet = logs.isEmpty
        ? null
        : logs.reduce((a, b) => (a.weight ?? 0) > (b.weight ?? 0) ? a : b);
    final topSetWeight = topSet?.weight?.toStringAsFixed(0) ?? 'N/A';
    final topSetWeightUnit = topSet?.weightUnitObj != null
        ? getServerStringTranslation(topSet!.weightUnitObj!.name, context)
        : '';
    return ExpansionTile(
      // leading: const Icon(Icons.fitness_center),
      title: Text(exercise.getTranslation(languageCode).name, style: theme.textTheme.titleMedium),
      subtitle: Text(i18n.topSet('$topSetWeight $topSetWeightUnit')),
      children: logs.map((log) => _SetDataRow(log: log, userPrTrophies: userPrTrophies)).toList(),
    );
  }
}

class _SetDataRow extends StatelessWidget {
  const _SetDataRow({required this.log, required this.userPrTrophies});

  final Log log;
  final List<UserTrophy> userPrTrophies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 5,
        children: [
          Text(
            log.repTextNoNl(context),
            style: theme.textTheme.bodyMedium,
          ),
          if (userPrTrophies.any((trophy) => trophy.contextData?.logId == log.id))
            Icon(Icons.emoji_events, color: theme.colorScheme.primary, size: 20),
          // if (log.volume() > 0)
          //   Text(
          //     '${log.volume().toStringAsFixed(0)} ${getServerStringTranslation(log.weightUnitObj!.name, context)}',
          //     style: theme.textTheme.bodyMedium,
          //   ),
        ],
      ),
    );
  }
}
