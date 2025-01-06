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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'as provider;
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/gym_mode.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/exercises/images.dart';
import 'package:wger/widgets/routines/forms/reps_unit.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/weight_unit.dart';

class GymMode extends ConsumerStatefulWidget {
  final DayData _dayData;
  late final TimeOfDay _start;

  GymMode(this._dayData) {
    _start = TimeOfDay.now();
  }

  @override
  ConsumerState<GymMode> createState() => _GymModeState();
}


class _GymModeState extends ConsumerState<GymMode> {
  var _totalElements = 1;

  /// Map with the first (navigation) page for each exercise
  final Map<Exercise, int> _exercisePages = {};
  late final PageController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();

  }

  @override
  void initState() {
    super.initState();
    final initialPage = ref.read(gymStateProvider).currentPage;
    _controller = PageController(initialPage: initialPage);
    Future.microtask(() => _calculatePages());
  }
  void _calculatePages() {
    for (final slot in widget._dayData.slots) {
      _totalElements += slot.setConfigs.length;
    }

    var currentPage = 1;
    final Map<Exercise, int> exercisePages = {};

    for (final slot in widget._dayData.slots) {
      var firstPage = true;
      for (final config in slot.setConfigs) {
        final exercise = provider.Provider.of<ExercisesProvider>(context, listen: false)
            .findExerciseById(config.exerciseId);

        if (firstPage) {
          exercisePages[exercise] = currentPage;
          currentPage++;
        }
        currentPage += 2;
        firstPage = false;
      }
    }

    ref.read(gymStateProvider.notifier).setExercisePages(exercisePages);
  }

  List<Widget> getContent() {
    final state = ref.watch(gymStateProvider);
    final exerciseProvider = provider.Provider.of<ExercisesProvider>(context, listen: false);
    final workoutProvider = provider.Provider.of<RoutinesProvider>(context, listen: false);
    var currentElement = 1;
    final List<Widget> out = [];

    for (final slotData in widget._dayData.slots) {
      var firstPage = true;
      for (final config in slotData.setConfigs) {
        final ratioCompleted = currentElement / _totalElements;
        final exercise = exerciseProvider.findExerciseById(config.exerciseId);
        currentElement++;

        if (firstPage && state.showExercisePages) {
          out.add(ExerciseOverview(
            _controller,
            exercise,
            ratioCompleted,
            state.exercisePages,
          ));
        }

        out.add(LogPage(
          _controller,
          config,
          slotData,
          exercise,
          workoutProvider.findById(widget._dayData.day!.routineId),
          ratioCompleted,
          state.exercisePages,
        ));
        out.add(TimerWidget(_controller, ratioCompleted, state.exercisePages));
        firstPage = false;
      }
    }

    return out;
  }
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      onPageChanged: (page) => ref.read(gymStateProvider.notifier).setCurrentPage(page),
      children: [
        StartPage(_controller, widget._dayData.day!, _exercisePages),
        ...getContent(),
        SessionPage(
          provider.Provider.of<RoutinesProvider>(context, listen: false)
              .findById(widget._dayData.day!.routineId),
          _controller,
          widget._start,
          _exercisePages,
        ),
      ],
    );
  }
}

class StartPage extends StatelessWidget {
  final PageController _controller;
  final Day _day;
  final Map<Exercise, int> _exercisePages;

