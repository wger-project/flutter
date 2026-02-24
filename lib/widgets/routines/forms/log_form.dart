/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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
import 'package:provider/provider.dart' as provider;
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/providers/gym_log_state.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/routines/forms/repetitions.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/weight.dart';

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
                  child: RepetitionInputWidget(
                    key: const ValueKey('logs-reps-widget'),
                    valueChange: widget.configData.repetitionsRounding,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: WeightInputWidget(
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
                  child: RepetitionInputWidget(
                    key: const ValueKey('logs-reps-widget'),
                    valueChange: widget.configData.repetitionsRounding,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: RepetitionUnitInputWidget(
                    key: const ValueKey('repetition-unit-input-widget'),
                    log?.repetitionsUnitObj,
                    onChanged: (v) => ref.read(gymLogProvider.notifier).setRepetitionUnit(v),
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
                  child: WeightInputWidget(
                    key: const ValueKey('logs-weight-widget'),
                    valueChange: widget.configData.weightRounding,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: WeightUnitInputWidget(
                    log?.weightUnitObj,
                    onChanged: (v) => ref.read(gymLogProvider.notifier).setWeightUnit(v),
                    key: const ValueKey('weight-unit-input-widget'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          if (_detailed)
            RiRInputWidget(
              key: const ValueKey('rir-input-widget'),
              log?.rir,
              onChanged: (value) {
                if (log == null) {
                  return;
                }
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

                      final logToSave = ref.read(gymLogProvider);
                      await provider.Provider.of<RoutinesProvider>(
                        context,
                        listen: false,
                      ).addLog(logToSave!);
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
