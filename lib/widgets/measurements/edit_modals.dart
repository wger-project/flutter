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
import 'package:wger/providers/measurement.dart';
import 'package:wger/theme/theme.dart';

/// Shows a modern modal bottom sheet for editing a measurement entry
void showEditEntryModal(
  BuildContext context,
  MeasurementCategory category,
  MeasurementEntry? entry,
) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final isNewEntry = entry == null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EditEntryModalContent(
      category: category,
      entry: entry,
      isDarkMode: isDarkMode,
      isNewEntry: isNewEntry,
    ),
  );
}

class _EditEntryModalContent extends StatefulWidget {
  final MeasurementCategory category;
  final MeasurementEntry? entry;
  final bool isDarkMode;
  final bool isNewEntry;

  const _EditEntryModalContent({
    required this.category,
    required this.entry,
    required this.isDarkMode,
    required this.isNewEntry,
  });

  @override
  State<_EditEntryModalContent> createState() => _EditEntryModalContentState();
}

class _EditEntryModalContentState extends State<_EditEntryModalContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _valueController;
  late TextEditingController _dateController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.entry?.date ?? DateTime.now();
    _valueController = TextEditingController();
    _dateController = TextEditingController();
    _notesController = TextEditingController(text: widget.entry?.notes ?? '');
  }

  @override
  void dispose() {
    _valueController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    if (_dateController.text.isEmpty) {
      _dateController.text = dateFormat.format(_selectedDate);
    }
    if (_valueController.text.isEmpty && widget.entry?.value != null) {
      _valueController.text = numberFormat.format(widget.entry!.value);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title
                  Text(
                    widget.isNewEntry
                        ? AppLocalizations.of(context).newEntry
                        : AppLocalizations.of(context).edit,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Date field
                  _buildTextField(
                    controller: _dateController,
                    label: AppLocalizations.of(context).date,
                    readOnly: true,
                    suffixIcon: Icons.calendar_today_rounded,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(DateTime.now().year - 10),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                          _dateController.text = dateFormat.format(pickedDate);
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).enterValue;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Value field
                  _buildTextField(
                    controller: _valueController,
                    label: AppLocalizations.of(context).value,
                    keyboardType: textInputTypeDecimal,
                    suffixText: widget.category.unit,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
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
                  const SizedBox(height: 16),
                  // Notes field
                  _buildTextField(
                    controller: _notesController,
                    label: AppLocalizations.of(context).notes,
                    maxLines: 2,
                    validator: (value) {
                      if (value != null && value.length > 100) {
                        return AppLocalizations.of(context).enterCharacters('0', '100');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Save button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: wgerAccentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context).save,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType? keyboardType,
    IconData? suffixIcon,
    String? suffixText,
    int maxLines = 1,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onTap: onTap,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        filled: true,
        fillColor: widget.isDarkMode
            ? Colors.grey.shade800.withValues(alpha: 0.5)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: wgerAccentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
        ),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: wgerAccentColor, size: 18) : null,
        suffixText: suffixText,
        suffixStyle: TextStyle(
          color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final value = numberFormat.parse(_valueController.text);
    final provider = Provider.of<MeasurementProvider>(context, listen: false);

    try {
      if (widget.isNewEntry) {
        await provider.addEntry(
          MeasurementEntry(
            id: null,
            category: widget.category.id!,
            date: _selectedDate,
            value: value,
            notes: _notesController.text,
          ),
        );
      } else {
        await provider.editEntry(
          widget.entry!.id!,
          widget.entry!.category,
          value,
          _notesController.text,
          _selectedDate,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).anErrorOccurred,
              textAlign: TextAlign.center,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Shows a modern modal bottom sheet for editing a measurement category
void showEditCategoryModal(
  BuildContext context,
  MeasurementCategory? category,
) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final isNewCategory = category == null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EditCategoryModalContent(
      category: category,
      isDarkMode: isDarkMode,
      isNewCategory: isNewCategory,
    ),
  );
}

class _EditCategoryModalContent extends StatefulWidget {
  final MeasurementCategory? category;
  final bool isDarkMode;
  final bool isNewCategory;

  const _EditCategoryModalContent({
    required this.category,
    required this.isDarkMode,
    required this.isNewCategory,
  });

  @override
  State<_EditCategoryModalContent> createState() => _EditCategoryModalContentState();
}

class _EditCategoryModalContentState extends State<_EditCategoryModalContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _unitController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _unitController = TextEditingController(text: widget.category?.unit ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title
                  Text(
                    widget.isNewCategory
                        ? AppLocalizations.of(context).newEntry
                        : AppLocalizations.of(context).edit,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Name field
                  _buildTextField(
                    controller: _nameController,
                    label: AppLocalizations.of(context).name,
                    helperText: AppLocalizations.of(context).measurementCategoriesHelpText,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).enterValue;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Unit field
                  _buildTextField(
                    controller: _unitController,
                    label: AppLocalizations.of(context).unit,
                    helperText: AppLocalizations.of(context).measurementEntriesHelpText,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).enterValue;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Save button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: wgerAccentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context).save,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 2,
        filled: true,
        fillColor: widget.isDarkMode
            ? Colors.grey.shade800.withValues(alpha: 0.5)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: wgerAccentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<MeasurementProvider>(context, listen: false);

    try {
      if (widget.isNewCategory) {
        await provider.addCategory(
          MeasurementCategory(
            id: null,
            name: _nameController.text,
            unit: _unitController.text,
          ),
        );
      } else {
        await provider.editCategory(
          widget.category!.id!,
          _nameController.text,
          _unitController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).anErrorOccurred,
              textAlign: TextAlign.center,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
