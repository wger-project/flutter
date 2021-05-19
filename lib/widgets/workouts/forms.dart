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
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/exercises/images.dart';

class WorkoutForm extends StatelessWidget {
  WorkoutPlan _plan;
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
            key: Key('field-name'),
            decoration: InputDecoration(labelText: AppLocalizations.of(context).name),
            controller: workoutNameController,
            validator: (value) {
              const minLength = 5;
              const maxLength = 100;
              if (value!.isEmpty || value.length < minLength || value.length > maxLength) {
                return AppLocalizations.of(context).enterCharacters(minLength, maxLength);
              }
              return null;
            },
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              _plan.name = newValue!;
            },
          ),
          TextFormField(
            key: Key('field-description'),
            decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
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
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              _plan.description = newValue!;
            },
          ),
          ElevatedButton(
            key: Key(SUBMIT_BUTTON_KEY_NAME),
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
                Navigator.of(context).pop();
              } else {
                _plan = await Provider.of<WorkoutPlansProvider>(context, listen: false)
                    .addWorkout(_plan);
                Navigator.of(context).pushReplacementNamed(
                  WorkoutPlanScreen.routeName,
                  arguments: _plan,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class DayCheckbox extends StatefulWidget {
  Day _day;
  final int _dayNr;

  DayCheckbox(this._dayNr, this._day);

  @override
  _DayCheckboxState createState() => _DayCheckboxState();
}

class _DayCheckboxState extends State<DayCheckbox> {
  bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      key: Key('field-checkbox-${widget._dayNr}'),
      title: Text(widget._day.getDayTranslated(
        widget._dayNr,
        Localizations.localeOf(context).languageCode,
      )),
      value: _isSelected,
      onChanged: (bool? newValue) {
        setState(() {
          _isSelected = newValue!;
          if (!newValue) {
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
  Day _day = Day();

  DayFormWidget(this.workout, [Day? day]) {
    this._day = day ?? Day();
    _day.workoutId = this.workout.id!;
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
            key: Key('field-description'),
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
              const minLength = 5;
              const maxLength = 100;
              if (value!.isEmpty || value.length < minLength || value.length > maxLength) {
                return AppLocalizations.of(context).enterCharacters(minLength, maxLength);
              }

              if (widget._day.daysOfWeek.length == 0) {
                return 'You need to select at least one day';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          ...Day.weekdays.keys.map((dayNr) => DayCheckbox(dayNr, widget._day)).toList(),
          ElevatedButton(
            key: Key(SUBMIT_BUTTON_KEY_NAME),
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }
              _form.currentState!.save();

              try {
                Provider.of<WorkoutPlansProvider>(context, listen: false).addDay(
                  widget._day,
                  widget.workout,
                );

                widget.dayController.clear();
                Navigator.of(context).pop();
              } catch (error) {
                await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('An error occurred!'),
                    content: Text('Something went wrong.'),
                    actions: [
                      TextButton(
                        child: Text('Okay'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      )
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
  Day _day;
  late Set _set;

  SetFormWidget(this._day, [Set? set]) {
    this._set = set ?? Set.withData(day: _day.id, sets: 4);
  }

  @override
  _SetFormWidgetState createState() => _SetFormWidgetState();
}

class _SetFormWidgetState extends State<SetFormWidget> {
  double _currentSetSliderValue = Set.DEFAULT_NR_SETS.toDouble();
  bool _detailed = false;

  // Form stuff
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _exercisesController = TextEditingController();

  /// Removes an exercise from the current set
  void removeExercise(Exercise exercise) {
    setState(() {
      widget._set.removeExercise(exercise);
    });
  }

  /// Adds an exercise to the current set
  void addExercise(Exercise exercise) {
    setState(() {
      widget._set.addExercise(exercise);
      addSettings();
    });
  }

  /// Adds settings to the set
  void addSettings() {
    widget._set.settings = [];
    int order = 0;
    for (var exercise in widget._set.exercisesObj) {
      order++;
      for (int loop = 0; loop < widget._set.sets; loop++) {
        Setting setting = Setting.empty();
        setting.order = order;
        setting.exercise = exercise;
        setting.weightUnit =
            Provider.of<WorkoutPlansProvider>(context, listen: false).defaultWeightUnit;
        setting.repetitionUnit =
            Provider.of<WorkoutPlansProvider>(context, listen: false).defaultRepetitionUnit;

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
            padding: EdgeInsets.only(top: 10),
            color: wgerPrimaryColorLight,
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
                ),
                if (widget._set.settings.length > 0)
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
                  child: TypeAheadFormField(
                    key: Key('field-typeahead'),
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: this._exercisesController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).searchExercise,
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.help),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(AppLocalizations.of(context).selectExercises),
                                    SizedBox(height: 10),
                                    Text(AppLocalizations.of(context).sameRepetitions)
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(MaterialLocalizations.of(context).closeButtonLabel),
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
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return await Provider.of<ExercisesProvider>(context, listen: false)
                          .searchExercise(
                        pattern,
                        Localizations.localeOf(context).languageCode,
                      );
                    },
                    itemBuilder: (context, suggestion) {
                      final result = suggestion! as Map;

                      final exercise = Provider.of<ExercisesProvider>(context, listen: false)
                          .findById(result['data']['id']);
                      return ListTile(
                        leading: Container(
                          width: 45,
                          child: ExerciseImageWidget(image: exercise.getMainImage),
                        ),
                        title: Text(exercise.name),
                        subtitle: Text(
                            '${exercise.categoryObj.name} / ${exercise.equipment.map((e) => e.name).join(', ')}'),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) {
                      final result = suggestion! as Map;
                      final exercise = Provider.of<ExercisesProvider>(context, listen: false)
                          .findById(result['data']['id']);
                      addExercise(exercise);
                      this._exercisesController.text = '';
                    },
                    validator: (value) {
                      // At least one exercise must be selected
                      if (widget._set.exercisesIds.length == 0) {
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
                  ),
                ),
                SizedBox(height: 10),
                ...widget._set.exercisesObj.map((exercise) {
                  final settings =
                      widget._set.settings.where((e) => e.exerciseObj.id == exercise.id).toList();

                  return ExerciseSetting(
                    exercise,
                    settings,
                    _detailed,
                    _currentSetSliderValue,
                    removeExercise,
                  );
                }).toList(),
                ElevatedButton(
                  key: Key(SUBMIT_BUTTON_KEY_NAME),
                  child: Text(AppLocalizations.of(context).save),
                  onPressed: () async {
                    final isValid = _formKey.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    _formKey.currentState!.save();

                    final workoutProvider =
                        Provider.of<WorkoutPlansProvider>(context, listen: false);

                    // Save set
                    Set setDb = await workoutProvider.addSet(widget._set);
                    widget._set.id = setDb.id;

                    // Remove unused settings
                    widget._set.settings.removeWhere((s) => s.weight == null && s.reps == null);

                    // Save remaining settings
                    for (var setting in widget._set.settings) {
                      setting.setId = setDb.id!;
                      setting.comment = '';

                      Setting settingDb = await workoutProvider.addSetting(setting);
                      setting.id = settingDb.id;
                    }

                    // Add to workout day
                    workoutProvider.fetchComputedSettings(widget._set);
                    widget._day.sets.add(widget._set);

                    // Close the bottom sheet
                    Navigator.of(context).pop();
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
  final Exercise _exercise;
  int _numberOfSets = 4;
  bool _detailed;
  final Function removeExercise;
  List<Setting> _settings = [];

  ExerciseSetting(
    this._exercise,
    this._settings,
    this._detailed,
    double sliderValue,
    this.removeExercise,
  ) {
    this._numberOfSets = sliderValue.round();
  }

  Widget getRows(BuildContext context) {
    List<Widget> out = [];
    for (var i = 0; i < _numberOfSets; i++) {
      var setting = _settings[i];

      if (_detailed) {
        out.add(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).setNr(i + 1),
                style: Theme.of(context).textTheme.headline6,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 2,
                    child: RepsInputWidget(setting, _detailed),
                  ),
                  SizedBox(width: 4),
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
                  SizedBox(width: 4),
                  Flexible(
                    flex: 3,
                    child: WeightUnitInputWidget(setting, key: Key(i.toString())),
                  ),
                ],
              ),
              Flexible(
                flex: 2,
                child: RiRInputWidget(setting),
              ),
              SizedBox(height: 15),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Flexible(child: RepsInputWidget(setting, _detailed)),
              SizedBox(width: 4),
              Flexible(child: WeightInputWidget(setting, _detailed)),
            ],
          ),
        );
      }
    }
    return Column(
      children: out,
    );
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
                _exercise.name,
                style: Theme.of(context).textTheme.headline6,
              ),
              subtitle: Text(_exercise.categoryObj.name),
              contentPadding: EdgeInsets.zero,
              leading: ExerciseImageWidget(image: _exercise.getMainImage),
              trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    removeExercise(_exercise);
                  }),
            ),
            Divider(),

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
          if (value != "") {
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
          if (value != "") {
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

  final SLIDER_START = -0.5;

  RiRInputWidget(this._setting) {
    dropdownValue = _setting.rir != null ? _setting.rir : Setting.DEFAULT_RIR;

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
    return '${value.toString()} ${AppLocalizations.of(context).rir}';
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
            min: widget.SLIDER_START,
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

  WeightUnitInputWidget(this._setting, {Key? key}) : super(key: key);

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
  RepetitionUnitInputWidget(this._setting);

  @override
  _RepetitionUnitInputWidgetState createState() => _RepetitionUnitInputWidgetState();
}

class _RepetitionUnitInputWidgetState extends State<RepetitionUnitInputWidget> {
  @override
  Widget build(BuildContext context) {
    RepetitionUnit selectedWeightUnit = widget._setting.repetitionUnitObj;

    return DropdownButtonFormField(
      value: selectedWeightUnit,
      decoration: InputDecoration(labelText: AppLocalizations.of(context).repetitionUnit),
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
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
