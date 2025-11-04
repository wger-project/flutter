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
import 'package:logging/logging.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/plate_weights.dart';
import 'package:wger/providers/workout_logs.dart';
import 'package:wger/screens/configure_plates_screen.dart';
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
  final Routine _routine;
  final double _ratioCompleted;
  final Map<Exercise, int> _exercisePages;
  final Log _log;
  final int _totalPages;

  LogPage(
    this._controller,
    this._configData,
    this._slotData,
    this._exercise,
    this._routine,
    this._ratioCompleted,
    this._exercisePages,
    this._totalPages,
    int? iteration,
  ) : _log = Log.fromSetConfigData(_configData)
        ..routineId = _routine.id!
        ..iteration = iteration;

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends ConsumerState<LogPage> {
  final GlobalKey<_LogFormWidgetState> _logFormKey = GlobalKey<_LogFormWidgetState>();

  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        NavigationHeader(
          widget._exercise.getTranslation(Localizations.localeOf(context).languageCode).name,
          widget._controller,
          totalPages: widget._totalPages,
          exercisePages: widget._exercisePages,
        ),

        Container(
          color: theme.colorScheme.onInverseSurface,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Column(
              children: [
                Text(
                  widget._configData.textRepr,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget._configData.type != SlotEntryType.normal)
                  Text(
                    widget._configData.type.name.toUpperCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
        if (widget._log.exercise.showPlateCalculator) const LogsPlatesWidget(),
        if (widget._slotData.comment.isNotEmpty)
          Text(widget._slotData.comment, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Expanded(
          child: (widget._routine.filterLogsByExercise(widget._exercise.id!).isNotEmpty)
              ? LogsPastLogsWidget(
                  log: widget._log,
                  pastLogs: widget._routine.filterLogsByExercise(widget._exercise.id!),
                  onCopy: (pastLog) {
                    _logFormKey.currentState?.copyFromPastLog(pastLog);
                  },
                  setStateCallback: (fn) {
                    setState(fn);
                  },
                )
              : Container(),
        ),

        Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            color: Theme.of(context).colorScheme.inversePrimary,
            // color: Theme.of(context).secondaryHeaderColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: LogFormWidget(
                key: _logFormKey,
                controller: widget._controller,
                configData: widget._configData,
                log: widget._log,
                focusNode: focusNode,
              ),
            ),
          ),
        ),
        NavigationFooter(widget._controller, widget._ratioCompleted),
      ],
    );
  }
}

class LogsPlatesWidget extends ConsumerWidget {
  const LogsPlatesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plateWeightsState = ref.watch(plateCalculatorProvider);

    return Container(
      color: Theme.of(context).colorScheme.onInverseSurface,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ConfigurePlatesScreen.routeName);
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
}

class LogsRepsWidget extends StatelessWidget {
  final TextEditingController controller;
  final SetConfigData configData;
  final FocusNode focusNode;
  final Log log;
  final void Function(VoidCallback fn) setStateCallback;

  final _logger = Logger('LogsRepsWidget');

  LogsRepsWidget({
    super.key,
    required this.controller,
    required this.configData,
    required this.focusNode,
    required this.log,
    required this.setStateCallback,
  });

  @override
  Widget build(BuildContext context) {
    final repsValueChange = configData.repetitionsRounding ?? 1;
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    final i18n = AppLocalizations.of(context);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.black),
          onPressed: () {
            final currentValue = numberFormat.tryParse(controller.text) ?? 0;
            final newValue = currentValue - repsValueChange;
            if (newValue >= 0) {
              setStateCallback(() {
                log.repetitions = newValue;
                controller.text = numberFormat.format(newValue);
              });
            }
          },
        ),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: i18n.repetitions),
            enabled: true,
            controller: controller,
            keyboardType: textInputTypeDecimal,
            focusNode: focusNode,
            onChanged: (value) {
              try {
                final newValue = numberFormat.parse(value);
                setStateCallback(() {
                  log.repetitions = newValue;
                });
              } on FormatException catch (error) {
                _logger.fine('Error parsing repetitions: $error');
              }
            },
            onSaved: (newValue) {
              _logger.info('Saving new reps value: $newValue');
              setStateCallback(() {
                log.repetitions = numberFormat.parse(newValue!);
              });
            },
            validator: (value) {
              if (numberFormat.tryParse(value ?? '') == null) {
                return i18n.enterValidNumber;
              }
              return null;
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            try {
              final newValue = numberFormat.parse(controller.text) + repsValueChange;
              setStateCallback(() {
                log.repetitions = newValue;
                controller.text = numberFormat.format(newValue);
              });
            } on FormatException catch (error) {
              _logger.fine('Error parsing reps during quick-add: $error');
            }
          },
        ),
      ],
    );
  }
}

