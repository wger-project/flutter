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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/models/measurements/measurement_group.dart';
import 'package:wger/providers/measurement.dart';

class MeasurementCategoryForm extends StatefulWidget {
  final MeasurementCategory? category;

  const MeasurementCategoryForm({
    super.key,
    this.category,
  });

  @override
  State<MeasurementCategoryForm> createState() => _MeasurementCategoryFormState();
}

class _MeasurementCategoryFormState extends State<MeasurementCategoryForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController unitController;

  int? _categoryId;

  int? _selectedGroupId;
  String? _selectedFormula;
  bool _isSubmitting = false;

  static const Map<String, String> _formulaLabels = {
    'BMI': 'Body Mass Index (BMI)',
    // 'LBM': 'Lean Body Mass',
    // '1RM_EPLEY': '1RM — Epley formula',
  };

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    _categoryId = cat?.id;
    nameController = TextEditingController(text: cat?.name ?? '');
    unitController = TextEditingController(text: cat?.unit ?? '');

    _selectedGroupId = cat?.groupId;
    _selectedFormula = (cat?.formula == null || cat?.formula == 'NONE') ? null : cat?.formula;
  }

  @override
  void dispose() {
    nameController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final groups = Provider.of<MeasurementProvider>(context, listen: false).groups;
    return Form(
      key: _form,
      child: Column(
        children: [
          // Name
          TextFormField(
            decoration: InputDecoration(
              labelText: i18n.name,
              helperText: i18n.measurementCategoriesHelpText,
            ),
            controller: nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return i18n.enterValue;
              }
              return null;
            },
          ),

          // Unit
          TextFormField(
            decoration: InputDecoration(
              labelText: i18n.unit,
              helperText: i18n.measurementEntriesHelpText,
            ),
            controller: unitController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return i18n.enterValue;
              }
              return null;
            },
          ),

          // Group dropdown
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _selectedGroupId,
            decoration: const InputDecoration(
              labelText: 'Group (optional)',
              helperText: 'Link this category to a group e.g. "Blood Pressure"',
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('- No group -'),
              ),
              ...groups.map(
                (g) => DropdownMenuItem<int?>(
                  value: g.id,
                  child: Text(g.name),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _selectedGroupId = val),
          ),

          // Formula dropdown
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _selectedFormula,
            decoration: const InputDecoration(
              labelText: 'Auto-calculate from formula (optional)',
              helperText: 'values are computed automatically, no entry needed.',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('- Manual entry -'),
              ),
              ..._formulaLabels.entries.map(
                (e) => DropdownMenuItem<String?>(
                  value: e.key,
                  child: Text(e.value),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _selectedFormula = val),
          ),

          const SizedBox(height: 16),
          ElevatedButton(
            child: Text(i18n.save),
            onPressed: () async {
              // Validate and save the current values to the weightEntry
              final isValid = _form.currentState?.validate() ?? false;
              if (!isValid) {
                return;
              }
              _form.currentState!.save();
              setState(() => _isSubmitting = true);
              final measurementProvider = Provider.of<MeasurementProvider>(context, listen: false);

              // Save the entry on the server
              final formulaToSave = _selectedFormula ?? 'NONE';
              try {
                if (_categoryId == null) {
                  await measurementProvider.addCategory(
                    MeasurementCategory(
                      id: null,
                      name: nameController.text.trim(),
                      unit: unitController.text.trim(),
                      groupId: _selectedGroupId,
                      formula: formulaToSave,
                    ),
                  );
                } else {
                  await measurementProvider.editCategory(
                    _categoryId!,
                    nameController.text.trim(),
                    unitController.text.trim(),
                    _selectedGroupId,
                    formulaToSave,
                    clearGroup: _selectedGroupId == null,
                    clearFormula: _selectedFormula == null,
                  );
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                setState(() => _isSubmitting = false);
              }
            },
          ),
        ],
      ),
    );
  }
}

class MeasurementEntryForm extends StatefulWidget {
  final int categoryId;
  final MeasurementEntry? entry;

  const MeasurementEntryForm({
    super.key,
    required this.categoryId,
    this.entry,
  });

  @override
  State<MeasurementEntryForm> createState() => _MeasurementEntryFormState();
}

class _MeasurementEntryFormState extends State<MeasurementEntryForm> {
  final _form = GlobalKey<FormState>();
  late final int _categoryId;
  late final TextEditingController _valueController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _notesController;

