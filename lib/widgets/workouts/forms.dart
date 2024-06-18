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
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/add_exercise_screen.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/widgets/exercises/images.dart';

class WorkoutForm extends StatelessWidget {
  final WorkoutPlan _plan;
  final _form = GlobalKey<FormState>();

  WorkoutForm(this._plan);

  final TextEditingController workoutNameController = TextEditingController();
  final TextEditingController workoutDescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_plan.id != null) {
      workoutNameController.text = _plan.name;
      workoutDescriptionController.text = _plan.description;
    }

    return Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
            key: const Key('field-name'),
            decoration: InputDecoration(labelText: AppLocalizations.of(context).name),
            controller: workoutNameController,
            validator: (value) {
              const minLength = 1;
              const maxLength = 100;
              if (value!.isEmpty || value.length < minLength || value.length > maxLength) {
                return AppLocalizations.of(context).enterCharacters(minLength, maxLength);
              }
              return null;
            },
            onSaved: (newValue) {
              _plan.name = newValue!;
            },
          ),
          TextFormField(
            key: const Key('field-description'),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).description,
            ),
            minLines: 3,
            maxLines: 10,
            controller: workoutDescriptionController,
            validator: (value) {
              const minLength = 0;
              const maxLength = 1000;
              if (value!.length > maxLength) {
                return AppLocalizations.of(context).enterCharacters(minLength, maxLength);
              }
              return null;
            },
            onSaved: (newValue) {
              _plan.description = newValue!;
            },
          ),
          ElevatedButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              // Validate and save
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // Save to DB
              if (_plan.id != null) {
                await Provider.of<WorkoutPlansProvider>(context, listen: false).editWorkout(_plan);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                final WorkoutPlan newPlan = await Provider.of<WorkoutPlansProvider>(
                  context,
                  listen: false,
                ).addWorkout(_plan);
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(
                    WorkoutPlanScreen.routeName,
                    arguments: newPlan,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class DayCheckbox extends StatefulWidget {
  final Day _day;
  final int _dayNr;

  const DayCheckbox(this._dayNr, this._day);

  @override
  _DayCheckboxState createState() => _DayCheckboxState();
}

class _DayCheckboxState extends State<DayCheckbox> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      key: Key('field-checkbox-${widget._dayNr}'),
      title: Text(widget._day.getDayTranslated(
        widget._dayNr,
        Localizations.localeOf(context).languageCode,
      )),
      value: widget._day.daysOfWeek.contains(widget._dayNr),
      onChanged: (bool? newValue) {
        setState(() {
          if (!newValue!) {
            widget._day.daysOfWeek.remove(widget._dayNr);
          } else {
            widget._day.daysOfWeek.add(widget._dayNr);
          }
        });
      },
    );
  }
}

class DayFormWidget extends StatefulWidget {
  final WorkoutPlan workout;
  final dayController = TextEditingController();
  late final Day _day;

  DayFormWidget(this.workout, [Day? day]) {
    _day = day ?? Day();
    _day.workoutId = workout.id!;
    if (_day.id != null) {
      dayController.text = day!.description;
    }
  }

  @override
  _DayFormWidgetState createState() => _DayFormWidgetState();
}