class LogsWeightWidget extends ConsumerWidget {
  final TextEditingController controller;
  final SetConfigData configData;
  final FocusNode focusNode;
  final Log log;
  final void Function(VoidCallback fn) setStateCallback;

  final _logger = Logger('LogsWeightWidget');

  LogsWeightWidget({
    super.key,
    required this.controller,
    required this.configData,
    required this.focusNode,
    required this.log,
    required this.setStateCallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightValueChange = configData.weightRounding ?? 1.25;
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final i18n = AppLocalizations.of(context);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.black),
          onPressed: () {
            try {
              final newValue = numberFormat.parse(controller.text) - weightValueChange;
              if (newValue > 0) {
                setStateCallback(() {
                  log.weight = newValue;
                  controller.text = numberFormat.format(newValue);
                  ref
                      .read(plateCalculatorProvider.notifier)
                      .setWeight(
                        controller.text == '' ? 0 : newValue,
                      );
                });
              }
            } on FormatException catch (error) {
              _logger.fine('Error parsing weight during quick-remove: $error');
            }
          },
        ),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: i18n.weight),
            controller: controller,
            keyboardType: textInputTypeDecimal,
            onChanged: (value) {
              try {
                final newValue = numberFormat.parse(value);
                setStateCallback(() {
                  log.weight = newValue;
                  ref
                      .read(plateCalculatorProvider.notifier)
                      .setWeight(
                        controller.text == '' ? 0 : numberFormat.parse(controller.text),
                      );
                });
              } on FormatException catch (error) {
                _logger.fine('Error parsing weight: $error');
              }
            },
            onSaved: (newValue) {
              setStateCallback(() {
                log.weight = numberFormat.parse(newValue!);
              });
            },
            validator: (value) {
              if (numberFormat.tryParse(value ?? '') == null) {
                return i18n.enterValidNumber;
              }
              return null;
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            try {
              final newValue = numberFormat.parse(controller.text) + weightValueChange;
              setStateCallback(() {
                log.weight = newValue;
                controller.text = numberFormat.format(newValue);
                ref
                    .read(plateCalculatorProvider.notifier)
                    .setWeight(
                      controller.text == '' ? 0 : newValue,
                    );
              });
            } on FormatException catch (error) {
              _logger.fine('Error parsing weight during quick-add: $error');
            }
          },
        ),
      ],
    );
  }
}

class LogsPastLogsWidget extends StatelessWidget {
  final Log log;
  final List<Log> pastLogs;
  final void Function(Log pastLog) onCopy;
  final void Function(VoidCallback fn) setStateCallback;

  const LogsPastLogsWidget({
    super.key,
    required this.log,
    required this.pastLogs,
    required this.onCopy,
    required this.setStateCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        children: [
          Text(
            AppLocalizations.of(context).labelWorkoutLogs,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          ...pastLogs.map((pastLog) {
            return ListTile(
              title: Text(pastLog.singleLogRepTextNoNl),
              subtitle: Text(
                DateFormat.yMd(Localizations.localeOf(context).languageCode).format(pastLog.date),
              ),
              trailing: const Icon(Icons.copy),
              onTap: () {
                setStateCallback(() {
                  log.rir = pastLog.rir;
                  log.repetitionUnit = pastLog.repetitionsUnitObj;
                  log.weightUnit = pastLog.weightUnitObj;

                  onCopy(pastLog);

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).dataCopied),
                    ),
                  );
                });
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 40),
            );
          }),
        ],
      ),
    );
  }
}

