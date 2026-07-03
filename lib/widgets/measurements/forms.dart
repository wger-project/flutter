/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/measurement_notifier.dart';
import 'package:wger/widgets/core/datetime_input.dart';
import 'package:wger/widgets/core/decimal_input.dart';
import 'package:wger/widgets/core/error.dart';
import 'package:wger/widgets/core/form_submit_button.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

class MeasurementCategoryForm extends ConsumerStatefulWidget {
  final MeasurementCategory? _category;

  const MeasurementCategoryForm([this._category]);

  @override
  ConsumerState<MeasurementCategoryForm> createState() => _MeasurementCategoryFormState();
}

class _MeasurementCategoryFormState extends ConsumerState<MeasurementCategoryForm> {
  final _form = GlobalKey<FormState>();

  late MeasurementCategory _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget._category ?? MeasurementCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          // Name
          TextFormField(
            initialValue: _draft.name,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).name,
              helperText: AppLocalizations.of(context).measurementCategoriesHelpText,
            ),
            maxLength: MeasurementCategory.maxNameChars,
            onSaved: (value) => _draft = _draft.copyWith(name: value ?? ''),
            validator: (value) {
              final i18n = AppLocalizations.of(context);
              if (value!.isEmpty) {
                return i18n.enterValue;
              }
              if (value.length > MeasurementCategory.maxNameChars) {
                return i18n.enterMaxCharacters(MeasurementCategory.maxNameChars.toString());
              }
              return null;
            },
          ),

          // Unit
          TextFormField(
            initialValue: _draft.unit,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).unit,
              helperText: AppLocalizations.of(context).measurementEntriesHelpText,
            ),
            maxLength: MeasurementCategory.maxUnitChars,
            onSaved: (value) => _draft = _draft.copyWith(unit: value ?? ''),
            validator: (value) {
              final i18n = AppLocalizations.of(context);
              if (value!.isEmpty) {
                return i18n.enterValue;
              }
              if (value.length > MeasurementCategory.maxUnitChars) {
                return i18n.enterMaxCharacters(MeasurementCategory.maxUnitChars.toString());
              }
              return null;
            },
          ),

          // metricType
          DropdownButtonFormField(
            items: MetricType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _draft = _draft.copyWith(metricType: value);
                });
              }
            },
          ),
          FormSubmitButton(
            label: AppLocalizations.of(context).save,
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }
              _form.currentState!.save();

              final notifier = ref.read(measurementProvider.notifier);
              if (_draft.id == null) {
                await notifier.addCategory(_draft);
              } else {
                notifier.updateCategory(_draft);
              }

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

class MeasurementEntryForm extends ConsumerStatefulWidget {
  final String _categoryId;
  final MeasurementEntry? _entry;

  const MeasurementEntryForm(this._categoryId, [MeasurementEntry? entry]) : _entry = entry;

  @override
  ConsumerState<MeasurementEntryForm> createState() => _MeasurementEntryFormState();
}

class _MeasurementEntryFormState extends ConsumerState<MeasurementEntryForm> {
  final _form = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  late final String? _existingId = widget._entry?.id;
  late DateTime _date = widget._entry?.date ?? DateTime.now();
  num? _value;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _value = widget._entry?.value;
    _notes = widget._entry?.notes ?? '';
    _notesController.text = _notes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(measurementProvider.notifier);
    final Future<MeasurementCategory?> categoryFuture = notifier.getCategoryById(
      widget._categoryId,
    );

    return FutureBuilder(
      future: categoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BoxedProgressIndicator();
        }
        if (snapshot.hasError) {
          return StreamErrorIndicator(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Category not found');
        }

        final category = snapshot.data!;

        return Form(
          key: _form,
          child: Column(
            children: [
              // Date
              DateInputWidget(
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

              // Time
              TimeInputWidget(
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

              // Value
              DecimalInputWidget(
                value: _value,
                labelText: AppLocalizations.of(context).value,
                suffixText: category.unit,
                isRequired: true,
                min: MeasurementEntry.minValue,
                max: MeasurementEntry.maxValue,
                onChanged: (value) => _value = value,
              ),
              // Notes
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context).notes),
                controller: _notesController,
                onSaved: (newValue) {
                  _notes = newValue ?? '';
                },
                validator: (value) {
                  const minLength = 0;
                  const maxLength = 100;
                  if (value!.isNotEmpty && (value.length < minLength || value.length > maxLength)) {
                    return AppLocalizations.of(context).enterCharacters(
                      minLength.toString(),
                      maxLength.toString(),
                    );
                  }
                  return null;
                },
              ),

              FormSubmitButton(
                label: AppLocalizations.of(context).save,
                onPressed: () async {
                  final isValid = _form.currentState!.validate();
                  if (!isValid) {
                    return;
                  }
                  _form.currentState!.save();

                  final entry = MeasurementEntry(
                    id: _existingId,
                    categoryId: category.id!,
                    date: _date,
                    value: _value!,
                    notes: _notes,
                  );
                  if (entry.id == null) {
                    await notifier.addEntry(entry);
                  } else {
                    await notifier.updateEntry(entry);
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
