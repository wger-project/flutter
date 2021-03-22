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
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/workout_plans.dart';

class GymMode extends StatefulWidget {
  final Day _workoutDay;
  GymMode(this._workoutDay);

  @override
  _GymModeState createState() => _GymModeState();
}

class _GymModeState extends State<GymMode> {
  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<Exercises>(context, listen: false);
    final workoutProvider = Provider.of<WorkoutPlans>(context, listen: false);

    List<Widget> out = [];

    for (var set in widget._workoutDay.sets) {
      var firstPage = true;
      for (var setting in set.settingsComputed) {
        if (firstPage) {
          out.add(ExerciseOverview(_controller, exerciseProvider.findById(setting.exerciseId)));
        }
        out.add(LogPage(
          _controller,
          setting,
          exerciseProvider.findById(setting.exerciseId),
          workoutProvider.findById(widget._workoutDay.workoutId),
        ));
        out.add(TimerWidget(_controller));

        firstPage = false;
      }
    }

    return PageView(
      controller: _controller,
      children: [
        StartPage(_controller, widget._workoutDay),
        ...out,
        SessionPage(workoutProvider.findById(widget._workoutDay.workoutId)),
      ],
    );
  }
}

class StartPage extends StatelessWidget {
  PageController _controller;
  final Day _day;

  StartPage(this._controller, this._day);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              AppLocalizations.of(context)!.todaysWorkout,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ..._day.sets.map(
            (set) {
              return Column(
                children: [
                  ...set.settings.map((s) {
                    return Column(
                      children: [
                        Text(s.exerciseObj.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(s.repsText),
                        SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                  Divider(),
                ],
              );
            },
          ).toList(),
          Text('Here some text on what to do, etc. etc.'),
          Expanded(
            child: Container(),
          ),
          NavigationFooter(_controller),
        ],
      ),
    );
  }
}

class LogPage extends StatelessWidget {
  PageController _controller;
  Setting _setting;
  Exercise _exercise;
  WorkoutPlan _workoutPlan;
  Log _log = Log();

  final _form = GlobalKey<FormState>();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _rirController = TextEditingController();
  final _commentController = TextEditingController();

  LogPage(this._controller, this._setting, this._exercise, this._workoutPlan) {
    if (_setting.reps != null) {
      _repsController.text = _setting.reps.toString();
    }

    if (_setting.weight != null) {
      _weightController.text = _setting.weight.toString();
    }

    if (_setting.rir != null) {
      _rirController.text = _setting.rir;
    }

    _log.date = DateTime.now();
    _log.exercise = _exercise.id;
    _log.workoutPlan = _workoutPlan.id!;
    _log.repetitionUnit = 1;
    _log.weightUnit = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              _exercise.name,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Expanded(child: Container()),
          Form(
            key: _form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.repetitions),
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (_) {},
                  onSaved: (newValue) {
                    _log.reps = int.parse(newValue!);
                  },
                  validator: (value) {
                    try {
                      double.parse(value!);
                    } catch (error) {
                      return AppLocalizations.of(context)!.enterValidNumber;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.weight),
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (_) {},
                  onSaved: (newValue) {
                    _log.weight = double.parse(newValue!);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.rir),
                  controller: _rirController,
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (_) {},
                  onSaved: (newValue) {},
                ),
                /*
                  TextFormField(
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.comment),
                    controller: _commentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    onFieldSubmitted: (_) {},
                    onSaved: (newValue) {
                      _log.
                    },
                  ),

                   */
                ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.save),
                  onPressed: () async {
                    // Validate and save the current values to the weightEntry
                    final isValid = _form.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    _form.currentState!.save();

                    // Save the entry on the server
                    try {
                      await Provider.of<WorkoutPlans>(context, listen: false).addLog(_log);
                      //final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
                      //ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      _controller.nextPage(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.bounceIn,
                      );
                    } on WgerHttpException catch (error) {
                      showHttpExceptionErrorDialog(error, context);
                    } catch (error) {
                      showErrorDialog(error, context);
                    }
                  },
                ),
              ],
            ),
          ),
          NavigationFooter(_controller),
        ],
      ),
    );
  }
}

