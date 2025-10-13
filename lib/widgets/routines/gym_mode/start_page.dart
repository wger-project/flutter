import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/widgets/exercises/images.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';

class StartPage extends StatelessWidget {
  final PageController _controller;
  final DayData _dayData;
  final Map<Exercise, int> _exercisePages;
  final int _totalPages;

  const StartPage(this._controller, this._dayData, this._exercisePages, this._totalPages);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).todaysWorkout,
          _controller,
          _totalPages,
          exercisePages: _exercisePages,
          hideEndWorkoutButton: true,
        ),
        Expanded(
          child: ListView(
            children: [
              ..._dayData.slots.map((slotData) {
                return Column(
                  children: [
                    ...slotData.setConfigs
                        .fold<Map<Exercise, List<String>>>({}, (acc, entry) {
                          acc.putIfAbsent(entry.exercise, () => []).add(entry.textRepr);
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
