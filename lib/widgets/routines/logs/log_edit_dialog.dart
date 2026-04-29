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
import 'package:logging/logging.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/providers/workout_logs.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/routines/forms/repetitions.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/weight.dart';

/// Show the edit dialog for the given [log].
///
/// Returns when the dialog is dismissed (either via cancel or after a
/// successful save).
Future<void> showLogEditDialog(BuildContext context, Log log) {
  return showDialog<void>(
    context: context,
    builder: (_) => LogEditDialog(log: log),
  );
}

/// Edit form for an already-existing [Log].
///
/// Holds local state for the editable fields so the original log is only
/// touched when the user confirms. Mirrors the gym-mode log form layout
/// (compact reps + weight by default, expanded units + RiR behind a
/// switch) and reuses the controlled input widgets from
/// `lib/widgets/routines/forms/`.
class LogEditDialog extends ConsumerStatefulWidget {
  final Log log;

  const LogEditDialog({super.key, required this.log});

  @override
  ConsumerState<LogEditDialog> createState() => _LogEditDialogState();
}

class _LogEditDialogState extends ConsumerState<LogEditDialog> {
  final _logger = Logger('LogEditDialog');
  final _form = GlobalKey<FormState>();

  // Editable draft state. Only applied to the original log on save, so a
  // cancel leaves the original untouched.
  num? _repetitions;
  num? _weight;
  num? _rir;
  RepetitionUnit? _repetitionUnit;
  WeightUnit? _weightUnit;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repetitions = widget.log.repetitions;
    _weight = widget.log.weight;
    _rir = widget.log.rir;
    _repetitionUnit = widget.log.repetitionsUnitObj;
    _weightUnit = widget.log.weightUnitObj;
  }

  Future<void> _onSave() async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }
    _form.currentState!.save();
    setState(() => _saving = true);

    final updated = widget.log.copyWith(
      repetitions: _repetitions,
      weight: _weight,
      rir: _rir,
      repetitionsUnitObj: _repetitionUnit,
      weightUnitObj: _weightUnit,
    );

    final i18n = AppLocalizations.of(context);
    try {
      await ref.read(workoutLogProvider).updateEntry(updated);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(i18n.successfullySaved, textAlign: TextAlign.center),
        ),
      );
      Navigator.of(context).pop();
    } catch (error, stack) {
      _logger.warning('Could not update log ${widget.log.id}', error, stack);
      if (mounted) {
        setState(() => _saving = false);
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      title: Text(i18n.edit),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RepetitionInputWidget(
                key: const ValueKey('edit-reps-widget'),
                value: _repetitions,
                onChanged: (v) => setState(() => _repetitions = v),
                unit: _repetitionUnit,
                onUnitChanged: (v) => setState(() => _repetitionUnit = v),
              ),
              const SizedBox(height: 12),
              WeightInputWidget(
                key: const ValueKey('edit-weight-widget'),
                value: _weight,
                onChanged: (v) => setState(() => _weight = v),
                unit: _weightUnit,
                onUnitChanged: (v) => setState(() => _weightUnit = v),
              ),
              const SizedBox(height: 12),
              RiRInputWidget(
                key: const ValueKey('edit-rir-widget'),
                _rir,
                onChanged: (v) => setState(() {
                  _rir = v.isEmpty ? null : num.parse(v);
                }),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('edit-cancel-button'),
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          key: const ValueKey('edit-save-button'),
          onPressed: _saving ? null : _onSave,
          child: _saving ? const FormProgressIndicator() : Text(i18n.save),
        ),
      ],
    );
  }
}
