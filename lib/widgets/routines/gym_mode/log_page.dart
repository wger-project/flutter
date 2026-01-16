/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
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
import 'package:provider/provider.dart' as provider;
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/gym_log_state.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/plate_weights.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/configure_plates_screen.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/routines/forms/reps_unit.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/weight_unit.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';
import 'package:wger/widgets/routines/plate_calculator.dart';

class LogPage extends ConsumerWidget {
  final _logger = Logger('LogPage');

  final PageController _controller;
  LogPage(this._controller);
  final GlobalKey<_LogFormWidgetState> _logFormKey = GlobalKey<_LogFormWidgetState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gymState = ref.watch(gymStateProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    final page = gymState.getPageByIndex();
    if (page == null) {
      _logger.info(
        'getPageByIndex for ${gymState.currentPage} returned null, showing empty container.',
      );
      return Container();
    }

    final slotEntryPage = gymState.getSlotEntryPageByIndex();
    if (slotEntryPage == null) {
      _logger.info(
        'getSlotPageByIndex for ${gymState.currentPage} returned null, showing empty container',
      );
      return Container();
    }
    final setConfigData = slotEntryPage.setConfigData!;

    final log = ref.watch(gymLogProvider);

    // Mark done sets
    final decorationStyle = slotEntryPage.logDone
        ? TextDecoration.lineThrough
        : TextDecoration.none;

    return Column(
      children: [
        NavigationHeader(
          log!.exercise.getTranslation(languageCode).name,
          _controller,
          key: const ValueKey('log-page-navigation-header'),
        ),

        Container(
          color: theme.colorScheme.onInverseSurface,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Column(
              children: [
                Column(
                  children: [
                    Text(
                      setConfigData.textRepr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: decorationStyle,
                      ),
                    ),
                    if (setConfigData.type != SlotEntryType.normal)
                      Text(
                        setConfigData.type.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: decorationStyle,
                        ),
                      ),
                  ],
                ),
                Text(
                  '${slotEntryPage.setIndex + 1} / ${page.slotPages.where((e) => e.type == SlotPageType.log).length}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        if (log.exercise.showPlateCalculator) const LogsPlatesWidget(),
        if (slotEntryPage.setConfigData!.comment.isNotEmpty)
          Text(slotEntryPage.setConfigData!.comment, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Expanded(
          child: (gymState.routine.filterLogsByExercise(log.exerciseId).isNotEmpty)
              ? LogsPastLogsWidget(
                  pastLogs: gymState.routine.filterLogsByExercise(log.exerciseId),
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
                controller: _controller,
                configData: setConfigData,
                // log: log!,
                key: _logFormKey,
              ),
            ),
          ),
        ),
        NavigationFooter(_controller),
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

class LogsRepsWidget extends ConsumerWidget {
  final _logger = Logger('LogsRepsWidget');

  final num valueChange;

  LogsRepsWidget({
    super.key,
    num? valueChange,
  }) : valueChange = valueChange ?? 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final i18n = AppLocalizations.of(context);

    final logNotifier = ref.read(gymLogProvider.notifier);
    final log = ref.watch(gymLogProvider);

    final currentReps = log?.repetitions;
    final repText = currentReps != null ? numberFormat.format(currentReps) : '';

    return Row(
      children: [
        // "Quick-remove" button
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.black),
          onPressed: () {
            final base = currentReps ?? 0;
            final newValue = base - valueChange;
            if (newValue >= 0 && log != null) {
              logNotifier.setRepetitions(newValue);
            }
          },
        ),

        // Text field
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: i18n.repetitions),
            enabled: true,
            key: ValueKey('reps-field-$repText'),
            initialValue: repText,
            keyboardType: textInputTypeDecimal,
            onChanged: (value) {
              try {
                final newValue = numberFormat.parse(value);
                logNotifier.setRepetitions(newValue);
              } on FormatException catch (error) {
                _logger.finer('Error parsing repetitions: $error');
              }
            },
            onSaved: (newValue) {
              if (newValue == null || log == null) {
                return;
              }
              logNotifier.setRepetitions(numberFormat.parse(newValue));
            },
            validator: (value) {
              if (numberFormat.tryParse(value ?? '') == null) {
                return i18n.enterValidNumber;
              }
              return null;
            },
          ),
        ),

        // "Quick-add" button
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            final base = currentReps ?? 0;
            final newValue = base + valueChange;
            if (newValue >= 0 && log != null) {
              logNotifier.setRepetitions(newValue);
            }
          },
        ),
      ],
    );
  }
}

class LogsWeightWidget extends ConsumerWidget {
  final _logger = Logger('LogsWeightWidget');

  final num valueChange;

  LogsWeightWidget({
    super.key,
    num? valueChange,
  }) : valueChange = valueChange ?? 1.25;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final i18n = AppLocalizations.of(context);

