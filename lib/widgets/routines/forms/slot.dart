/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/add_exercise_screen.dart';
import 'package:wger/widgets/exercises/images.dart';
import 'package:wger/widgets/routines/forms.dart';

class SlotFormWidgetNg extends StatefulWidget {
  final Day _day;

  SlotFormWidgetNg(this._day);

  @override
  _SlotFormWidgetStateNg createState() => _SlotFormWidgetStateNg();
}

class _SlotFormWidgetStateNg extends State<SlotFormWidgetNg> {
  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      children: [
        Text(widget._day.id!.toString()),
        ...widget._day.slots.map((slot) => Text(slot.id!.toString())).toList()
      ],
    ));
  }
}

class SlotFormWidget extends StatefulWidget {
  final Day _day;
  late final Slot _slot;

  SlotFormWidget(this._day, [Slot? set]) {
    _slot = set ?? Slot.withData(day: _day.id, order: _day.slots.length);
  }

  @override
  _SlotFormWidgetState createState() => _SlotFormWidgetState();
}

class _SlotFormWidgetState extends State<SlotFormWidget> {
  double _currentSetSliderValue = Slot.DEFAULT_NR_SETS.toDouble();
  bool _detailed = false;
  bool _searchEnglish = true;

  // Form stuff
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _exercisesController = TextEditingController();

  /// Removes an exercise from the current set
  void removeExerciseBase(Exercise base) {
    setState(() {
      widget._slot.removeExercise(base);
    });
  }

  @override
  void dispose() {
    _exercisesController.dispose();
    super.dispose();
  }

  /// Adds an exercise to the current set
  void addExercise(Exercise base) {
    setState(() {
      widget._slot.addExerciseBase(base);
      addSettings();
    });
  }

