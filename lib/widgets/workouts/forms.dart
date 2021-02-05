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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/widgets/workouts/exercises.dart';

class WorkoutForm extends StatelessWidget {
  WorkoutPlan _plan;
  final _form = GlobalKey<FormState>();

  WorkoutForm(
    this._plan, {
    Key key,
  }) : super(key: key);

  final TextEditingController workoutController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    workoutController.text = _plan.description ?? '';

    return Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
            controller: workoutController,
            validator: (value) {
              const minLength = 5;
              const maxLength = 100;
              if (value.isEmpty || value.length < minLength || value.length > maxLength) {
                return 'Please enter between $minLength and $maxLength characters.';
              }
              return null;
            },
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              _plan.description = newValue;
            },
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              // Validate and save
              final isValid = _form.currentState.validate();
              if (!isValid) {
                return;
              }
              _form.currentState.save();

              // Save to DB
              final workout = _plan.id != null
                  ? await Provider.of<WorkoutPlans>(context, listen: false).patchWorkout(_plan)
                  : await Provider.of<WorkoutPlans>(context, listen: false).postWorkout(_plan);

              Navigator.of(context).pop();
              if (_plan.id == null) {
                Navigator.of(context).pushNamed(WorkoutPlanScreen.routeName, arguments: workout);
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
      title: Text(widget._day.getDayName(widget._dayNr)),
      value: _isSelected,
      onChanged: (bool newValue) {
        setState(() {
          _isSelected = newValue;
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
  Day _day;

  DayFormWidget({
    @required this.workout,
    day,
  }) {
    this._day = day ?? Day();
    _day.workout = this.workout;
    _day.workoutId = this.workout.id;
  }

  @override
  _DayFormWidgetState createState() => _DayFormWidgetState();
}

class _DayFormWidgetState extends State<DayFormWidget> {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
              controller: widget.dayController,
              onSaved: (value) {
                widget._day.description = value;
              },
              validator: (value) {
                const minLength = 5;
                const maxLength = 100;
                if (value.isEmpty || value.length < minLength || value.length > maxLength) {
                  return 'Please enter between $minLength and $maxLength characters.';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            Text('Week days'),
            ...Day.weekdays.keys.map((dayNr) => DayCheckbox(dayNr, widget._day)).toList(),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).save),
              onPressed: () async {
                if (!_form.currentState.validate()) {
                  return;
                }
                _form.currentState.save();

                try {
                  print(widget._day.daysOfWeek);
                  print(widget._day.description);
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
      ),
    );
  }
}

class SetFormWidget extends StatefulWidget {
  Day _day;
  Set _set;

  SetFormWidget(Day day, [Set set]) {
    this._day = day;
    this._set = set ?? Set(day: day.id, sets: 4);
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
  void removeExercise(int id) {
    setState(() {
      widget._set.exercises.removeWhere((element) => element.id == id);
    });
  }

  /// Adds an exercise to the current set
  void addExercise(Exercise exercise) {
    setState(() {
      widget._set.exercises.add(exercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: this._exercisesController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).exercise,
                    helperMaxLines: 3,
                    helperText: 'You can search for more than one exercise, they will be grouped '
                        'together for a superset.'),
              ),
              suggestionsCallback: (pattern) async {
                return await Provider.of<Exercises>(context, listen: false).searchExercise(pattern);
              },
              itemBuilder: (context, suggestion) {
                // TODO: this won't work if the server uses e.g. AWS to serve
                //       the static files
                String serverUrl = Provider.of<Auth>(context, listen: false).serverUrl;
                final exercise = Provider.of<Exercises>(context, listen: false)
                    .findById(suggestion['data']['id']);
                return ListTile(
                  leading: Container(
                    width: 45,
                    child: suggestion['data']['image'] != null
                        ? ExerciseImage(
                            imageUrl: suggestion['data']['image'],
                            serverUrl: serverUrl,
                          )
                        : Container(),
                  ),
                  title: Text(exercise.name),
                  subtitle: Text(exercise.category.name),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (suggestion) {
                final exercise = Provider.of<Exercises>(context, listen: false)
                    .findById(suggestion['data']['id']);
                addExercise(exercise);
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please select an exercise';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            Text('Number of sets: ${_currentSetSliderValue.round()}'),
            Slider(
              value: _currentSetSliderValue,
              min: 1,
              max: 10,
              divisions: 10,
              label: _currentSetSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  widget._set.sets = value.round();

                  // Add all settings to list
                  widget._set.settings = [];
                  for (var exercise in widget._set.exercises) {
                    for (int loop = 0; loop < widget._set.sets; loop++) {
                      widget._set.settings.add(Setting(exercise: exercise));
                    }
                  }

                  _currentSetSliderValue = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('More details'),
              value: _detailed,
              onChanged: (value) {
                setState(() {
                  _detailed = !_detailed;
                });
              },
            ),
            Text('If you do the same repetitions for all sets you can just enter '
                'one value: e.g. for 4 sets just enter one "10" for the repetitions, '
                'this automatically becomes "4 x 10".'),
            ...widget._set.exercises.map((exercise) {
              final settings =
                  widget._set.settings.where((e) => e.exercise.id == exercise.id).toList();

              return ExerciseSetting(
                exercise,
                settings,
                _detailed,
                _currentSetSliderValue,
                removeExercise,
              );
            }).toList(),
            ElevatedButton(
                child: Text(AppLocalizations.of(context).save),
                onPressed: () async {
                  final isValid = _formKey.currentState.validate();
                  if (!isValid) {
                    return;
                  }
                  _formKey.currentState.save();

                  print(widget._set.toJson());
                  //await Provider.of<WorkoutPlans>(context, listen: false).addSet(widget._set);
                  for (var setting in widget._set.settings) {
                    if (setting.weight != null && setting.reps != null) {
                      //await Provider.of<WorkoutPlans>(context, listen: false).addSetting(setting);
                      print(setting.toJson());
                    }
                  }

                  print('Set debug');
                  print('--------------------------');
                  print('Day-ID: ${widget._set.day}');
                  print('Nr of sets: ${widget._set.sets}');
                  print('Exercises: ');
                  for (var e in widget._set.exercises) {
                    print('  * ${e.name}');
                  }
                  print('Settings: ');
                  for (var s in widget._set.settings) {
                    print('  * Exercise: ${s.exercise.name}, Weight: ${s.weight}, Reps: ${s.reps}');
                  }
                }),
          ],
        ),
      ),
    );
  }
}

class ExerciseSetting extends StatelessWidget {
  Exercise _exercise;
  int _numberOfSets;
  bool _detailed;
  Function removeExercise;
  List<Setting> _settings = [];

  ExerciseSetting(Exercise exercise, List<Setting> settings, bool expanded, double sliderValue,
      removeExercise) {
    this._exercise = exercise;
    this._settings = settings;
    this._detailed = expanded;
    this._numberOfSets = sliderValue.round();
    this.removeExercise = removeExercise;
  }

  Widget getRow() {
    List<Widget> out = [];
    for (var i = 0; i < _numberOfSets; i++) {
      var setting = _settings[i];
      out.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RepsInputWidget(setting),
            SizedBox(width: 4),
            if (_detailed) WeightUnitInputWidget(key: Key(i.toString())),
            WeightInputWidget(setting),
            SizedBox(width: 4),
            if (_detailed) RepetitionUnitInputWidget(),
            if (_detailed) RiRInputWidget(),
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
        SizedBox(height: 15),
        Text(_exercise.name, style: TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            removeExercise(_exercise.id);
          },
        ),
        //ExerciseImage(imageUrl: _exercise.images.first.url),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Reps'),
            if (_detailed) Text('Unit'),
            Text('Weight'),
            if (_detailed) Text('Weight unit'),
            if (_detailed) Text('RiR'),
          ],
        ),
        getRow(),
      ],
    );
  }
}

