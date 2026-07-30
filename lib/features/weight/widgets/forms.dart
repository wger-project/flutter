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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/core/number_input.dart';
import 'package:wger/core/widgets/datetime_input.dart';
import 'package:wger/core/widgets/form_submit_button.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Sanity bounds (in kg) and stepper sizes for manual body weight input
const _minWeightKg = 30;
const _maxWeightKg = 300;
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

  // Controller instead of initialValue because the quick +/- buttons write
  // into the field. Seeded in didChangeDependencies (needs the locale).
  final _weightController = TextEditingController();
  bool _seeded = false;

  late DateTime _date;
  num _weight = 0;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _date = widget._entry?.date ?? DateTime.now();
    _weight = widget._entry?.value ?? 0;

    // Existing entries keep their stored unit (the value is shown exactly as
    // entered); new entries default to the profile unit
    final entry = widget._entry;
    _unit = entry != null
        ? entry.unitOrFallback(widget._category.unit)
        : weightDisplayUnit(ref.read(userProfileProvider).value?.isMetric ?? true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_seeded) {
      _seeded = true;
      if (widget._entry != null) {
        _weightController.text = localizedNumberFormat(context).format(widget._entry!.value);
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  /// `true` when [value] (in the currently selected unit) is plausible
  bool _isInRange(num value) {
    final kg = convertWeight(value, from: _unit, to: 'kg');
    return kg >= _minWeightKg && kg <= _maxWeightKg;
  }

  /// Adds [delta] to the field's current value, clamped to the valid range
  void _step(num delta) {
    final numberFormat = localizedNumberFormat(context);
    final parsed = numberFormat.tryParse(_weightController.text);
    if (parsed == null) {
      return;
    }
    final newValue = parsed + delta;
    if (!_isInRange(newValue)) {
      return;
    }
    _weightController.text = numberFormat.format(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = localizedNumberFormat(context);

    return Form(
      key: _form,
      child: Column(
        children: [
          DateInputWidget(
            key: const Key('dateInput'),
            value: _date,
            labelText: AppLocalizations.of(context).date,
            firstDate: DateTime(DateTime.now().year - 10),
            lastDate: DateTime.now(),
            onChanged: (date) {
              _date = _date.copyWith(
                year: date.year,
                month: date.month,
                day: date.day,
              );
            },
          ),
          TimeInputWidget(
            key: const Key('timeInput'),
            value: TimeOfDay.fromDateTime(_date),
            labelText: AppLocalizations.of(context).time,
            onChanged: (time) {
              _date = _date.copyWith(
                hour: time.hour,
                minute: time.minute,
                second: 0,
              );
            },
          ),

          // Weight
          TextFormField(
            key: const Key('weightInput'),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).weight,
              prefix: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const Key('quickMinus'),
                    icon: const FaIcon(FontAwesomeIcons.circleMinus),
                    onPressed: () => _step(-_stepperBig),
                  ),
                  IconButton(
                    key: const Key('quickMinusSmall'),
                    icon: const FaIcon(FontAwesomeIcons.minus),
                    onPressed: () => _step(-_stepperSmall),
                  ),
                ],
              ),
              suffix: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const Key('quickPlusSmall'),
                    icon: const FaIcon(FontAwesomeIcons.plus),
                    onPressed: () => _step(_stepperSmall),
                  ),
                  IconButton(
                    key: const Key('quickPlus'),
                    icon: const FaIcon(FontAwesomeIcons.circlePlus),
                    onPressed: () => _step(_stepperBig),
                  ),
                ],
              ),
            ),
            controller: _weightController,
            keyboardType: textInputTypeDecimal,
            inputFormatters: [LocalizedDecimalInputFormatter(numberFormat.symbols.DECIMAL_SEP)],
            onSaved: (newValue) {
              _weight = numberFormat.parse(newValue!);
            },
            validator: (value) {
              final i18n = AppLocalizations.of(context);
              if (value!.isEmpty) {
                return i18n.enterValue;
              }
              final parsed = numberFormat.tryParse(value);
              if (parsed == null) {
                return i18n.enterValidNumber;
              }
              if (!_isInRange(parsed)) {
                // The bounds are defined in kg, show them in the entered unit
                return i18n.formMinMaxValues(
                  convertWeight(_minWeightKg, from: 'kg', to: _unit).round(),
                  convertWeight(_maxWeightKg, from: 'kg', to: _unit).round(),
                );
              }
              return null;
            },
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

              // Notes, source and external id are not editable here; keep the
              // existing values so edits to imported entries stay deduplicable.
              // The chosen unit is stamped into extra_data, other keys survive.
              final entry = MeasurementEntry(
                id: widget._entry?.id,
                categoryId: widget._category.id!,
                date: _date,
                value: _weight,
                notes: widget._entry?.notes ?? '',
                source: widget._entry?.source ?? 'user',
                externalId: widget._entry?.externalId,
                extraData: {...?widget._entry?.extraData, 'unit': _unit},
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
