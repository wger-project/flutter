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
import 'package:wger/locale/locales.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/workout_plan.dart';

class GymMode extends StatefulWidget {
  final WorkoutPlan _workoutPlan;
  GymMode(this._workoutPlan);

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
    return PageView(
      controller: _controller,
      children: [
        StartPage(widget._workoutPlan),
        TimerWidget(_controller),
        LogPage(_controller),
        TimerWidget(_controller),
        LogPage(_controller),
        SessionPage(),

        //MyPage2Widget(),
        //MyPage3Widget(),
      ],
    );
  }
}

class StartPage extends StatelessWidget {
  final WorkoutPlan _workoutPlan;

  StartPage(this._workoutPlan);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Gym mode',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              _workoutPlan.description,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          ElevatedButton(
            child: Text('Back to workout'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class LogPage extends StatelessWidget {
  PageController _controller;
  final _form = GlobalKey<FormState>();
  final repsController = TextEditingController();

  LogPage(this._controller);

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
              'Log',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Expanded(
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: AppLocalizations.of(context).repetitions),
                    controller: repsController,
                    onFieldSubmitted: (_) {},
                    onSaved: (newValue) {},
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).weight),
                    controller: repsController,
                    onFieldSubmitted: (_) {},
                    onSaved: (newValue) {},
                  ),
                  ElevatedButton(
                    child: Text(AppLocalizations.of(context).save),
                    onPressed: () async {},
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              _controller.nextPage(
                duration: Duration(milliseconds: 200),
                curve: Curves.bounceIn,
              );
            },
          )
        ],
      ),
    );
  }
}

class SessionPage extends StatefulWidget {
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
          Expanded(
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<int>(
                    value: impressionValue,
                    underline: Container(height: 0),
                    onChanged: (int newValue) {
                      setState(() {
                        impressionValue = newValue;
                      });
                    },
                    items: ImpressionMap.keys.map<DropdownMenuItem<int>>((int key) {
                      return DropdownMenuItem<int>(
                        value: key,
                        child: Text(
                          ImpressionMap[key],
                        ),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).notes,
                    ),
                    maxLines: 3,
                    controller: notesController,
                    keyboardType: TextInputType.multiline,
                    onFieldSubmitted: (_) {},
                    onSaved: (newValue) {},
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          decoration:
                              InputDecoration(labelText: AppLocalizations.of(context).timeStart),
                          controller: timeStartController,
                          onFieldSubmitted: (_) {},
                          onSaved: (newValue) {},
                        ),
                      ),
                      Flexible(
                        child: TextFormField(
                          decoration:
                              InputDecoration(labelText: AppLocalizations.of(context).timeEnd),
                          controller: timeEndController,
                          onFieldSubmitted: (_) {},
                          onSaved: (newValue) {},
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    child: Text(AppLocalizations.of(context).save),
                    onPressed: () async {},
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: () {},
          )
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

  Timer _timer;
  int _currentTime = 1;

  void startTimer() {
    setState(() {
      _currentTime = 0;
    });

    _timer?.cancel();

    const oneSecond = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSecond,
      (Timer timer) {
        if (_currentTime == 10) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _currentTime++;
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Timer',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ElevatedButton(
            child: Text("start"),
            onPressed: () {
              startTimer();
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                _currentTime.toString(),
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              widget._controller
                  .nextPage(duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
            },
          ),
        ],
      ),
    );
  }
}
