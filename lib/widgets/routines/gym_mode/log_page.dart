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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/providers/plate_weights.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/configure_plates.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/routines/forms/reps_unit.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/weight_unit.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';
import 'package:wger/widgets/routines/plate_calculator.dart';

class LogPage extends ConsumerStatefulWidget {
  final PageController _controller;
  final SetConfigData _configData;
  final SlotData _slotData;
  final Exercise _exercise;
  final Routine _workoutPlan;
  final double _ratioCompleted;
  final Map<Exercise, int> _exercisePages;
  final Log _log;

  LogPage(
    this._controller,
    this._configData,
    this._slotData,
    this._exercise,
    this._workoutPlan,
    this._ratioCompleted,
    this._exercisePages,
    int? iteration,
  ) : _log = Log.fromSetConfigData(_configData)
          ..routineId = _workoutPlan.id!
          ..iteration = iteration;

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends ConsumerState<LogPage> {
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
            onFieldSubmitted: (_) {
              // Placeholder for potential future logic
            },
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
                  ref.read(plateCalculatorProvider.notifier).setWeight(
                        _weightController.text == '' ? 0 : double.parse(_weightController.text),
                      );
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
            onFieldSubmitted: (_) {
              // Placeholder for potential future logic
            },
            onChanged: (value) {
              try {
                num.parse(value);
                setState(() {
                  widget._log.weight = num.parse(value);
                  ref.read(plateCalculatorProvider.notifier).setWeight(
                        _weightController.text == '' ? 0 : double.parse(_weightController.text),
                      );
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
                ref.read(plateCalculatorProvider.notifier).setWeight(
                      _weightController.text == '' ? 0 : double.parse(_weightController.text),
                    );
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
                Flexible(
                  child: RepetitionUnitInputWidget(
                    widget._log.repetitionsUnitId,
                    onChanged: (v) => {},
                  ),
                ),
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
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
            dense: true,
            title: Text(AppLocalizations.of(context).setUnitsAndRir),
            value: _detailed,
            onChanged: (value) {
              setState(() {
                _detailed = !_detailed;
              });
            },
          ),
          FilledButton(
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
                    } on WgerHttpException {
                      _isSaving = false;

                      rethrow;
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          // color: Theme.of(context).secondaryHeaderColor,
          // color: Theme.of(context).splashColor,
          // color: Theme.of(context).colorScheme.onInverseSurface,
          // border: Border.all(color: Colors.black, width: 1),
          ),
      child: ListView(
        children: [
          Text(
            AppLocalizations.of(context).labelWorkoutLogs,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          ...widget._workoutPlan
              .filterLogsByExercise(widget._exercise.id!, unique: true)
              .map((log) {
            return ListTile(
              title: Text(log.singleLogRepTextNoNl),
              subtitle: Text(
                DateFormat.yMd(Localizations.localeOf(context).languageCode).format(log.date),
              ),
              trailing: const Icon(Icons.copy),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 40),
            );
          }),
        ],
      ),
    );
  }

  Widget getPlates() {
    final plateWeightsState = ref.watch(plateCalculatorProvider);

    return Container(
      color: Theme.of(context).colorScheme.onInverseSurface,
      child: Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text(
          //       AppLocalizations.of(context).plateCalculator,
          //       style: Theme.of(context).textTheme.titleMedium,
          //     ),
          //     IconButton(
          //       onPressed: () {
          //         Navigator.of(context)
          //             .push(MaterialPageRoute(builder: (context) => const AddPlateWeights()));
          //       },
          //       icon: const Icon(Icons.settings, size: 16),
          //     ),
          //   ],
          // ),
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const ConfigureAvailablePlates()));
            },
            child: SizedBox(
              child: plateWeightsState.hasPlates
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...plateWeightsState.calculatePlates.entries.map(
                          (entry) => Row(
                            children: [
                              Text(entry.value.toString()),
                              const Text('×'),
                              PlateWeight(
                                value: entry.key,
                                size: 37,
                                padding: 2,
                                margin: 0,
                                color: ref.read(plateCalculatorProvider).getColor(entry.key),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: MutedText(
                        AppLocalizations.of(context).plateCalculatorNotDivisible,
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationHeader(
          widget._exercise.getTranslation(Localizations.localeOf(context).languageCode).name,
          widget._controller,
          exercisePages: widget._exercisePages,
        ),

        Container(
          color: Theme.of(context).colorScheme.onInverseSurface,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              widget._configData.textRepr,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (widget._slotData.comment.isNotEmpty)
          Text(widget._slotData.comment, textAlign: TextAlign.center),
        // Only show calculator for barbell
        if (widget._log.exercise.equipment.map((e) => e.id).contains(ID_EQUIPMENT_BARBELL))
          getPlates(),
        const SizedBox(height: 10),
        Expanded(
          child: (widget._workoutPlan.filterLogsByExercise(widget._exercise.id!).isNotEmpty)
              ? getPastLogs()
              : Container(),
        ),

        Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            color: Theme.of(context).colorScheme.inversePrimary,
            // color: Theme.of(context).secondaryHeaderColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: getForm(),
            ),
          ),
        ),
        NavigationFooter(widget._controller, widget._ratioCompleted),
      ],
    );
  }
}
