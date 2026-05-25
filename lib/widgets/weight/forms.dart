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
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/number_input.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight_notifier.dart';
import 'package:wger/widgets/core/datetime_input.dart';

class WeightForm extends riverpod.ConsumerWidget {
  final _form = GlobalKey<FormState>();
  final weightController = TextEditingController(text: '');

  final WeightEntry _weightEntry;

  WeightForm([WeightEntry? weightEntry])
    : _weightEntry = weightEntry ?? WeightEntry(date: DateTime.now());

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    if (weightController.text.isEmpty && _weightEntry.weight != 0) {
      weightController.text = numberFormat.format(_weightEntry.weight);
    }

    return Form(
      key: _form,
      child: Column(
        children: [
          DateInputWidget(
            key: const Key('dateInput'),
            value: _weightEntry.date,
            labelText: AppLocalizations.of(context).date,
            firstDate: DateTime(DateTime.now().year - 10),
            lastDate: DateTime.now(),
            onChanged: (date) {
              _weightEntry.date = _weightEntry.date.copyWith(
                year: date.year,
                month: date.month,
                day: date.day,
              );
            },
          ),
          TimeInputWidget(
            key: const Key('timeInput'),
            value: TimeOfDay.fromDateTime(_weightEntry.date),
            labelText: AppLocalizations.of(context).time,
            onChanged: (time) {
              _weightEntry.date = _weightEntry.date.copyWith(
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
                    onPressed: () {
                      try {
                        final newValue = numberFormat.parse(weightController.text) - 1;
                        weightController.text = numberFormat.format(newValue);
                      } on FormatException {}
                    },
                  ),
                  IconButton(
                    key: const Key('quickMinusSmall'),
                    icon: const FaIcon(FontAwesomeIcons.minus),
                    onPressed: () {
                      try {
                        final newValue = numberFormat.parse(weightController.text) - 0.1;
                        weightController.text = numberFormat.format(newValue);
                      } on FormatException {}
                    },
                  ),
                ],
              ),
              suffix: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const Key('quickPlusSmall'),
                    icon: const FaIcon(FontAwesomeIcons.plus),
                    onPressed: () {
                      try {
                        final newValue = numberFormat.parse(weightController.text) + 0.1;
                        weightController.text = numberFormat.format(newValue);
                      } on FormatException {}
                    },
                  ),
                  IconButton(
                    key: const Key('quickPlus'),
                    icon: const FaIcon(FontAwesomeIcons.circlePlus),
                    onPressed: () {
                      try {
                        final newValue = numberFormat.parse(weightController.text) + 1;
                        weightController.text = numberFormat.format(newValue);
                      } on FormatException {}
                    },
                  ),
                ],
              ),
            ),
            controller: weightController,
            keyboardType: textInputTypeDecimal,
            inputFormatters: [LocalizedDecimalInputFormatter(numberFormat.symbols.DECIMAL_SEP)],
            onSaved: (newValue) {
              _weightEntry.weight = numberFormat.parse(newValue!);
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
              if (parsed < 30 || parsed > 300) {
                return i18n.formMinMaxValues(30, 300);
              }
              return null;
            },
          ),
          ElevatedButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              // Validate and save the current values to the weightEntry
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // Save the entry on the server
              final notifier = ref.read(weightEntryProvider.notifier);
              _weightEntry.id == null
                  ? await notifier.addEntry(_weightEntry)
                  : await notifier.updateEntry(_weightEntry);

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