class _DayFormWidgetState extends State<DayFormWidget> {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: ListView(
        children: [
          TextFormField(
            key: const Key('field-description'),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).description,
              helperText: AppLocalizations.of(context).dayDescriptionHelp,
              helperMaxLines: 3,
            ),
            controller: widget.dayController,
            onSaved: (value) {
              widget._day.description = value!;
            },
            validator: (value) {
              const minLength = 1;
              const maxLength = 100;
              if (value!.isEmpty || value.length < minLength || value.length > maxLength) {
                return AppLocalizations.of(context).enterCharacters(minLength, maxLength);
              }

              if (widget._day.daysOfWeek.isEmpty) {
                return 'You need to select at least one day';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          ...Day.weekdays.keys.map((dayNr) => DayCheckbox(dayNr, widget._day)),
          ElevatedButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }
              _form.currentState!.save();

              try {
                if (widget._day.id == null) {
                  Provider.of<WorkoutPlansProvider>(context, listen: false).addDay(
                    widget._day,
                    widget.workout,
                  );
                } else {
                  Provider.of<WorkoutPlansProvider>(context, listen: false).editDay(
                    widget._day,
                  );
                }

                widget.dayController.clear();
                Navigator.of(context).pop();
              } catch (error) {
                await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('An error occurred!'),
                    content: const Text('Something went wrong.'),
                    actions: [
                      TextButton(
                        child: const Text('Okay'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SetFormWidget extends StatefulWidget {
  final Day _day;
  late final Set _set;

  SetFormWidget(this._day, [Set? set]) {
    _set = set ?? Set.withData(day: _day.id, order: _day.sets.length, sets: 4);
  }

  @override
  _SetFormWidgetState createState() => _SetFormWidgetState();
}

class _SetFormWidgetState extends State<SetFormWidget> {
  double _currentSetSliderValue = Set.DEFAULT_NR_SETS.toDouble();
  bool _detailed = false;
  bool _searchEnglish = true;

  // Form stuff
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _exercisesController = TextEditingController();

  /// Removes an exercise from the current set
  void removeExerciseBase(Exercise base) {
    setState(() {
      widget._set.removeExercise(base);
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
      widget._set.addExerciseBase(base);
      addSettings();
    });
  }

  /// Adds settings to the set
  void addSettings() {
    final workoutProvider = context.read<WorkoutPlansProvider>();

    widget._set.settings = [];
    int order = 0;
    for (final exercise in widget._set.exerciseBasesObj) {
      order++;
      for (int loop = 0; loop < widget._set.sets; loop++) {
        final Setting setting = Setting.empty();
        setting.order = order;
        setting.exercise = exercise;
        setting.weightUnit = workoutProvider.defaultWeightUnit;
        setting.repetitionUnit = workoutProvider.defaultRepetitionUnit;

        widget._set.settings.add(setting);
      }
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
                      widget._set.sets = value.round();
                      _currentSetSliderValue = value;
                      addSettings();
                    });
                  },
                  inactiveColor: Theme.of(context).colorScheme.background,
                ),
                if (widget._set.settings.isNotEmpty)
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
                              if (widget._set.exerciseBasesIds.isEmpty) {
                                return AppLocalizations.of(context).selectExercise;
                              }

                              // At least one setting has to be filled in
                              if (widget._set.settings
                                      .where((s) => s.weight == null && s.reps == null)
                                      .length ==
                                  widget._set.settings.length) {
                                return AppLocalizations.of(context).enterRepetitionsOrWeight;
                              }
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
                    widget._set.comment = newValue!;
                  },
                ),
                const SizedBox(height: 10),
                ...widget._set.exerciseBasesObj.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  final showSupersetInfo = (index + 1) < widget._set.exerciseBasesObj.length;
                  final settings =
                      widget._set.settings.where((e) => e.exerciseObj.id == exercise.id).toList();

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

                    final workoutProvider = Provider.of<WorkoutPlansProvider>(
                      context,
                      listen: false,
                    );

                    // Save set
                    final Set setDb = await workoutProvider.addSet(widget._set);
                    widget._set.id = setDb.id;

                    // Remove unused settings
                    widget._set.settings.removeWhere((s) => s.weight == null && s.reps == null);

                    // Save remaining settings
                    for (final setting in widget._set.settings) {
                      setting.setId = setDb.id!;
                      setting.comment = '';

                      final Setting settingDb = await workoutProvider.addSetting(setting);
                      setting.id = settingDb.id;
                    }

                    // Add to workout day
                    workoutProvider.fetchComputedSettings(widget._set);
                    widget._day.sets.add(widget._set);

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

class ExerciseSetting extends StatelessWidget {
  final Exercise _exerciseBase;
  late final int _numberOfSets;
  final bool _detailed;
  final Function removeExercise;
  final List<Setting> _settings;

  ExerciseSetting(
    this._exerciseBase,
    this._settings,
    this._detailed,
    double sliderValue,
    this.removeExercise,
  ) {
    _numberOfSets = sliderValue.round();
  }

  Widget getRows(BuildContext context) {
    final List<Widget> out = [];
    for (var i = 0; i < _numberOfSets; i++) {
      final setting = _settings[i];

      if (_detailed) {
        out.add(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).setNr(i + 1),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 2,
                    child: RepsInputWidget(setting, _detailed),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    flex: 3,
                    child: RepetitionUnitInputWidget(setting),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 2,
                    child: WeightInputWidget(setting, _detailed),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    flex: 3,
                    child: WeightUnitInputWidget(setting, key: Key(i.toString())),
                  ),
                ],
              ),
              Flexible(flex: 2, child: RiRInputWidget(setting)),
              const SizedBox(height: 15),
            ],
          ),
        );
      } else {
        out.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AppLocalizations.of(context).setNr(i + 1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Flexible(child: RepsInputWidget(setting, _detailed)),
              const SizedBox(width: 4),
              Flexible(child: WeightInputWidget(setting, _detailed)),
            ],
          ),
        );
      }
    }
    return Column(children: out);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            ListTile(
              title: Text(
                _exerciseBase.getExercise(Localizations.localeOf(context).languageCode).name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(_exerciseBase.category!.name),
              contentPadding: EdgeInsets.zero,
              leading: ExerciseImageWidget(image: _exerciseBase.getMainImage),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  removeExercise(_exerciseBase);
                },
              ),
            ),
            const Divider(),

            //ExerciseImage(imageUrl: _exercise.images.first.url),
            if (!_detailed)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(AppLocalizations.of(context).repetitions),
                  Text(AppLocalizations.of(context).weight),
                ],
              ),
            getRows(context),
          ],
        ),
      ),
    );
  }
}

