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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/gym_mode.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/routines/forms/reps_unit.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/weight_unit.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';

class LogPage extends StatefulWidget {
  final PageController _controller;
  final SetConfigData _configData;
  final SlotData _slotData;
  final Exercise _exercise;
  final Routine _workoutPlan;
  final double _ratioCompleted;
  final Map<Exercise, int> _exercisePages;
  late Log _log;
  final int _iteration;

  LogPage(
    this._controller,
    this._configData,
    this._slotData,
    this._exercise,
    this._workoutPlan,
    this._ratioCompleted,
    this._exercisePages,
    this._iteration,
  ) {
    _log = Log.fromSetConfigData(_configData);
    _log.routineId = _workoutPlan.id!;
    _log.iteration = _iteration;
  }

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final _form = GlobalKey<FormState>();
  final _repetitionsController = TextEditingController();
  final _weightController = TextEditingController();
  var _detailed = false;
  bool _isSaving = false;

  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();

    if (widget._configData.repetitions != null) {
      _repetitionsController.text = widget._configData.repetitions!.toString();
    }

    if (widget._configData.weight != null) {
      _weightController.text = widget._configData.weight!.toString();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    _repetitionsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Widget getRepsWidget() {
    final repsValueChange = widget._configData.repetitionsRounding ?? 1;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.black),
          onPressed: () {
            try {
              final num newValue = num.parse(_repetitionsController.text) - repsValueChange;
              if (newValue > 0) {
                _repetitionsController.text = newValue.toString();
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
            controller: _repetitionsController,
            keyboardType: TextInputType.number,
            focusNode: focusNode,
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              widget._log.repetitions = num.parse(newValue!);
              focusNode.unfocus();
            },
            validator: (value) {
              try {
                num.parse(value!);
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
              final num newValue = num.parse(_repetitionsController.text) + repsValueChange;
              _repetitionsController.text = newValue.toString();
            } on FormatException {}
          },
        ),
      ],
    );
  }

  Widget getWeightWidget() {
    final weightValueChange = widget._configData.weightRounding ?? 1.25;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.black),
          onPressed: () {
            try {
              final num newValue = num.parse(_weightController.text) - (2 * weightValueChange);
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
                num.parse(value);
                setState(() {
                  widget._log.weight = num.parse(value);
                });
              } on FormatException {}
            },
            onSaved: (newValue) {
              setState(() {
                widget._log.weight = num.parse(newValue!);
              });
            },
            validator: (value) {
              try {
                num.parse(value!);
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
              final num newValue = num.parse(_weightController.text) + (2 * weightValueChange);
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
            style: Theme.of(context).textTheme.titleMedium,
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
                Flexible(
                  child: RepetitionUnitInputWidget(
                    widget._log.repetitionsUnitId,
                    onChanged: (v) => {},
                  ),
                ),
              ],
            ),
          if (_detailed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: getWeightWidget()),
                const SizedBox(width: 8),
                Flexible(
                  child: WeightUnitInputWidget(widget._log.weightUnitId, onChanged: (v) => {}),
                ),
              ],
            ),
          if (_detailed)
            RiRInputWidget(
              widget._log.rir,
              onChanged: (value) {
                if (value == '') {
                  widget._log.rir = null;
                } else {
                  widget._log.rir = num.parse(value);
                }
              },
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
            child:
                _isSaving ? const FormProgressIndicator() : Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    );
  }

  Widget getPastLogs() {
    return ListView(
      padding: const EdgeInsets.only(left: 10),
      children: [
        Text(
          AppLocalizations.of(context).labelWorkoutLogs,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.left,
        ),
        ...widget._workoutPlan.filterLogsByExercise(widget._exercise.id!, unique: true).map((log) {
          return ListTile(
            title: Text(log.singleLogRepTextNoNl),
            subtitle: Text(
                '${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(log.date)}: '
                '${widget._workoutPlan.logs.where((logs) => logs.exerciseId == log.exerciseId && log.date.day == logs.date.day && log.date.month == logs.date.month && log.date.year == logs.date.year && log.repetitions == logs.repetitions && log.weight == logs.weight).length} ${AppLocalizations.of(context).sets}'),
            trailing: const Icon(Icons.copy),
            dense: true,
            visualDensity: VisualDensity(vertical: -3),
            onTap: () {
              setState(() {
                // Text field
                _repetitionsController.text = log.repetitions?.toString() ?? '';
                _weightController.text = log.weight?.toString() ?? '';

                // Drop downs
                widget._log.rir = log.rir;
                widget._log.repetitionUnit = log.repetitionsUnitObj;
                widget._log.weightUnit = log.weightUnitObj;

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context).dataCopied),
                ));
              });
            },
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
          style: Theme.of(context).textTheme.titleMedium,
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
                          const SizedBox(width: 5),
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
    const Duration currentSetWindow = Duration(hours: -4);
    final int currentSet = 1 +
        widget._workoutPlan.logs
            .where((logs) =>
                logs.exerciseId == widget._exercise.id &&
                logs.slotEntryId == widget._log.slotEntryId &&
                logs.date.isAfter(DateTime.now().add(currentSetWindow)))
            .length;
    final int totalExerciseSets =
        widget._slotData.setConfigs.where((logs) => logs.exerciseId == widget._exercise.id).length;
    return Column(
      children: [
        NavigationHeader(
          widget._exercise.getTranslation(Localizations.localeOf(context).languageCode).name,
          widget._controller,
          exercisePages: widget._exercisePages,
        ),
        Center(
          child: Text(
            widget._configData.textRepr,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child: Text(
            '${AppLocalizations.of(context).set} $currentSet / $totalExerciseSets',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        if (widget._slotData.comment != '')
          Text(widget._slotData.comment, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Expanded(
          child: (widget._workoutPlan.filterLogsByExercise(widget._exercise.id!).isNotEmpty)
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
