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
import 'package:intl/intl.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/measurement_notifier.dart';
import 'package:wger/widgets/core/error.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

class MeasurementCategoryForm extends ConsumerWidget {
  final _form = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final unitController = TextEditingController();

  final String? _existingId;

  MeasurementCategoryForm([MeasurementCategory? category]) : _existingId = category?.id {
    nameController.text = category?.name ?? '';
    unitController.text = category?.unit ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: _form,
      child: Column(
        children: [
          // Name
          TextFormField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).name,
              helperText: AppLocalizations.of(context).measurementCategoriesHelpText,
            ),
            controller: nameController,
            validator: (value) {
              if (value!.isEmpty) {
                return AppLocalizations.of(context).enterValue;
              }
              return null;
            },
          ),

          // Unit
          TextFormField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).unit,
              helperText: AppLocalizations.of(context).measurementEntriesHelpText,
            ),
            controller: unitController,
            validator: (value) {
              if (value!.isEmpty) {
                return AppLocalizations.of(context).enterValue;
              }
              return null;
            },
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              final notifier = ref.read(measurementProvider.notifier);
              final category = MeasurementCategory(
                id: _existingId,
                name: nameController.text,
                unit: unitController.text,
              );

              if (category.id == null) {
                await notifier.addCategory(category);
              } else {
                notifier.updateCategory(category);
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

  const MeasurementEntryForm(this._categoryId, [MeasurementEntry? entry])
    : _entry = entry;

  @override
  ConsumerState<MeasurementEntryForm> createState() => _MeasurementEntryFormState();
}

class _MeasurementEntryFormState extends ConsumerState<MeasurementEntryForm> {
  final _form = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
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
    _valueController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    final timeFormat = DateFormat.Hm(Localizations.localeOf(context).languageCode);

    final notifier = ref.read(measurementProvider.notifier);
    final Future<MeasurementCategory?> categoryFuture = notifier.getCategoryById(
      widget._categoryId,
    );

    if (_dateController.text.isEmpty) {
      _dateController.text = dateFormat.format(_date);
    }
    if (_timeController.text.isEmpty) {
      _timeController.text = timeFormat.format(_date);
    }

    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    // If the value is not empty, format it
    if (_valueController.text.isEmpty && _value != null) {
      _valueController.text = numberFormat.format(_value);
    }

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
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).date,
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    key: Key('calendarIcon'),
                  ),
                ),
                readOnly: true,
                controller: _dateController,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());

                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(DateTime.now().year - 10),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    _dateController.text = dateFormat.format(pickedDate);
                  }
                },
                onSaved: (newValue) {
                  final date = dateFormat.parse(newValue!);
                  _date = _date.copyWith(year: date.year, month: date.month, day: date.day);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context).enterValue;
                  }
                  return null;
                },
              ),

              // Time
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).time,
                  suffixIcon: const Icon(
                    Icons.access_time_outlined,
                    key: Key('clockIcon'),
                  ),
                ),
                readOnly: true,
                controller: _timeController,
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_date),
                  );

                  if (pickedTime != null) {
                    final now = DateTime.now();
                    final dt = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    _timeController.text = timeFormat.format(dt);
                  }
                },
                onSaved: (newValue) {
                  final time = timeFormat.parse(newValue!);
                  _date = _date.copyWith(
                    hour: time.hour,
                    minute: time.minute,
                    second: time.second,
                  );
                },
              ),

              // Value
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).value,
                  suffixIcon: Text(category.unit),
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                controller: _valueController,
                keyboardType: textInputTypeDecimal,
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
                onSaved: (newValue) {
                  _value = numberFormat.parse(newValue!);
                },
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

              ElevatedButton(
                child: Text(AppLocalizations.of(context).save),
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
