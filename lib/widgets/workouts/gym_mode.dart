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
import 'package:wger/helpers/json.dart';
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
  late TimeOfDay _start;

  GymMode(this._workoutDay) {
    _start = TimeOfDay.now();
  }

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

    // Build the list of exercise overview, sets and pause pages
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
        StartPage(
          _controller,
          widget._workoutDay,
        ),
        ...out,
        SessionPage(
          workoutProvider.findById(widget._workoutDay.workoutId),
          _controller,
          widget._start,
        ),
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
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          ..._day.sets.map(
            (set) {
              return Column(
                children: [
                  ...set.settingsFiltered.map((s) {
                    return Column(
                      children: [
                        Text(
                          s.exerciseObj.name,
                          style: Theme.of(context).textTheme.headline6,
                        ),
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
          ElevatedButton(
            child: Text('Start'),
            onPressed: () {
              _controller.nextPage(duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
            },
          ),
          Expanded(
            child: Container(),
          ),
          NavigationFooter(
            _controller,
            showPrevious: false,
          ),
        ],
      ),
    );
  }
}

class LogPage extends StatefulWidget {
  PageController _controller;
  Setting _setting;
  Exercise _exercise;
  WorkoutPlan _workoutPlan;
  Log _log = Log.empty();

  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _rirController = TextEditingController();

  LogPage(this._controller, this._setting, this._exercise, this._workoutPlan) {
    if (_setting.reps != null) {
      _repsController.text = _setting.reps.toString();
    }

    if (_setting.weight != null) {
      _weightController.text = _setting.weight.toString();
    }

    if (_setting.rir != null) {
      _rirController.text = _setting.rir!;
    }

    _log.date = DateTime.now();
    _log.setExercise(_exercise);
    _log.workoutPlan = _workoutPlan.id!;
    _log.repetitionUnit = _setting.repetitionUnitId;
    _log.weightUnit = _setting.weightUnitId;
  }

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final _form = GlobalKey<FormState>();
  String rirValue = Setting.defaultRiR;

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
              widget._exercise.name,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Center(
            child: Text(
              '${widget._setting.singleSettingRepText}',
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
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
                  controller: widget._repsController,
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (_) {},
                  onSaved: (newValue) {
                    widget._log.reps = int.parse(newValue!);
                  },
                  validator: (value) {
                    try {
                      int.parse(value!);
                    } catch (error) {
                      return AppLocalizations.of(context)!.enterValidNumber;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.weight),
                  controller: widget._weightController,
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (_) {},
                  onSaved: (newValue) {
                    widget._log.weight = double.parse(newValue!);
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
                DropdownButtonFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.rir),
                  value: rirValue,
                  onSaved: (String? newValue) {
                    widget._log.rir = newValue!;
                  },
                  onChanged: (String? newValue) {
                    setState(() {
                      rirValue = newValue!;
                    });
                  },
                  items: Setting.possibleRiRValues.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
                      await Provider.of<WorkoutPlans>(context, listen: false).addLog(widget._log);
                      //final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
                      //ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      widget._controller.nextPage(
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
          NavigationFooter(widget._controller),
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
  PageController _controller;
  TimeOfDay _start;

  SessionPage(this._workoutPlan, this._controller, this._start);

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
  void initState() {
    super.initState();

    timeStartController.text = timeToString(widget._start)!;
    timeEndController.text = timeToString(TimeOfDay.now())!;
    _session.workoutId = widget._workoutPlan.id!;
    _session.date = DateTime.now();
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
              AppLocalizations.of(context)!.workoutSession,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Expanded(child: Container()),
          Form(
            key: _form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButtonFormField(
                  value: impressionValue,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.impression,
                  ),
                  items: ImpressionMap.keys.map<DropdownMenuItem<int>>((int key) {
                    return DropdownMenuItem<int>(
                      value: key,
                      child: Text(ImpressionMap[key]!),
                    );
                  }).toList(),
                  onSaved: (int? newValue) {
                    _session.impression = newValue!;
                  },
                  onChanged: (int? newValue) {
                    setState(() {
                      impressionValue = newValue!;
                    });
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
                        onTap: () async {
                          // Stop keyboard from appearing
                          FocusScope.of(context).requestFocus(new FocusNode());

                          // Open time picker
                          var pickedTime = await showTimePicker(
                            context: context,
                            initialTime: widget._start,
                          );

                          timeStartController.text = timeToString(pickedTime)!;
                        },
                        onSaved: (newValue) {
                          _session.timeStart = stringToTime(newValue);
                        },
                      ),
                    ),
                    Flexible(
                      child: TextFormField(
                        decoration:
                            InputDecoration(labelText: AppLocalizations.of(context)!.timeEnd),
                        controller: timeEndController,
                        onFieldSubmitted: (_) {},
                        onTap: () async {
                          // Stop keyboard from appearing
                          FocusScope.of(context).requestFocus(new FocusNode());

                          // Open time picker
                          var pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          timeStartController.text = timeToString(pickedTime)!;
                        },
                        onSaved: (newValue) {
                          _session.timeEnd = stringToTime(newValue);
                        },
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
          NavigationFooter(
            widget._controller,
            showNext: false,
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
          Expanded(
            child: Center(
              child: Text(
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
  bool showPrevious;
  bool showNext;

  NavigationFooter(this._controller, {this.showPrevious = true, this.showNext = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Nest all widgets in an expanded so that they all take the same size
        // independently of how wide they are so that the buttons are positioned
        // always on the same spot

        Expanded(
          child: showPrevious
              ? IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    _controller.previousPage(
                        duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
                  },
                )
              : Container(),
        ),
        Expanded(
          child: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(
          child: showNext
              ? IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    _controller.nextPage(
                        duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
                  },
                )
              : Container(),
        ),
      ],
    );
  }
}
