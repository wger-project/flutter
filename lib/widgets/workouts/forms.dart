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

class DayFormWidget extends StatefulWidget {
  final WorkoutPlan workout;
  final dayController = TextEditingController();

  Map<String, dynamic> _dayData = {
    'description': '',
    'daysOfWeek': [1],
  };

  DayFormWidget({
    Key key,
    @required this.workout,
  }) : super(key: key);

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
            Text(
              AppLocalizations.of(context).newDay,
              style: Theme.of(context).textTheme.headline6,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
              controller: widget.dayController,
              onSaved: (value) {
                widget._dayData['description'] = value;
              },
              validator: (value) {
                const minLenght = 5;
                const maxLenght = 100;
                if (value.isEmpty || value.length < minLenght || value.length > maxLenght) {
                  return 'Please enter between $minLenght and $maxLenght characters.';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'TODO: Checkbox for days'),
              enabled: false,
            ),
            //...Day().weekdays.values.map((dayName) => DayCheckbox(dayName)).toList(),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).save),
              onPressed: () async {
                if (!_form.currentState.validate()) {
                  return;
                }
                _form.currentState.save();

                try {
                  Provider.of<WorkoutPlans>(context, listen: false).addDay(
                      Day(description: widget.dayController.text, daysOfWeek: [1]), widget.workout);
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
                decoration: InputDecoration(labelText: AppLocalizations.of(context).exercise),
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
            Text('You can search for more than one exercise, they will be grouped '
                'together for a superset.'),
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
      out.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Reps'),
          Text('Unit'),
          Text('Weight'),
          Text('RiR'),
        ],
      ));
    }
    return Column(
      children: out,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_exercise.name, style: TextStyle(fontWeight: FontWeight.bold)),
        //ExerciseImage(imageUrl: _exercise.images.first.url),
        Divider(),
        getSets(),
        Padding(padding: EdgeInsets.symmetric(vertical: 5))
      ],
    );
  }
}