  const StartPage(this._controller, this._day, this._exercisePages);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).todaysWorkout,
          _controller,
          exercisePages: _exercisePages,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            children: [
              ..._day.slots.map((slot) {
                return Column(
                  children: [
                    ...slot.entries.map((entry) {
                      return Column(
                        children: [
                          Text(
                            entry.exerciseObj
                                .getExercise(Localizations.localeOf(context).languageCode)
                                .name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Text('TODO'),
                          const SizedBox(height: 15),
                        ],
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
        FilledButton(
          child: Text(AppLocalizations.of(context).start),
          onPressed: () {
            _controller.nextPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.bounceIn,
            );
          },
        ),
        NavigationFooter(_controller, 0, showPrevious: false),
      ],
    );
  }
}

class LogPage extends StatefulWidget {
  final PageController _controller;
  final SetConfigData _configData;
  final SlotData _slotData;
  final Exercise _exercise;
  final Routine _workoutPlan;
  final double _ratioCompleted;
  final Map<Exercise, int> _exercisePages;
  final Log _log = Log.empty();

  LogPage(
    this._controller,
    this._configData,
    this._slotData,
    this._exercise,
    this._workoutPlan,
    this._ratioCompleted,
    this._exercisePages,
  ) {
    _log.date = DateTime.now();
    _log.routineId = _workoutPlan.id!;
    _log.exerciseBase = _exercise;
    _log.weightUnit = _configData.weightUnit;
    _log.repetitionUnit = _configData.repsUnit;
    _log.rir = _configData.rir;
  }

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final _form = GlobalKey<FormState>();
  String rirValue = SlotEntry.DEFAULT_RIR;
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  var _detailed = false;
  bool _isSaving = false;

  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();

    if (widget._configData.reps != null) {
      _repsController.text = widget._configData.reps!.toString();
    }

    if (widget._configData.weight != null) {
      _weightController.text = widget._configData.weight!.toString();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Widget getRepsWidget() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.black),
          onPressed: () {
            try {
              final int newValue = int.parse(_repsController.text) - 1;
              if (newValue > 0) {
                _repsController.text = newValue.toString();
              }
            } on FormatException {}
          },
        ),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).repetitions,
            ),
            enabled: true,
            controller: _repsController,
            keyboardType: TextInputType.number,
            focusNode: focusNode,
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              widget._log.reps = int.parse(newValue!);
              focusNode.unfocus();
            },
            validator: (value) {
              try {
                int.parse(value!);
              } catch (error) {
                return AppLocalizations.of(context).enterValidNumber;
              }
              return null;
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            try {
              final int newValue = int.parse(_repsController.text) + 1;
              _repsController.text = newValue.toString();
            } on FormatException {}
          },
        ),
      ],
    );
  }

  Widget getWeightWidget() {
    const minPlateWeight = 1.25;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.black),
          onPressed: () {
            try {
              final double newValue = double.parse(_weightController.text) - (2 * minPlateWeight);
              if (newValue > 0) {
                setState(() {
                  widget._log.weight = newValue;
                  _weightController.text = newValue.toString();
                });
              }
            } on FormatException {}
          },
        ),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).weight,
            ),
            controller: _weightController,
            keyboardType: TextInputType.number,
            onFieldSubmitted: (_) {},
            onChanged: (value) {
              try {
                double.parse(value);
                setState(() {
                  widget._log.weight = double.parse(value);
                });
              } on FormatException {}
            },
            onSaved: (newValue) {
              setState(() {
                widget._log.weight = double.parse(newValue!);
              });
            },
            validator: (value) {
              try {
                double.parse(value!);
              } catch (error) {
                return AppLocalizations.of(context).enterValidNumber;
              }
              return null;
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            try {
              final double newValue = double.parse(_weightController.text) + (2 * minPlateWeight);
              setState(() {
                widget._log.weight = newValue;
                _weightController.text = newValue.toString();
              });
            } on FormatException {}
          },
        ),
      ],
    );
  }

  Widget getForm() {
    return Form(
      key: _form,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).newEntry,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (!_detailed)
            Row(
              children: [
                Flexible(child: getRepsWidget()),
                const SizedBox(width: 8),
                Flexible(child: getWeightWidget()),
              ],
            ),
          if (_detailed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: getRepsWidget()),
                const SizedBox(width: 8),
                Flexible(child: RepetitionUnitInputWidget(widget._log)),
              ],
            ),
          if (_detailed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: getWeightWidget()),
                const SizedBox(width: 8),
                Flexible(child: WeightUnitInputWidget(widget._log)),
              ],
            ),
          if (_detailed)
            RiRInputWidget(
              widget._log.rir == null ? null : num.parse(widget._log.rir!),
              onChanged: (v) => {},
            ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).setUnitsAndRir),
            value: _detailed,
            onChanged: (value) {
              setState(() {
                _detailed = !_detailed;
              });
            },
          ),
          ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      // Validate and save the current values to the weightEntry
                      final isValid = _form.currentState!.validate();
                      if (!isValid) {
                        return;
                      }
                      _isSaving = true;
                      _form.currentState!.save();

                      // Save the entry on the server
                      try {
                        await provider.Provider.of<RoutinesProvider>(
                          context,
                          listen: false,
                        ).addLog(widget._log);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 2), // default is 4
                            content: Text(
                              AppLocalizations.of(context).successfullySaved,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                        widget._controller.nextPage(
                          duration: DEFAULT_ANIMATION_DURATION,
                          curve: DEFAULT_ANIMATION_CURVE,
                        );
                        _isSaving = false;
                      } on WgerHttpException catch (error) {
                        if (mounted) {
                          showHttpExceptionErrorDialog(error, context);
                        }
                        _isSaving = false;
                      } catch (error) {
                        if (mounted) {
                          showErrorDialog(error, context);
                        }
                        _isSaving = false;
                      }
                    },
              child: _isSaving
                  ? const FormProgressIndicator()
                  : Text(AppLocalizations.of(context).save)),
        ],
      ),
    );
  }

  Widget getPastLogs() {
    return ListView(
      children: [
        Text(
          AppLocalizations.of(context).labelWorkoutLogs,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        ...widget._workoutPlan.filterLogsByExercise(widget._exercise, unique: true).map((log) {
          return ListTile(
            title: Text(log.singleLogRepTextNoNl),
            subtitle: Text(
              DateFormat.yMd(Localizations.localeOf(context).languageCode).format(log.date),
            ),
            trailing: const Icon(Icons.copy),
            onTap: () {
              setState(() {
                // Text field
                _repsController.text = log.reps.toString();
                _weightController.text = log.weight.toString();

                // Drop downs
                widget._log.rir = log.rir;
                widget._log.repetitionUnit = log.repetitionUnitObj;
                widget._log.weightUnit = log.weightUnitObj;

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context).dataCopied),
                ));
              });
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 40),
          );
        }),
      ],
    );
  }

  Widget getPlates() {
    final plates = plateCalculator(
      double.parse(_weightController.text == '' ? '0' : _weightController.text),
      BAR_WEIGHT,
      AVAILABLE_PLATES,
    );
    final groupedPlates = groupPlates(plates);

    return Column(
      children: [
        Text(
          AppLocalizations.of(context).plateCalculator,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(
          height: 35,
          child: plates.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...groupedPlates.keys.map(
                      (key) => Row(
                        children: [
                          Text(groupedPlates[key].toString()),
                          const Text('×'),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: SizedBox(
                                height: 35,
                                width: 35,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    key.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                )
              : MutedText(
                  AppLocalizations.of(context).plateCalculatorNotDivisible,
                ),
        ),
        const SizedBox(height: 3),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationHeader(
          widget._exercise.getExercise(Localizations.localeOf(context).languageCode).name,
          widget._controller,
          exercisePages: widget._exercisePages,
        ),
        Center(
          child: Text(
            widget._configData.textRepr,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
        if (widget._slotData.comment != '')
          Text(widget._slotData.comment, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Expanded(
          child: (widget._workoutPlan.filterLogsByExercise(widget._exercise).isNotEmpty)
              ? getPastLogs()
              : Container(),
        ),
        // Only show calculator for barbell
        if (widget._log.exercise.equipment.map((e) => e.id).contains(ID_EQUIPMENT_BARBELL))
          getPlates(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Card(child: getForm()),
        ),
        NavigationFooter(widget._controller, widget._ratioCompleted),
      ],
    );
  }
}

class ExerciseOverview extends StatelessWidget {
  final PageController _controller;
  final Exercise _exerciseBase;
  final double _ratioCompleted;
  final Map<Exercise, int> _exercisePages;

  const ExerciseOverview(
    this._controller,
    this._exerciseBase,
    this._ratioCompleted,
    this._exercisePages,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationHeader(
          _exerciseBase.getExercise(Localizations.localeOf(context).languageCode).name,
          _controller,
          exercisePages: _exercisePages,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              Text(
                getTranslation(_exerciseBase.category!.name, context),
                semanticsLabel: getTranslation(_exerciseBase.category!.name, context),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              ..._exerciseBase.equipment.map((e) => Text(
                    getTranslation(e.name, context),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  )),
              if (_exerciseBase.images.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._exerciseBase.images.map((e) => ExerciseImageWidget(image: e)),
                    ],
                  ),
                ),
              Html(
                data: _exerciseBase
                    .getExercise(Localizations.localeOf(context).languageCode)
                    .description,
              ),
            ],
          ),
        ),
        NavigationFooter(_controller, _ratioCompleted),
      ],
    );
  }
}

class SessionPage extends StatefulWidget {
  final Routine _workoutPlan;
  final PageController _controller;
  final TimeOfDay _start;
  final Map<Exercise, int> _exercisePages;

  const SessionPage(
    this._workoutPlan,
    this._controller,
    this._start,
    this._exercisePages,
  );

  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final _form = GlobalKey<FormState>();
  final impressionController = TextEditingController();
  final notesController = TextEditingController();
  final timeStartController = TextEditingController();
  final timeEndController = TextEditingController();

  final _session = WorkoutSession.now();

  /// Selected impression: bad, neutral, good
  var selectedImpression = [false, true, false];

  @override
  void initState() {
    super.initState();

    timeStartController.text = timeToString(widget._start)!;
    timeEndController.text = timeToString(TimeOfDay.now())!;
    _session.routineId = widget._workoutPlan.id!;
    _session.impression = DEFAULT_IMPRESSION;
    _session.date = DateTime.now();
  }

  @override
  void dispose() {
    impressionController.dispose();
    notesController.dispose();
    timeStartController.dispose();
    timeEndController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).workoutSession,
          widget._controller,
          exercisePages: widget._exercisePages,
        ),
        const Divider(),
        Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ToggleButtons(
                  renderBorder: false,
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < selectedImpression.length;
                          buttonIndex++) {
                        _session.impression = index + 1;

                        if (buttonIndex == index) {
                          selectedImpression[buttonIndex] = true;
                        } else {
                          selectedImpression[buttonIndex] = false;
                        }
                      }
                    });
                  },
                  isSelected: selectedImpression,
                  children: const [
                    Icon(Icons.sentiment_very_dissatisfied),
                    Icon(Icons.sentiment_neutral),
                    Icon(Icons.sentiment_very_satisfied),
                  ],
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).notes,
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
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).timeStart,
                          errorMaxLines: 2,
                        ),
                        controller: timeStartController,
                        onFieldSubmitted: (_) {},
                        onTap: () async {
                          // Stop keyboard from appearing
                          FocusScope.of(context).requestFocus(FocusNode());

                          // Open time picker
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: _session.timeStart,
                          );

                          if (pickedTime != null) {
                            timeStartController.text = timeToString(pickedTime)!;
                            _session.timeStart = pickedTime;
                          }
                        },
                        onSaved: (newValue) {
                          _session.timeStart = stringToTime(newValue);
                        },
                        validator: (_) {
                          final TimeOfDay startTime = stringToTime(timeStartController.text);
                          final TimeOfDay endTime = stringToTime(timeEndController.text);
                          if (startTime.isAfter(endTime)) {
                            return AppLocalizations.of(context).timeStartAhead;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).timeEnd,
                        ),
                        controller: timeEndController,
                        onFieldSubmitted: (_) {},
                        onTap: () async {
                          // Stop keyboard from appearing
                          FocusScope.of(context).requestFocus(FocusNode());

                          // Open time picker
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: _session.timeEnd,
                          );

                          if (pickedTime != null) {
                            timeEndController.text = timeToString(pickedTime)!;
                            _session.timeEnd = pickedTime;
                          }
                        },
                        onSaved: (newValue) {
                          _session.timeEnd = stringToTime(newValue);
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  child: Text(AppLocalizations.of(context).save),
                  onPressed: () async {
                    // Validate and save the current values to the weightEntry
                    final isValid = _form.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    _form.currentState!.save();

                    // Save the entry on the server
                    try {
                      await provider.Provider.of<RoutinesProvider>(
                        context,
                        listen: false,
                      ).addSession(_session);
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    } on WgerHttpException catch (error) {
                      if (mounted) {
                        showHttpExceptionErrorDialog(error, context);
                      }
                    } catch (error) {
                      if (mounted) {
                        showErrorDialog(error, context);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        NavigationFooter(widget._controller, 1, showNext: false),
      ],
    );
  }
}