  late DateTime _selectedDateTime;
  late num _selectedValue;
  late String _selectedNotes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.categoryId;
    _selectedDateTime = widget.entry?.date ?? DateTime.now();
    _selectedValue = widget.entry?.value ?? 0;
    _selectedNotes = widget.entry?.notes ?? '';
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _valueController = TextEditingController();
    _notesController = TextEditingController(text: widget.entry?.notes ?? '');
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
    final i18n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    final dateFormat = DateFormat.yMd(locale);
    final timeFormat = DateFormat.Hm(locale);

    final measurementProvider = Provider.of<MeasurementProvider>(context, listen: false);
    final measurementCategory = measurementProvider.categories.firstWhere(
      (category) => category.id == _categoryId,
    );

    if (_dateController.text.isEmpty) {
      _dateController.text = dateFormat.format(_selectedDateTime);
    }
    if (_timeController.text.isEmpty) {
      _timeController.text = timeFormat.format(_selectedDateTime);
    }

    final numberFormat = NumberFormat.decimalPattern(locale);

    // If the value is not empty, format it
    if (_valueController.text.isEmpty && widget.entry?.value != null) {
      _valueController.text = numberFormat.format(widget.entry!.value);
    }

    return Form(
      key: _form,
      child: Column(
        children: [
          // Date
          TextFormField(
            decoration: InputDecoration(
              labelText: i18n.date,
              suffixIcon: const Icon(
                Icons.calendar_today,
                key: Key('calendarIcon'),
              ),
            ),
            readOnly: true,
            // Hide text cursor
            controller: _dateController,
            onTap: () async {
              // Stop keyboard from appearing
              FocusScope.of(context).requestFocus(FocusNode());

              // Show Date Picker Here
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDateTime,
                firstDate: DateTime(DateTime.now().year - 10),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                _dateController.text = dateFormat.format(pickedDate);
              }
            },
            onSaved: (newValue) {
              final date = dateFormat.parse(newValue!);
              _selectedDateTime = _selectedDateTime.copyWith(
                year: date.year,
                month: date.month,
                day: date.day,
              );
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return i18n.enterValue;
              }
              return null;
            },
          ),

          // Time
          TextFormField(
            decoration: InputDecoration(
              labelText: i18n.time,
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
                initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
              );

              if (pickedTime != null) {
                // Use DateFormat.Hm to stay consistent with onSaved parsing
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
              _selectedDateTime = _selectedDateTime.copyWith(
                hour: time.hour,
                minute: time.minute,
                second: time.second,
              );
            },
          ),

          // Value
          TextFormField(
            decoration: InputDecoration(
              labelText: i18n.value,
              suffixIcon: Text(measurementCategory.unit),
              suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            controller: _valueController,
            keyboardType: textInputTypeDecimal,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return i18n.enterValue;
              }
              try {
                numberFormat.parse(value);
              } catch (error) {
                return i18n.enterValidNumber;
              }
              return null;
            },
            onSaved: (newValue) {
              _selectedValue = numberFormat.parse(newValue!);
            },
          ),
          // Notes
          TextFormField(
            decoration: InputDecoration(labelText: i18n.notes),
            controller: _notesController,
            onSaved: (newValue) {
              _selectedNotes = newValue!;
            },
            validator: (value) {
              const minLength = 0;
              const maxLength = 100;
              if (value!.isNotEmpty && (value.length < minLength || value.length > maxLength)) {
                return i18n.enterCharacters(
                  minLength.toString(),
                  maxLength.toString(),
                );
              }
              return null;
            },
          ),

          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    // Validate and save the current values to the weightEntry
                    final isValid = _form.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    setState(() => _isSubmitting = true);
                    _form.currentState!.save();

                    final provider = Provider.of<MeasurementProvider>(context, listen: false);
                    try {
                      // Save the entry on the server
                      widget.entry == null
                          ? await provider.addEntry(
                              MeasurementEntry(
                                id: null,
                                category: _categoryId,
                                date: _selectedDateTime,
                                value: _selectedValue,
                                notes: _selectedNotes,
                              ),
                            )
                          : await provider.editEntry(
                              widget.entry!.id!,
                              _categoryId,
                              _selectedValue,
                              _selectedNotes,
                              _selectedDateTime,
                            );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      debugPrint('Save failed: $e');
                    } finally {
                      setState(() => _isSubmitting = false);
                    }
                  },
            child: Text(i18n.save),
          ),
        ],
      ),
    );
  }
}
