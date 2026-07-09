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
import 'package:logging/logging.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/core/snackbar.dart';
import 'package:wger/core/widgets/core.dart';
import 'package:wger/core/widgets/error.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/models/set_config_data.dart';
import 'package:wger/features/routines/models/slot_entry.dart';
import 'package:wger/features/routines/providers/gym_log_notifier.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/providers/plate_weights.dart';
import 'package:wger/features/routines/providers/workout_logs_notifier.dart';
import 'package:wger/features/routines/screens/settings_plates_screen.dart';
import 'package:wger/features/routines/validators.dart';
import 'package:wger/features/routines/widgets/forms/repetitions.dart';
import 'package:wger/features/routines/widgets/forms/rir.dart';
import 'package:wger/features/routines/widgets/forms/weight.dart';
import 'package:wger/features/routines/widgets/gym_mode/navigation.dart';
import 'package:wger/features/routines/widgets/plate_calculator.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class LogPage extends ConsumerWidget {
  final _logger = Logger('LogPage');

  final PageController _controller;

  /// Identifies which slot page this widget renders, so it shows its own
  /// content instead of whatever the globally-current page happens to be.
  final String slotUuid;

  LogPage(this._controller, this.slotUuid);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gymState = ref.watch(gymStateProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    final slotEntryPage = gymState.getSlotPageByUUID(slotUuid);
    if (slotEntryPage == null) {
      _logger.info('getSlotPageByUUID for $slotUuid returned null, showing empty container.');
      return Container();
    }

    final page = gymState.getPageByIndex(slotEntryPage.pageIndex);
    if (page == null) {
      _logger.info(
        'getPageByIndex for ${slotEntryPage.pageIndex} returned null, showing empty container.',
      );
      return Container();
    }
    final setConfigData = slotEntryPage.setConfigData!;

    // Past logs come straight from the local DB (not the gym-mode routine
    // snapshot) so a set logged during this workout shows up right away.
    final pastLogs = ref.watch(
      pastExerciseLogsProvider(
        routineId: gymState.routine.id!,
        exerciseId: setConfigData.exerciseId,
      ),
    );

    // Mark done sets
    final decorationStyle = slotEntryPage.logDone
        ? TextDecoration.lineThrough
        : TextDecoration.none;

    return Column(
      children: [
        NavigationHeader(
          setConfigData.exercise.getTranslation(languageCode).name,
          _controller,
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
        if (setConfigData.exercise.showPlateCalculator) const LogsPlatesWidget(),
        if (slotEntryPage.setConfigData!.comment.isNotEmpty)
          Text(slotEntryPage.setConfigData!.comment, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Expanded(child: _buildPastLogs(pastLogs)),

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
                key: ValueKey('log-form-${slotEntryPage.uuid}'),
              ),
            ),
          ),
        ),
        NavigationFooter(_controller),
      ],
    );
  }

  /// Renders the previous logs for this exercise
  Widget _buildPastLogs(AsyncValue<List<Log>> pastLogs) {
    if (pastLogs.hasError) {
      _logger.warning('Could not load past logs', pastLogs.error, pastLogs.stackTrace);
      // Scroll-wrap so the indicator fits this slim slot instead of overflowing.
      return SingleChildScrollView(
        child: StreamErrorIndicator(pastLogs.error!, stacktrace: pastLogs.stackTrace),
      );
    }
    final logs = pastLogs.value ?? const <Log>[];
    return logs.isEmpty ? const SizedBox.shrink() : LogsPastLogsWidget(pastLogs: logs);
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

class LogsPastLogsWidget extends ConsumerWidget {
  final List<Log> pastLogs;

  const LogsPastLogsWidget({
    super.key,
    required this.pastLogs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logProvider = ref.read(gymLogProvider.notifier);
    final dateFormat = localizedDate(context);

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
                showSnackbar(context, AppLocalizations.of(context).dataCopied);
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

  const LogFormWidget({
    super.key,
    required this.controller,
    required this.configData,
  });

  @override
  _LogFormWidgetState createState() => _LogFormWidgetState();
}

class _LogFormWidgetState extends ConsumerState<LogFormWidget> {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final logProvider = ref.read(workoutLogProvider);
    final log = ref.watch(gymLogProvider);

    // The log is populated when the page becomes current: the PageView can lay
    // out and mount this page before that happens, so guard against null.
    if (log == null) {
      return const SizedBox.shrink();
    }

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
          Row(
            children: [
              Flexible(
                child: RepetitionInputWidget(
                  key: const ValueKey('logs-reps-widget'),
                  value: log.repetitions,
                  valueChange: widget.configData.repetitionsRounding,
                  unit: log.repetitionsUnitObj,
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(gymLogProvider.notifier).setRepetitions(v);
                    }
                  },
                  onUnitChanged: (v) {
                    if (v != null) {
                      ref.read(gymLogProvider.notifier).setRepetitionUnit(v);
                    }
                  },
                ),
              ),
              Flexible(
                child: WeightInputWidget(
                  key: const ValueKey('logs-weight-widget'),
                  value: log.weight,
                  valueChange: widget.configData.weightRounding,
                  unit: log.weightUnitObj,
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(gymLogProvider.notifier).setWeight(v);
                      ref.read(plateCalculatorProvider.notifier).setWeight(v);
                    }
                  },
                  onUnitChanged: (v) {
                    if (v != null) {
                      ref.read(gymLogProvider.notifier).setWeightUnit(v);
                    }
                  },
                ),
              ),
            ],
          ),
          RiRInputWidget(
            key: const ValueKey('rir-input-widget'),
            log.rir,
            onChanged: (value) {
              log.rir = value == '' ? null : num.parse(value);
            },
          ),
          FilledButton(
            key: const ValueKey('save-log-button'),
            onPressed: () async {
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              final error = validateWorkoutLogCrossField(
                repetitions: log.repetitions,
                weight: log.weight,
                i18n: i18n,
              );
              if (error != null) {
                showSnackbar(context, error);
                return;
              }

              final gymState = ref.read(gymStateProvider);
              final gymProvider = ref.read(gymStateProvider.notifier);
              final page = gymState.getSlotEntryPageByIndex()!;

              // A failed write is intentionally left to propagate to the global
              // error handler; the success path below is then skipped.
              await logProvider.addEntry(log);
              if (!context.mounted) {
                return;
              }

              gymProvider.markSlotPageAsDone(page.uuid, isDone: true);
              showSnackbar(
                context,
                i18n.successfullySaved,
                center: true,
                duration: const Duration(seconds: 2),
              );
              widget.controller.nextPage(
                duration: DEFAULT_ANIMATION_DURATION,
                curve: DEFAULT_ANIMATION_CURVE,
              );
            },
            child: Text(i18n.save),
          ),
        ],
      ),
    );
  }
}