class TimerWidget extends StatefulWidget {
  final PageController _controller;
  final double _ratioCompleted;
  final Map<Exercise, int> _exercisePages;

  const TimerWidget(
    this._controller,
    this._ratioCompleted,
    this._exercisePages,
  );

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  // See https://stackoverflow.com/questions/54610121/flutter-countdown-timer

  Timer? _timer;
  int _seconds = 1;
  final _maxSeconds = 600;
  DateTime today = DateTime(2000, 1, 1, 0, 0, 0);

  void startTimer() {
    setState(() {
      _seconds = 0;
    });

    _timer?.cancel();

    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (Timer timer) {
      if (_seconds == _maxSeconds) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).pause,
          widget._controller,
          exercisePages: widget._exercisePages,
        ),
        Expanded(
          child: Center(
            child: Text(
              DateFormat('m:ss').format(today.add(Duration(seconds: _seconds))),
              style: Theme.of(context).textTheme.displayLarge!.copyWith(color: wgerPrimaryColor),
            ),
          ),
        ),
        NavigationFooter(widget._controller, widget._ratioCompleted),
      ],
    );
  }
}

class NavigationFooter extends StatelessWidget {
  final PageController _controller;
  final double _ratioCompleted;
  final bool showPrevious;
  final bool showNext;

