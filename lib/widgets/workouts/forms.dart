/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
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
import 'package:wger/widgets/workouts/exercises.dart';

class WorkoutForm extends StatelessWidget {
  WorkoutPlan _plan;
  final _form = GlobalKey<FormState>();

  WorkoutForm(this._plan);

  final TextEditingController workoutController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_plan.id != null) {
      workoutController.text = _plan.description;
    }

    return Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
            controller: workoutController,
            validator: (value) {
              const minLength = 5;
              const maxLength = 100;
              if (value!.isEmpty || value.length < minLength || value.length > maxLength) {
                return AppLocalizations.of(context)!.enterCharacters(minLength, maxLength);
              }
              return null;
            },
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              _plan.description = newValue!;
            },
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.save),
            onPressed: () async {
              // Validate and save
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // Save to DB
              _plan.id != null
                  ? await Provider.of<WorkoutPlans>(context, listen: false).editWorkout(_plan)
                  : await Provider.of<WorkoutPlans>(context, listen: false).addWorkout(_plan);

              Navigator.of(context).pushReplacementNamed(
                WorkoutPlanScreen.routeName,
                arguments: _plan,
              );
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
      title: Text(widget._day.getDayName(widget._dayNr)),
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
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.description,
              helperText: AppLocalizations.of(context)!.dayDescriptionHelp,
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
                return AppLocalizations.of(context)!.enterCharacters(minLength, maxLength);
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          ...Day.weekdays.keys.map((dayNr) => DayCheckbox(dayNr, widget._day)).toList(),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.save),
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }
              _form.currentState!.save();

              try {
                Provider.of<WorkoutPlans>(context, listen: false).addDay(
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
        setting.setExercise(exercise);
        setting.setRepetitionUnit(
          Provider.of<WorkoutPlans>(context, listen: false).defaultRepetitionUnit,
        );
        setting.setWeightUnit(
          Provider.of<WorkoutPlans>(context, listen: false).defaultWeightUnit,
        );

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
          TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: this._exercisesController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.exercise,
                  helperMaxLines: 3,
                  helperText: AppLocalizations.of(context)!.selectExercises),
            ),
            suggestionsCallback: (pattern) async {
              return await Provider.of<Exercises>(context, listen: false).searchExercise(
                pattern,
                Localizations.localeOf(context).languageCode,
              );
            },
            itemBuilder: (context, suggestion) {
              final result = suggestion! as Map;

              final exercise =
                  Provider.of<Exercises>(context, listen: false).findById(result['data']['id']);
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
              final exercise =
                  Provider.of<Exercises>(context, listen: false).findById(result['data']['id']);
              addExercise(exercise);
              this._exercisesController.text = '';
            },
            validator: (value) {
              if (widget._set.exercisesIds.length == 0) {
                return AppLocalizations.of(context)!.selectExercise;
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          Center(
            child: Text(AppLocalizations.of(context)!.nrOfSets(_currentSetSliderValue.round())),
          ),
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
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.toggleDetails),
            value: _detailed,
            onChanged: (value) {
              setState(() {
                _detailed = !_detailed;
              });
            },
          ),
          Text(
            AppLocalizations.of(context)!.sameRepetitions,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
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
            child: Text(AppLocalizations.of(context)!.save),
            onPressed: () async {
              final isValid = _formKey.currentState!.validate();
              if (!isValid) {
                return;
              }
              _formKey.currentState!.save();

              final workoutProvider = Provider.of<WorkoutPlans>(context, listen: false);

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
                setting.repsText = await workoutProvider.fetchSmartText(
                  widget._set,
                  setting.exerciseObj,
                );
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
      out.add(
        _detailed
            ? Column(
                //crossAxisAlignment: CrossAxisAlignment.baseline,
                //1textBaseline: TextBaseline.alphabetic,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.setNr(i + 1),
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
                        child: WeightUnitInputWidget(setting, key: Key(i.toString())),
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
                        child: RepetitionUnitInputWidget(setting),
                      ),
                    ],
                  ),
                  Flexible(
                    flex: 2,
                    child: RiRInputWidget(setting),
                  ),
                  SizedBox(height: 15),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    AppLocalizations.of(context)!.setNr(i + 1),
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
    return Column(
      children: out,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Text(
          _exercise.name,
          style: Theme.of(context).textTheme.headline6,
        ),
        IconButton(
          icon: Icon(Icons.delete_outline),
          onPressed: () {
            removeExercise(_exercise);
          },
        ),
        //ExerciseImage(imageUrl: _exercise.images.first.url),
        if (!_detailed)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(AppLocalizations.of(context)!.repetitions),
              Text(AppLocalizations.of(context)!.weight),
            ],
          ),
        getRows(context),
      ],
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
        labelText: _detailed ? AppLocalizations.of(context)!.repetitions : '',
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
          return AppLocalizations.of(context)!.enterValidNumber;
        }
        return null;
      },
      onSaved: (newValue) {
        if (newValue != null && newValue != '') {
          _setting.reps = int.parse(newValue);
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
        labelText: _detailed ? AppLocalizations.of(context)!.weight : '',
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
          return AppLocalizations.of(context)!.enterValidNumber;
        }
        return null;
      },
      onSaved: (newValue) {
        if (newValue != null && newValue != '') {
          _setting.weight = double.parse(newValue);
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
  RiRInputWidget(this._setting) {
    dropdownValue = _setting.rir != null ? _setting.rir : Setting.DEFAULT_RIR;
  }

  @override
  _RiRInputWidgetState createState() => _RiRInputWidgetState();
}

class _RiRInputWidgetState extends State<RiRInputWidget> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.rir),
      value: widget.dropdownValue,
      onSaved: (String? newValue) {
        widget._setting.setRir(newValue!);
      },
      onChanged: (String? newValue) {
        setState(() {
          widget.dropdownValue = newValue!;
        });
      },
      items: Setting.POSSIBLE_RIR_VALUES.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
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
      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.weightUnit),
      onChanged: (WeightUnit? newValue) {
        setState(() {
          selectedWeightUnit = newValue!;
          widget._setting.setWeightUnit(newValue);
        });
      },
      items: Provider.of<WorkoutPlans>(context, listen: false)
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
      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.repetitionUnit),
      isDense: true,
      onChanged: (RepetitionUnit? newValue) {
        setState(() {
          selectedWeightUnit = newValue!;
          widget._setting.setRepetitionUnit(newValue);
        });
      },
      items: Provider.of<WorkoutPlans>(context, listen: false)
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
