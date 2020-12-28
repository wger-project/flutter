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
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/workout_plans.dart';

class DayFormWidget extends StatelessWidget {
  final WorkoutPlan workout;

  DayFormWidget({
    Key key,
    @required this.dayController,
    @required Map<String, dynamic> dayData,
    @required this.workout,
  })  : _dayData = dayData,
        super(key: key);

  final TextEditingController dayController;
  final Map<String, dynamic> _dayData;
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
              controller: dayController,
              onSaved: (value) {
                _dayData['description'] = value;
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
                  Provider.of<WorkoutPlans>(context, listen: false)
                      .addDay(Day(description: dayController.text, daysOfWeek: [1]), workout);
                  dayController.clear();
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
                decoration: InputDecoration(labelText: AppLocalizations.of(context).ingredient),
              ),
              suggestionsCallback: (pattern) async {
                return await Provider.of<Exercises>(context, listen: false)
                    .searchIngredient(pattern);
              },
              itemBuilder: (context, suggestion) {
                String serverUrl = Provider.of<Auth>(context, listen: false).serverUrl;
                print(suggestion);
                print(serverUrl);
                print('$serverUrl${suggestion["data"]["image"]}');
                return ListTile(
                  leading: Container(
                    width: 45,
                    child: suggestion['data']['image'] != null
                        ? FadeInImage(
                            placeholder: AssetImage('assets/images/placeholder.png'),
                            image: NetworkImage(serverUrl + suggestion['data']['image']),
                            fit: BoxFit.cover,
                          )
                        : Image(
                            image: AssetImage('assets/images/placeholder.png'),
                            color: Color.fromRGBO(255, 255, 255, 0.3),
                            colorBlendMode: BlendMode.modulate),
                  ),
                  title: Text(suggestion['value']),
                  subtitle: Text(suggestion['data']['id'].toString()),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (suggestion) {
                print(suggestion);
                //mealItem.ingredientId = suggestion['data']['id'];
                //this._ingredientController.text = suggestion['value'];
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please select an ingredient';
                }
                //if (mealItem.ingredientId == null) {
                //  return 'Please select an ingredient';
                //}
                return null;
              },
            ),
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
            ElevatedButton(child: Text('Save'), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
