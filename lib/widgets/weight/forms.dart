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
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight.dart';

class WeightForm extends StatelessWidget {
  final _form = GlobalKey<FormState>();
  final dateController = TextEditingController();
  final weightController = TextEditingController();

  late final WeightEntry _weightEntry;

  WeightForm([WeightEntry? weightEntry]) {
    _weightEntry = weightEntry ?? WeightEntry(date: DateTime.now());
    weightController.text = _weightEntry.id == null ? '' : _weightEntry.weight.toString();
    dateController.text = toDate(_weightEntry.date)!;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          // Weight date
          TextFormField(
            readOnly: true, // Stop keyboard from appearing
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).date,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            enableInteractiveSelection: false,
            controller: dateController,
            onTap: () async {
              // Show Date Picker Here
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _weightEntry.date,
                firstDate: DateTime(DateTime.now().year - 10),
                lastDate: DateTime.now(),
                selectableDayPredicate: (day) {
                  // Always allow the current initial date
                  if (day == _weightEntry.date) {
                    return true;
                  }

                  // if the date is known, don't allow it
                  return Provider.of<BodyWeightProvider>(context, listen: false).findByDate(day) ==
                      null;
                },
              );

              if (pickedDate != null) {
                dateController.text = toDate(pickedDate)!;
              }
            },
            onSaved: (newValue) {
              _weightEntry.date = DateTime.parse(newValue!);
            },
          ),

          // Weight
          TextFormField(
            decoration: InputDecoration(labelText: AppLocalizations.of(context).weight),
            controller: weightController,
            keyboardType: TextInputType.number,
            onSaved: (newValue) {
              _weightEntry.weight = double.parse(newValue!);
            },
            validator: (value) {
              if (value!.isEmpty) {
                return AppLocalizations.of(context).enterValue;
              }
              try {
                double.parse(value);
              } catch (error) {
                return AppLocalizations.of(context).enterValidNumber;
              }
              return null;
            },
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              // Validate and save the current values to the weightEntry
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // Save the entry on the server
              try {
                _weightEntry.id == null
                    ? await Provider.of<BodyWeightProvider>(context, listen: false)
                        .addEntry(_weightEntry)
                    : await Provider.of<BodyWeightProvider>(context, listen: false)
                        .editEntry(_weightEntry);
              } on WgerHttpException catch (error) {
                showHttpExceptionErrorDialog(error, context);
              } catch (error) {
                showErrorDialog(error, context);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
