import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/day_data.dart';
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
                  title: const Text('Show exercise overview pages'),
                  value: gymState.showExercisePages,
                  onChanged: (value) => gymNotifier.setShowExercisePages(value),
                ),
                SwitchListTile(
                  title: const Text('Show timer'),
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
  final DayData _dayData;
  final Map<Exercise, int> _exercisePages;

  const StartPage(this._controller, this._dayData, this._exercisePages);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).todaysWorkout,
          _controller,
          exercisePages: _exercisePages,
        ),

        Expanded(
          child: ListView(
            children: [
              if (_dayData.day!.isSpecialType)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      '${_dayData.day!.type.name.toUpperCase()}\n${_dayData.day!.type.i18Label(AppLocalizations.of(context))}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ..._dayData.slots.map((slotData) {
                return Column(
                  children: [
                    ...slotData.setConfigs
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
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: entry.value.map((text) => Text(text)).toList(),
                                ),
                              ),
                            ],
                          );
                        }),
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
        NavigationFooter(_controller, 0, showPrevious: false),
      ],
    );
  }
}