  /// Adds settings to the set
  void addSettings() {
    final workoutProvider = context.read<RoutinesProvider>();

    widget._slot.entries = [];
    int order = 0;
    for (final exercise in widget._slot.exercisesObj) {
      order++;
      // for (int loop = 0; loop < widget._set.sets; loop++) {
      final SlotEntry setting = SlotEntry.empty();
      setting.order = order;
      setting.exercise = exercise;
      setting.weightUnit = workoutProvider.defaultWeightUnit;
      setting.repetitionUnit = workoutProvider.defaultRepetitionUnit;

      widget._slot.entries.add(setting);
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 10),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).nrOfSets(_currentSetSliderValue.round())),
                Slider(
                  value: _currentSetSliderValue,
                  min: 1,
                  max: 10,
                  divisions: 10,
                  label: _currentSetSliderValue.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      // widget._set.sets = value.round();
                      _currentSetSliderValue = value;
                      addSettings();
                    });
                  },
                  inactiveColor: Theme.of(context).colorScheme.surface,
                ),
                if (widget._slot.entries.isNotEmpty)
                  SwitchListTile(
                    title: Text(AppLocalizations.of(context).setUnitsAndRir),
                    value: _detailed,
                    onChanged: (value) {
                      setState(() {
                        _detailed = !_detailed;
                      });
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Card(
                  child: Column(
                    children: [
                      TypeAheadField<Exercise>(
                        key: const Key('field-typeahead'),
                        decorationBuilder: (context, child) {
                          return Material(
                            type: MaterialType.card,
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: child,
                          );
                        },
                        controller: _exercisesController,
                        builder: (context, controller, focusNode) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            // autofocus: true,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).searchExercise,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.help),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(AppLocalizations.of(context).selectExercises),
                                          const SizedBox(height: 10),
                                          Text(AppLocalizations.of(context).sameRepetitions),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text(
                                            MaterialLocalizations.of(context).closeButtonLabel,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              errorMaxLines: 2,
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              // At least one exercise must be selected
                              if (widget._slot.exercisesIds.isEmpty) {
                                return AppLocalizations.of(context).selectExercise;
                              }

                              // At least one setting has to be filled in
                              // if (widget._set.entries
                              //         .where((s) => s.weight == null && s.reps == null)
                              //         .length ==
                              //     widget._set.entries.length) {
                              //   return AppLocalizations.of(context).enterRepetitionsOrWeight;
                              // }
                              return null;
                            },
                          );
                        },
                        suggestionsCallback: (pattern) {
                          if (pattern == '') {
                            return null;
                          }
                          return context.read<ExercisesProvider>().searchExercise(
                                pattern,
                                languageCode: Localizations.localeOf(context).languageCode,
                                searchEnglish: _searchEnglish,
                              );
                        },
                        itemBuilder: (
                          BuildContext context,
                          Exercise exerciseSuggestion,
                        ) =>
                            ListTile(
                          key: Key('exercise-${exerciseSuggestion.id}'),
                          leading: SizedBox(
                            width: 45,
                            child: ExerciseImageWidget(
                              image: exerciseSuggestion.getMainImage,
                            ),
                          ),
                          title: Text(
                            exerciseSuggestion
                                .getExercise(Localizations.localeOf(context).languageCode)
                                .name,
                          ),
                          subtitle: Text(
                            '${exerciseSuggestion.category!.name} / ${exerciseSuggestion.equipment.map((e) => e.name).join(', ')}',
                          ),
                        ),
                        emptyBuilder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text(AppLocalizations.of(context).noMatchingExerciseFound),
                              ),
                              ListTile(
                                title: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(AddExerciseScreen.routeName);
                                  },
                                  child: Text(AppLocalizations.of(context).contributeExercise),
                                ),
                              ),
                            ],
                          );
                        },
                        transitionBuilder: (context, animation, child) => FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastOutSlowIn,
                          ),
                          child: child,
                        ),
                        onSelected: (Exercise exerciseSuggestion) {
                          // SuggestionsController.of(context).select(exerciseSuggestion);

                          addExercise(exerciseSuggestion);
                          _exercisesController.text = '';
                        },
                      ),
                      if (Localizations.localeOf(context).languageCode != LANGUAGE_SHORT_ENGLISH)
                        SwitchListTile(
                          title: Text(AppLocalizations.of(context).searchNamesInEnglish),
                          value: _searchEnglish,
                          onChanged: (_) {
                            setState(() {
                              _searchEnglish = !_searchEnglish;
                            });
                          },
                          dense: true,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).comment,
                    errorMaxLines: 2,
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    const minLength = 0;
                    const maxLength = 200;
                    if (value!.length > maxLength) {
                      return AppLocalizations.of(context).enterCharacters(minLength, maxLength);
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    widget._slot.comment = newValue!;
                  },
                ),
                const SizedBox(height: 10),
                ...widget._slot.exercisesObj.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  final showSupersetInfo = (index + 1) < widget._slot.exercisesObj.length;
                  final settings =
                      widget._slot.entries.where((e) => e.exerciseObj.id == exercise.id).toList();

                  return Column(
                    children: [
                      ExerciseSetting(
                        exercise,
                        settings,
                        _detailed,
                        _currentSetSliderValue,
                        removeExerciseBase,
                      ),
                      if (showSupersetInfo)
                        const Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text('+'),
                        ),
                      if (showSupersetInfo) Text(AppLocalizations.of(context).supersetWith),
                      if (showSupersetInfo)
                        const Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text('+'),
                        ),
                    ],
                  );
                }),
                ElevatedButton(
                  key: const Key(SUBMIT_BUTTON_KEY_NAME),
                  child: Text(AppLocalizations.of(context).save),
                  onPressed: () async {
                    final isValid = _formKey.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    _formKey.currentState!.save();

                    final workoutProvider = Provider.of<RoutinesProvider>(
                      context,
                      listen: false,
                    );

                    // Save set
                    final Slot setDb = await workoutProvider.addSet(widget._slot);
                    widget._slot.id = setDb.id;

                    // Remove unused settings
                    // widget._set.entries.removeWhere((s) => s.weight == null && s.reps == null);

                    // Save remaining settings
                    for (final setting in widget._slot.entries) {
                      setting.slotId = setDb.id!;
                      setting.comment = '';

                      final SlotEntry settingDb = await workoutProvider.addSetting(setting);
                      setting.id = settingDb.id;
                    }

                    // Add to workout day
                    workoutProvider.fetchComputedSettings(widget._slot);
                    widget._day.slots.add(widget._slot);

                    // Close the bottom sheet
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
