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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/gym_log_state.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/plate_weights.dart';
import 'package:wger/screens/settings_plates_screen.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/routines/forms/log_form.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';
import 'package:wger/widgets/routines/plate_calculator.dart';

class LogPage extends ConsumerWidget {
  final _logger = Logger('LogPage');

  final PageController _controller;
  LogPage(this._controller);

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

    final log = ref.read(gymLogProvider);

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
                key: ValueKey('log-form-${slotEntryPage.uuid}'),
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
                  SnackBar(content: Text(AppLocalizations.of(context).dataCopied)),
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
