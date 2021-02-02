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
  const SetFormWidget({
    Key key,
  }) : super(key: key);

  @override
  _SetFormWidgetState createState() => _SetFormWidgetState();
}

class _SetFormWidgetState extends State<SetFormWidget> {
  double _currentSetSliderValue = 4;
  List<Exercise> _exercises = [];

  // Form stuff
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _exercisesController = TextEditingController();

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
                final e = Provider.of<Exercises>(context, listen: false)
                    .findById(suggestion['data']['id']);
                setState(() {
                  _exercises.add(e);
                });
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please select an exercise';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            Text('Number of sets:'),
            Slider(
              value: _currentSetSliderValue,
              min: 1,
              max: 10,
              divisions: 10,
              label: _currentSetSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSetSliderValue = value;
                });
              },
            ),
            Text('If you do the same repetitions for all sets you can just enter '
                'one value: e.g. for 4 sets just enter one "10" for the repetitions, '
                'this automatically becomes "4 x 10".'),
            ..._exercises.map((e) => ExerciseSet(e, _currentSetSliderValue)).toList(),
            ElevatedButton(child: Text('Save'), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class ExerciseSet extends StatelessWidget {
  Exercise _exercise;
  int _numberOfSets;

  ExerciseSet(Exercise exercise, double sliderValue) {
    this._exercise = exercise;
    this._numberOfSets = sliderValue.round();
  }

  Widget getSets() {
    List<Widget> out = [];
    for (var i = 1; i <= _numberOfSets; i++) {
      out.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RepsInputWidget(),
            WeightUnitInputWidget(key: Key(i.toString())),
            WeightInputWidget(),
            RiRInputWidget(),
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
        //ExerciseImage(imageUrl: _exercise.images.first.url),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reps'),
            Text('Unit'),
            Text('Weight'),
            Text('RiR'),
          ],
        ),
        getSets(),
      ],
    );
  }
}

class RepsInputWidget extends StatelessWidget {
  final _repsController = TextEditingController();

  RepsInputWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        //decoration: InputDecoration(labelText: 'aa'),
        controller: _repsController,
        onTap: () async {},
      ),
    );
  }
}

class WeightInputWidget extends StatelessWidget {
  final _weightController = TextEditingController();

  WeightInputWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        //decoration: InputDecoration(labelText: ''),
        controller: _weightController,
        onTap: () async {},
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
  String dropdownValue = '1';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      underline: Container(
        height: 0,
        //  color: Colors.deepPurpleAccent,
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
