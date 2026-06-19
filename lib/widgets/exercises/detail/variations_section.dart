/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercises_notifier.dart';
import 'package:wger/widgets/exercises/list_tile.dart';

class VariationsSection extends ConsumerWidget {
  final Exercise exercise;

  const VariationsSection({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (exercise.variationGroup == null) {
      return const SizedBox.shrink();
    }

    final exerciseState = ref.watch(exercisesProvider).value ?? const ExerciseState([]);
    final variations = exerciseState.findByVariationGroup(
      exercise.variationGroup,
      exerciseIdToExclude: exercise.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).variations,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (variations.isEmpty)
          const Text('-/-')
        else
          ...variations.map((e) => ExerciseListTile(exercise: e)),
        const SizedBox(height: 9),
      ],
    );
  }
}
