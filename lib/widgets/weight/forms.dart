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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight.dart';

class WeightForm extends riverpod.ConsumerWidget {
  final _form = GlobalKey<FormState>();
  final dateController = TextEditingController(text: '');
  final timeController = TextEditingController(text: '');
  final weightController = TextEditingController(text: '');

  final WeightEntry _weightEntry;

  WeightForm([WeightEntry? weightEntry])
    : _weightEntry = weightEntry ?? WeightEntry(date: DateTime.now());

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    final timeFormat = DateFormat.Hm(Localizations.localeOf(context).languageCode);

    if (weightController.text.isEmpty && _weightEntry.weight != 0) {
      weightController.text = numberFormat.format(_weightEntry.weight);
    }
    if (dateController.text.isEmpty) {
      dateController.text = dateFormat.format(_weightEntry.date);
    }
    if (timeController.text.isEmpty) {
      timeController.text = TimeOfDay.fromDateTime(_weightEntry.date).format(context);
    }

    return Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
            key: const Key('dateInput'),
            // Stop keyboard from appearing
            readOnly: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).date,
              suffixIcon: const Icon(
                Icons.calendar_today,
                key: Key('calendarIcon'),
              ),
            ),
            enableInteractiveSelection: false,
            controller: dateController,
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _weightEntry.date,
                firstDate: DateTime(DateTime.now().year - 10),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                dateController.text = dateFormat.format(pickedDate);
              }
            },
            onSaved: (newValue) {
              final date = dateFormat.parse(newValue!);
              _weightEntry.date = _weightEntry.date.copyWith(
                year: date.year,
                month: date.month,
                day: date.day,
              );
            },
          ),
          TextFormField(
            key: const Key('timeInput'),
            // Stop keyboard from appearing
            readOnly: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).time,
              suffixIcon: const Icon(
                Icons.access_time_outlined,
                key: Key('clockIcon'),
              ),
            ),
            enableInteractiveSelection: false,
            controller: timeController,
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_weightEntry.date),
              );

              if (pickedTime != null) {
                timeController.text = pickedTime.format(context);
              }
            },
            onSaved: (newValue) {
              final time = timeFormat.parse(newValue!);
              _weightEntry.date = _weightEntry.date.copyWith(
                hour: time.hour,
                minute: time.minute,
                second: time.second,
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
            onSaved: (newValue) {
              _weightEntry.weight = numberFormat.parse(newValue!);
            },
            validator: (value) {
              if (value!.isEmpty) {
                return AppLocalizations.of(context).enterValue;
              }

              try {
                numberFormat.parse(value);
              } catch (error) {
                return AppLocalizations.of(context).enterValidNumber;
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