    final plateProvider = ref.read(plateCalculatorProvider.notifier);
    final logProvider = ref.read(gymLogProvider.notifier);
    final log = ref.watch(gymLogProvider);

    final currentWeight = log?.weight;
    final weightText = currentWeight != null ? numberFormat.format(currentWeight) : '';

    return Row(
      children: [
        IconButton(
          // "Quick-remove" button
          icon: const Icon(Icons.remove, color: Colors.black),
          onPressed: () {
            final base = currentWeight ?? 0;
            final newValue = base - valueChange;
            if (newValue >= 0 && log != null) {
              logProvider.setWeight(newValue);
            }
          },
        ),

        // Text field
        Expanded(
          child: TextFormField(
            key: ValueKey('weight-field-$weightText'),
            decoration: InputDecoration(labelText: i18n.weight),
            initialValue: weightText,
            keyboardType: textInputTypeDecimal,
            onChanged: (value) {
              try {
                final newValue = numberFormat.parse(value);
                plateProvider.setWeight(newValue);
                logProvider.setWeight(newValue);
              } on FormatException catch (error) {
                _logger.finer('Error parsing weight: $error');
              }
            },
            onSaved: (newValue) {
              if (newValue == null || log == null) {
                return;
              }
              logProvider.setWeight(numberFormat.parse(newValue));
            },
            validator: (value) {
              if (numberFormat.tryParse(value ?? '') == null) {
                return i18n.enterValidNumber;
              }
              return null;
            },
          ),
        ),

        // "Quick-add" button
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            final base = currentWeight ?? 0;
            final newValue = base + valueChange;
            if (log != null) {
              logProvider.setWeight(newValue);
            }
          },
        ),
      ],
    );
  }
}

class LogsPastLogsWidget extends ConsumerWidget {
  final List<Log> pastLogs;

  const LogsPastLogsWidget({
    super.key,
    required this.pastLogs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logProvider = ref.read(gymLogProvider.notifier);
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);

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
              key: ValueKey('past-log-${pastLog.id}'),
              title: Text(pastLog.repTextNoNl(context)),
              subtitle: Text(dateFormat.format(pastLog.date)),
              trailing: const Icon(Icons.copy),
              onTap: () {
                logProvider.setLog(pastLog);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).dataCopied),
                  ),
                );
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
  final _logger = Logger('LogFormWidget');

  final PageController controller;
  final SetConfigData configData;

  LogFormWidget({
    super.key,
    required this.controller,
    required this.configData,
  });

  @override
  _LogFormWidgetState createState() => _LogFormWidgetState();
}

class _LogFormWidgetState extends ConsumerState<LogFormWidget> {
  final _form = GlobalKey<FormState>();
  var _detailed = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final log = ref.watch(gymLogProvider);

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
                    key: const ValueKey('logs-reps-widget'),
                    valueChange: widget.configData.repetitionsRounding,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: LogsWeightWidget(
                    key: const ValueKey('logs-weight-widget'),
                    valueChange: widget.configData.weightRounding,
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
                    key: const ValueKey('logs-reps-widget'),
                    valueChange: widget.configData.repetitionsRounding,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: RepetitionUnitInputWidget(
                    key: const ValueKey('repetition-unit-input-widget'),
                    log!.repetitionsUnitId,
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
                    key: const ValueKey('logs-weight-widget'),
                    valueChange: widget.configData.weightRounding,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: WeightUnitInputWidget(
                    log!.weightUnitId,
                    onChanged: (v) => {},
                    key: const ValueKey('weight-unit-input-widget'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          if (_detailed)
            RiRInputWidget(
              key: const ValueKey('rir-input-widget'),
              log!.rir,
              onChanged: (value) {
                log.rir = value == '' ? null : num.parse(value);
              },
            ),
          SwitchListTile(
            key: const ValueKey('units-switch'),
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
            key: const ValueKey('save-log-button'),
            onPressed: _isSaving
                ? null
                : () async {
                    final isValid = _form.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    _isSaving = true;
                    _form.currentState!.save();

                    try {
                      final gymState = ref.read(gymStateProvider);
                      final gymProvider = ref.read(gymStateProvider.notifier);

                      await provider.Provider.of<RoutinesProvider>(
                        context,
                        listen: false,
                      ).addLog(log!);
                      final page = gymState.getSlotEntryPageByIndex()!;
                      gymProvider.markSlotPageAsDone(page.uuid, isDone: true);

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
                    } on WgerHttpException {
                      setState(() {
                        _isSaving = false;
                      });
                      rethrow;
                    } finally {
                      setState(() {
                        _isSaving = false;
                      });
                    }
                  },
            child: _isSaving ? const FormProgressIndicator() : Text(i18n.save),
          ),
        ],
      ),
    );
  }
}