class RepsInputWidget extends StatelessWidget {
  final _repsController = TextEditingController();
  Setting _setting;

  RepsInputWidget(Setting setting) {
    this._setting = setting;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        //decoration: InputDecoration(labelText: 'Reps'),
        controller: _repsController,
        keyboardType: TextInputType.number,
        onSaved: (newValue) {
          if (newValue != null && newValue != '') {
            _setting.reps = int.parse(newValue);
          }
        },
      ),
    );
  }
}

class WeightInputWidget extends StatelessWidget {
  final _weightController = TextEditingController();
  Setting _setting;

  WeightInputWidget(Setting setting) {
    this._setting = setting;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        //decoration: InputDecoration(labelText: 'Weight'),
        controller: _weightController,
        keyboardType: TextInputType.number,
        onSaved: (newValue) {
          if (newValue != null && newValue != '') {
            _setting.weight = double.parse(newValue);
          }
        },
      ),
    );
  }
}

class RiRInputWidget extends StatefulWidget {
  RiRInputWidget({Key key}) : super(key: key);

  @override
  _RiRInputWidgetState createState() => _RiRInputWidgetState();
}

class _RiRInputWidgetState extends State<RiRInputWidget> {
  String dropdownValue = '1';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      underline: Container(
        height: 0,
        //color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['1', '1.5', '2', '2.5', '3', '3.5']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class WeightUnitInputWidget extends StatefulWidget {
  WeightUnitInputWidget({Key key}) : super(key: key);

  @override
  _WeightUnitInputWidgetState createState() => _WeightUnitInputWidgetState();
}

class _WeightUnitInputWidgetState extends State<WeightUnitInputWidget> {
  WeightUnit dropdownValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<WeightUnit>(
      value: dropdownValue,
      underline: Container(
        height: 0,
        //  color: Colors.deepPurpleAccent,
      ),
      onChanged: (WeightUnit newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: Provider.of<WorkoutPlans>(context, listen: false)
          .weightUnits
          .map<DropdownMenuItem<WeightUnit>>((WeightUnit value) {
        return DropdownMenuItem<WeightUnit>(
          value: value,
          child: Text(
            value.name,
            style: TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}

class RepetitionUnitInputWidget extends StatefulWidget {
  RepetitionUnitInputWidget({Key key}) : super(key: key);

  @override
  _RepetitionUnitInputWidgetState createState() => _RepetitionUnitInputWidgetState();
}

class _RepetitionUnitInputWidgetState extends State<RepetitionUnitInputWidget> {
  RepetitionUnit dropdownValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<RepetitionUnit>(
      value: dropdownValue,
      underline: Container(
        height: 0,
        //  color: Colors.deepPurpleAccent,
      ),
      onChanged: (RepetitionUnit newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: Provider.of<WorkoutPlans>(context, listen: false)
          .repetitionUnits
          .map<DropdownMenuItem<RepetitionUnit>>((RepetitionUnit value) {
        return DropdownMenuItem<RepetitionUnit>(
          value: value,
          child: Text(
            value.name,
            style: TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}