class RepsInputWidget extends StatelessWidget {
  final _repsController = TextEditingController();
  final Setting _setting;
  final bool _detailed;

  RepsInputWidget(this._setting, this._detailed);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: _detailed ? AppLocalizations.of(context).repetitions : '',
        errorMaxLines: 2,
      ),
      controller: _repsController,
      keyboardType: TextInputType.number,
      validator: (value) {
        try {
          if (value != '') {
            double.parse(value!);
          }
        } catch (error) {
          return AppLocalizations.of(context).enterValidNumber;
        }
        return null;
      },
      onChanged: (newValue) {
        if (newValue != '') {
          try {
            _setting.reps = int.parse(newValue);
          } catch (e) {}
        }
      },
    );
  }
}

class WeightInputWidget extends StatelessWidget {
  final _weightController = TextEditingController();
  final Setting _setting;
  final bool _detailed;

  WeightInputWidget(this._setting, this._detailed);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: _detailed ? AppLocalizations.of(context).weight : '',
        errorMaxLines: 2,
      ),
      controller: _weightController,
      keyboardType: TextInputType.number,
      validator: (value) {
        try {
          if (value != '') {
            double.parse(value!);
          }
        } catch (error) {
          return AppLocalizations.of(context).enterValidNumber;
        }
        return null;
      },
      onChanged: (newValue) {
        if (newValue != '') {
          try {
            _setting.weight = double.parse(newValue);
          } catch (e) {}
        }
      },
    );
  }
}

/// Input widget for Rests In Reserve
///
/// Can be used with a Setting or a Log object
class RiRInputWidget extends StatefulWidget {
  final dynamic _setting;
  late String dropdownValue;
  late double _currentSetSliderValue;

  static const SLIDER_START = -0.5;