class ExerciseOverview extends StatelessWidget {
  PageController _controller;
  Exercise _exercise;

  ExerciseOverview(this._controller, this._exercise);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              _exercise.name,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Expanded(
            child: Text(_exercise.description),
          ),
          NavigationFooter(_controller),
        ],
      ),
    );
  }
}

class SessionPage extends StatefulWidget {
  WorkoutPlan _workoutPlan;

  SessionPage(this._workoutPlan);

  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final _form = GlobalKey<FormState>();
  final impressionController = TextEditingController();
  final notesController = TextEditingController();
  final timeStartController = TextEditingController();
  final timeEndController = TextEditingController();

  int impressionValue = 2;
  var _session = WorkoutSession();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Session',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Expanded(child: Container()),
          Form(
            key: _form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FormField<int>(
                  builder: (FormFieldState<int> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.impression,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: impressionValue,
                          isDense: true,
                          onChanged: (int? newValue) {
                            setState(() {
                              impressionValue = newValue!;
                              state.didChange(newValue);
                            });
                          },
                          items: ImpressionMap.keys.map<DropdownMenuItem<int>>((int key) {
                            return DropdownMenuItem<int>(
                              value: key,
                              child: Text(
                                ImpressionMap[key]!,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.notes,
                  ),
                  maxLines: 3,
                  controller: notesController,
                  keyboardType: TextInputType.multiline,
                  onFieldSubmitted: (_) {},
                  onSaved: (newValue) {
                    _session.notes = newValue!;
                  },
                ),
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        decoration:
                            InputDecoration(labelText: AppLocalizations.of(context)!.timeStart),
                        controller: timeStartController,
                        onFieldSubmitted: (_) {},
                        onSaved: (newValue) {},
                      ),
                    ),
                    Flexible(
                      child: TextFormField(
                        decoration:
                            InputDecoration(labelText: AppLocalizations.of(context)!.timeEnd),
                        controller: timeEndController,
                        onFieldSubmitted: (_) {},
                        onSaved: (newValue) {},
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.save),
                  onPressed: () async {
                    // Validate and save the current values to the weightEntry
                    final isValid = _form.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    _form.currentState!.save();
                    _session.date = DateTime.now();
                    _session.workoutId = widget._workoutPlan.id!;
                    _session.impression = impressionValue;

                    // Save the entry on the server
                    try {
                      await Provider.of<WorkoutPlans>(context, listen: false).addSession(_session);
                      Navigator.of(context).pop();
                    } on WgerHttpException catch (error) {
                      showHttpExceptionErrorDialog(error, context);
                    } catch (error) {
                      showErrorDialog(error, context);
                    }
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class TimerWidget extends StatefulWidget {
  PageController _controller;

  TimerWidget(this._controller);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // See https://stackoverflow.com/questions/54610121/flutter-countdown-timer

  Timer? _timer;
  int _seconds = 1;
  final _maxSeconds = 600;
  DateTime today = new DateTime(2000, 1, 1, 0, 0, 0);

  void startTimer() {
    setState(() {
      _seconds = 0;
    });

    _timer?.cancel();

    const oneSecond = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSecond,
      (Timer timer) {
        if (_seconds == _maxSeconds) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _seconds++;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Timer',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          /*
          ElevatedButton(
            child: Text("start"),
            onPressed: () {
              startTimer();
            },
          ),

           */
          Expanded(
            child: Center(
              child: Text(
                //'${_seconds} sec',
                DateFormat('m:ss').format(today.add(Duration(seconds: _seconds))),
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
          ),
          NavigationFooter(widget._controller),
        ],
      ),
    );
  }
}

class NavigationFooter extends StatelessWidget {
  final PageController _controller;

  NavigationFooter(this._controller);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            _controller.previousPage(duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
          },
        ),
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () {
            _controller.nextPage(duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
          },
        ),
      ],
    );
  }
}
