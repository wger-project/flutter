/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/widgets/exercises/images.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';

class GymModeOptions extends ConsumerStatefulWidget {
  const GymModeOptions({super.key});

  @override
  ConsumerState<GymModeOptions> createState() => _GymModeOptionsState();
}

class _GymModeOptionsState extends ConsumerState<GymModeOptions> {
  bool _showOptions = false;

  @override
  Widget build(BuildContext context) {
    final gymState = ref.watch(gymStateProvider);
    final gymNotifier = ref.watch(gymStateProvider.notifier);
    final i18n = AppLocalizations.of(context);

    return Column(
      children: [
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(i18n.gymModeShowExercises),
                  value: gymState.showExercisePages,
                  onChanged: (value) => gymNotifier.setShowExercisePages(value),
                ),
                SwitchListTile(
                  title: Text(i18n.gymModeShowTimer),
                  value: gymState.showTimerPages,
                  onChanged: (value) => gymNotifier.setShowTimerPages(value),
                ),
              ],
            ),
          ),
          crossFadeState: _showOptions ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),

        ListTile(
          title: Text(i18n.settingsTitle),
          leading: const Icon(Icons.settings),
          onTap: () => setState(() => _showOptions = !_showOptions),
        ),
      ],
    );
  }
}

class StartPage extends ConsumerWidget {
  final PageController _controller;

  const StartPage(this._controller);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayDataDisplay = ref.watch(gymStateProvider).dayDataDisplay;

    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).todaysWorkout,
          _controller,
          showEndWorkoutButton: false,
        ),

        Expanded(
          child: ListView(
            children: [
              if (dayDataDisplay.day!.isSpecialType)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      '${dayDataDisplay.day!.type.name.toUpperCase()}\n${dayDataDisplay.day!.type.i18Label(AppLocalizations.of(context))}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ...dayDataDisplay.slots
                  .expand((slot) => slot.setConfigs)
                  .fold<Map<Exercise, List<String>>>({}, (acc, entry) {
                    acc.putIfAbsent(entry.exercise, () => []).add(entry.textReprWithType);
                    return acc;
                  })
                  .entries
                  .map((entry) {
                    final exercise = entry.key;
                    return Column(
                      children: [
                        ListTile(
                          leading: SizedBox(
                            width: 45,
                            child: ExerciseImageWidget(image: exercise.getMainImage),
                          ),
                          title: Text(
                            exercise
                                .getTranslation(Localizations.localeOf(context).languageCode)
                                .name,
                          ),
                          subtitle: Text(entry.value.toList().join('\n')),
                        ),
                      ],
                    );
                  }),
            ],
          ),
        ),
        const GymModeOptions(),
        FilledButton(
          child: Text(AppLocalizations.of(context).start),
          onPressed: () {
            _controller.nextPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.bounceIn,
            );
          },
        ),
        NavigationFooter(_controller, showPrevious: false),
      ],
    );
  }
}