  RiRInputWidget(this._setting) {
    dropdownValue = _setting.rir ?? Setting.DEFAULT_RIR;

    // Read string RiR into a double
    if (_setting.rir != null) {
      if (_setting.rir == '') {
        _currentSetSliderValue = SLIDER_START;
      } else {
        _currentSetSliderValue = double.parse(_setting.rir);
      }
    } else {
      _currentSetSliderValue = SLIDER_START;
    }
  }

  @override
  _RiRInputWidgetState createState() => _RiRInputWidgetState();
}

class _RiRInputWidgetState extends State<RiRInputWidget> {
  /// Returns the string used in the slider
  String getSliderLabel(double value) {
    if (value < 0) {
      return AppLocalizations.of(context).rirNotUsed;
    }
    return '$value ${AppLocalizations.of(context).rir}';
  }

  String mapDoubleToAllowedRir(double value) {
    if (value < 0) {
      return '';
    } else {
      // The representation is different (3.0 -> 3) we are on an int, round
      if (value.toInt() < value) {
        return value.toString();
      } else {
        return value.toInt().toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(AppLocalizations.of(context).rir),
        Expanded(
          child: Slider(
            value: widget._currentSetSliderValue,
            min: RiRInputWidget.SLIDER_START,
            max: (Setting.POSSIBLE_RIR_VALUES.length - 2) / 2,
            divisions: Setting.POSSIBLE_RIR_VALUES.length - 1,
            label: getSliderLabel(widget._currentSetSliderValue),
            onChanged: (double value) {
              widget._setting.setRir(mapDoubleToAllowedRir(value));
              setState(() {
                widget._currentSetSliderValue = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

/// Input widget for workout weight units
///
/// Can be used with a Setting or a Log object
class WeightUnitInputWidget extends StatefulWidget {
  final dynamic _setting;

  const WeightUnitInputWidget(this._setting, {super.key});

  @override
  _WeightUnitInputWidgetState createState() => _WeightUnitInputWidgetState();
}

class _WeightUnitInputWidgetState extends State<WeightUnitInputWidget> {
  @override
  Widget build(BuildContext context) {
    WeightUnit selectedWeightUnit = widget._setting.weightUnitObj;

    return DropdownButtonFormField(
      value: selectedWeightUnit,
      decoration: InputDecoration(labelText: AppLocalizations.of(context).weightUnit),
      onChanged: (WeightUnit? newValue) {
        setState(() {
          selectedWeightUnit = newValue!;
          widget._setting.weightUnit = newValue;
        });
      },
      items: Provider.of<WorkoutPlansProvider>(context, listen: false)
          .weightUnits
          .map<DropdownMenuItem<WeightUnit>>((WeightUnit value) {
        return DropdownMenuItem<WeightUnit>(
          key: Key(value.id.toString()),
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}

/// Input widget for repetition units
///
/// Can be used with a Setting or a Log object
class RepetitionUnitInputWidget extends StatefulWidget {
  final dynamic _setting;

  const RepetitionUnitInputWidget(this._setting);

  @override
  _RepetitionUnitInputWidgetState createState() => _RepetitionUnitInputWidgetState();
}

class _RepetitionUnitInputWidgetState extends State<RepetitionUnitInputWidget> {
  @override
  Widget build(BuildContext context) {
    RepetitionUnit selectedWeightUnit = widget._setting.repetitionUnitObj;

    return DropdownButtonFormField(
      value: selectedWeightUnit,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).repetitionUnit,
      ),
      isDense: true,
      onChanged: (RepetitionUnit? newValue) {
        setState(() {
          selectedWeightUnit = newValue!;
          widget._setting.repetitionUnit = newValue;
        });
      },
      items: Provider.of<WorkoutPlansProvider>(context, listen: false)
          .repetitionUnits
          .map<DropdownMenuItem<RepetitionUnit>>((RepetitionUnit value) {
        return DropdownMenuItem<RepetitionUnit>(
          key: Key(value.id.toString()),
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
