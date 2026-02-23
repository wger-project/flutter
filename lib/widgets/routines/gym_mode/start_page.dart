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
  late TextEditingController _countdownController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(gymStateProvider).countdownDuration.inSeconds.toString();
    _countdownController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gymState = ref.watch(gymStateProvider);
    final gymNotifier = ref.watch(gymStateProvider.notifier);
    final i18n = AppLocalizations.of(context);

    // If the value in the provider changed, update the controller text
    final currentText = gymState.countdownDuration.inSeconds.toString();
    if (_countdownController.text != currentText) {
      _countdownController.text = currentText;
    }

    return Column(
      children: [
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: Card(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SwitchListTile(
                        key: const ValueKey('gym-mode-option-show-exercises'),
                        title: Text(i18n.gymModeShowExercises),
                        value: gymState.showExercisePages,
                        onChanged: (value) => gymNotifier.setShowExercisePages(value),
                      ),
                      SwitchListTile(
                        key: const ValueKey('gym-mode-option-show-timer'),
                        title: Text(i18n.gymModeShowTimer),
                        value: gymState.showTimerPages,
                        onChanged: (value) => gymNotifier.setShowTimerPages(value),
                      ),
                      ListTile(
                        key: const ValueKey('gym-mode-timer-type'),
                        enabled: gymState.showTimerPages,
                        title: Text(i18n.gymModeTimerType),
                        trailing: DropdownButton<bool>(
                          key: const ValueKey('countdown-type-dropdown'),
                          value: gymState.useCountdownBetweenSets,
                          onChanged: gymState.showTimerPages
                              ? (bool? newValue) {
                                  if (newValue != null) {
                                    gymNotifier.setUseCountdownBetweenSets(newValue);
                                  }
                                }
                              : null,
                          items: [false, true].map<DropdownMenuItem<bool>>((bool value) {
                            final label = value ? i18n.countdown : i18n.stopwatch;

                            return DropdownMenuItem<bool>(value: value, child: Text(label));
                          }).toList(),
                        ),
                        subtitle: Text(i18n.gymModeTimerTypeHelText),
                      ),
                      ListTile(
                        key: const ValueKey('gym-mode-default-countdown-time'),
                        enabled: gymState.showTimerPages,
                        title: TextFormField(
                          controller: _countdownController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: i18n.gymModeDefaultCountdownTime,
                            suffix: IconButton(
                              onPressed: gymState.showTimerPages && gymState.useCountdownBetweenSets
                                  ? () => gymNotifier.setCountdownDuration(
                                      DEFAULT_COUNTDOWN_DURATION,
                                    )
                                  : null,
                              icon: const Icon(Icons.refresh),
                            ),
                          ),
                          onChanged: (value) {
                            final intValue = int.tryParse(value);
                            if (intValue != null &&
                                intValue > 0 &&
                                intValue < MAX_COUNTDOWN_DURATION) {
                              gymNotifier.setCountdownDuration(intValue);
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? value) {
                            final intValue = int.tryParse(value!);
                            if (intValue == null ||
                                intValue < MIN_COUNTDOWN_DURATION ||
                                intValue > MAX_COUNTDOWN_DURATION) {
                              return i18n.formMinMaxValues(
                                MIN_COUNTDOWN_DURATION,
                                MAX_COUNTDOWN_DURATION,
                              );
                            }
                            return null;
                          },
                          enabled: gymState.showTimerPages && gymState.useCountdownBetweenSets,
                        ),
                      ),
                      SwitchListTile(
                        key: const ValueKey('gym-mode-notify-countdown'),
                        title: Text(i18n.gymModeNotifyOnCountdownFinish),
                        value: gymState.alertOnCountdownEnd,
                        onChanged: (gymState.showTimerPages && gymState.useCountdownBetweenSets)
                            ? (value) => gymNotifier.setAlertOnCountdownEnd(value)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          crossFadeState: _showOptions ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),

        ListTile(
          key: const ValueKey('gym-mode-options-tile'),
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
