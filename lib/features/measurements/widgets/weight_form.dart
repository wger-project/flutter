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
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:wger/core/consts.dart';
import 'package:wger/core/widgets/datetime_input.dart';
import 'package:wger/core/widgets/decimal_input.dart';
import 'package:wger/core/widgets/form_submit_button.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Stepper sizes for the quick +/- buttons. The value bounds come from the
/// metric type, which has them per unit (see [MetricType.limits])
const _stepperSmall = 0.1;
const _stepperBig = 1;

/// Create/edit form for a body weight entry.
///
/// Entries are measurements in the official body weight [MeasurementCategory].
/// The value is shown and edited in the unit it was entered in; the chosen
/// unit is stamped into the entry's `extra_data`.
class WeightForm extends riverpod.ConsumerStatefulWidget {
  final MeasurementCategory _category;
  final MeasurementEntry? _entry;

  const WeightForm(this._category, [this._entry]);

  @override
  riverpod.ConsumerState<WeightForm> createState() => _WeightFormState();
}

class _WeightFormState extends riverpod.ConsumerState<WeightForm> {
  final _form = GlobalKey<FormState>();

  late MeasurementEntry _draft;
  num? _weight;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _draft =
        widget._entry ??
        MeasurementEntry(
          categoryId: widget._category.id!,
          date: DateTime.now(),
          value: 0,
          notes: '',
        );
    _weight = widget._entry?.value;

    // Existing entries keep their stored unit (the value is shown exactly as
    // entered); new entries default to the profile unit
    final entry = widget._entry;
    _unit = entry != null
        ? entry.unitOrFallbackFor(widget._category.unit)
        : weightDisplayUnit(ref.read(userProfileProvider).value?.isMetric ?? true);
  }

  /// The bounds of the unit the value is currently entered in
  MetricLimits get _limits => MetricType.bodyWeight.limits(_unit);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          DateTimeInputWidget(
            key: const Key('dateTimeInput'),
            value: _draft.date,
            onChanged: (value) => _draft = _draft.copyWith(date: value),
          ),

          // Weight
          DecimalInputWidget(
            key: const Key('weightInput'),
            value: _weight,
            labelText: AppLocalizations.of(context).weight,
            isRequired: true,
            min: _limits.min,
            max: _limits.max,
            steppers: const [_stepperBig, _stepperSmall],
            onChanged: (value) => _weight = value,
          ),

          // Unit the value is entered in, stamped onto the entry when saving
          DropdownButtonFormField<String>(
            key: const Key('unitInput'),
            initialValue: _unit,
            decoration: InputDecoration(labelText: AppLocalizations.of(context).unit),
            items: [
              for (final unit in convertibleUnits) DropdownMenuItem(value: unit, child: Text(unit)),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _unit = value);
              }
            },
          ),
          FormSubmitButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            label: AppLocalizations.of(context).save,
            onPressed: () async {
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // The draft carries what the form does not offer (notes, source,
              // external id), so an edited import stays deduplicable; only the
              // chosen unit is stamped into extra_data, other keys survive
              final entry = _draft.copyWith(
                value: _weight!,
                extraData: {...?_draft.extraData, 'unit': _unit},
              );

              final notifier = ref.read(measurementProvider.notifier);
              entry.id == null ? await notifier.addEntry(entry) : await notifier.updateEntry(entry);

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