  const NavigationFooter(
    this._controller,
    this._ratioCompleted, {
    this.showPrevious = true,
    this.showNext = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showPrevious)
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _controller.previousPage(
                duration: DEFAULT_ANIMATION_DURATION,
                curve: DEFAULT_ANIMATION_CURVE,
              );
            },
          )
        else
          const SizedBox(width: 48),
        Expanded(
          child: LinearProgressIndicator(
            minHeight: 1.5,
            value: _ratioCompleted,
            valueColor: const AlwaysStoppedAnimation<Color>(wgerPrimaryColor),
          ),
        ),
        if (showNext)
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _controller.nextPage(
                duration: DEFAULT_ANIMATION_DURATION,
                curve: DEFAULT_ANIMATION_CURVE,
              );
            },
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}

class NavigationHeader extends StatelessWidget {
  final PageController _controller;
  final String _title;
  final Map<Exercise, int> exercisePages;

  const NavigationHeader(
    this._title,
    this._controller, {
    required this.exercisePages,
  });

  Widget getDialog(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).jumpTo,
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          children: [
            ...exercisePages.keys.map((e) {
              return ListTile(
                title: Text(e.getExercise(Localizations.localeOf(context).languageCode).name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _controller.animateToPage(
                    exercisePages[e]!,
                    duration: DEFAULT_ANIMATION_DURATION,
                    curve: DEFAULT_ANIMATION_CURVE,
                  );
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              _title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.toc),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => getDialog(context),
            );
          },
        ),
      ],
    );
  }
}