class LogFormWidget extends ConsumerStatefulWidget {
  final PageController controller;
  final SetConfigData configData;
  final Log log;
  final FocusNode focusNode;

  const LogFormWidget({
    super.key,
    required this.controller,
    required this.configData,
    required this.log,
    required this.focusNode,
  });

  @override
  _LogFormWidgetState createState() => _LogFormWidgetState();
}

class _LogFormWidgetState extends ConsumerState<LogFormWidget> {
  final _form = GlobalKey<FormState>();
  var _detailed = false;
  bool _isSaving = false;

  late final TextEditingController _repetitionsController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();

    _repetitionsController = TextEditingController();
    _weightController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = Localizations.localeOf(context).toString();
      final numberFormat = NumberFormat.decimalPattern(locale);

      if (widget.configData.repetitions != null) {
        _repetitionsController.text = numberFormat.format(widget.configData.repetitions);
      }

      if (widget.configData.weight != null) {
        _weightController.text = numberFormat.format(widget.configData.weight);
      }
    });
  }

  @override
  void dispose() {
    _repetitionsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void copyFromPastLog(Log pastLog) {
    final locale = Localizations.localeOf(context).toString();
    final numberFormat = NumberFormat.decimalPattern(locale);

    setState(() {
      _repetitionsController.text = pastLog.repetitions != null
          ? numberFormat.format(pastLog.repetitions)
          : '';
      _weightController.text = pastLog.weight != null ? numberFormat.format(pastLog.weight) : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final logProvider = ref.watch(workoutLogProvider.notifier);

    return Form(
      key: _form,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            i18n.newEntry,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (!_detailed)
            Row(
              children: [
                Flexible(
                  child: LogsRepsWidget(
                    controller: _repetitionsController,
                    configData: widget.configData,
                    focusNode: widget.focusNode,
                    log: widget.log,
                    setStateCallback: (fn) {
                      setState(fn);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: LogsWeightWidget(
                    controller: _weightController,
                    configData: widget.configData,
                    focusNode: widget.focusNode,
                    log: widget.log,
                    setStateCallback: (fn) {
                      setState(fn);
                    },
                  ),
                ),
              ],
            ),
          if (_detailed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: LogsRepsWidget(
                    controller: _repetitionsController,
                    configData: widget.configData,
                    focusNode: widget.focusNode,
                    log: widget.log,
                    setStateCallback: (fn) {
                      setState(fn);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: RepetitionUnitInputWidget(
                    widget.log.repetitionsUnitId,
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
                Flexible(
                  child: LogsWeightWidget(
                    controller: _weightController,
                    configData: widget.configData,
                    focusNode: widget.focusNode,
                    log: widget.log,
                    setStateCallback: (fn) {
                      setState(fn);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: WeightUnitInputWidget(widget.log.weightUnitId, onChanged: (v) => {}),
                ),
                const SizedBox(width: 8),
              ],
            ),
          if (_detailed)
            RiRInputWidget(
              widget.log.rir,
              onChanged: (value) {
                if (value == '') {
                  widget.log.rir = null;
                } else {
                  widget.log.rir = num.parse(value);
                }
              },
            ),
          SwitchListTile(
            dense: true,
            title: Text(i18n.setUnitsAndRir),
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
                    final isValid = _form.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    setState(() {
                      _isSaving = true;
                    });
                    _form.currentState!.save();

                    widget.log.id = null;
                    logProvider.addEntry(widget.log);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          content: Text(
                            i18n.successfullySaved,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    widget.controller.nextPage(
                      duration: DEFAULT_ANIMATION_DURATION,
                      curve: DEFAULT_ANIMATION_CURVE,
                    );
                    setState(() {
                      _isSaving = false;
                    });
                  },
            child: _isSaving ? const FormProgressIndicator() : Text(i18n.save),
          ),
        ],
      ),
    );
  }
}
