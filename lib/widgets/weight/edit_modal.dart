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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/theme/theme.dart';

/// Shows a modern modal bottom sheet for adding/editing a weight entry
void showEditWeightModal(BuildContext context, WeightEntry? entry) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final isNewEntry = entry == null || entry.id == null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EditWeightModalContent(
      entry: entry,
      isDarkMode: isDarkMode,
      isNewEntry: isNewEntry,
    ),
  );
}

class _EditWeightModalContent extends StatefulWidget {
  final WeightEntry? entry;
  final bool isDarkMode;
  final bool isNewEntry;

  const _EditWeightModalContent({
    required this.entry,
    required this.isDarkMode,
    required this.isNewEntry,
  });

  @override
  State<_EditWeightModalContent> createState() => _EditWeightModalContentState();
}

class _EditWeightModalContentState extends State<_EditWeightModalContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.entry?.date ?? now;
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    _weightController = TextEditingController();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    if (_dateController.text.isEmpty) {
      _dateController.text = dateFormat.format(_selectedDate);
    }
    if (_timeController.text.isEmpty) {
      _timeController.text = _selectedTime.format(context);
    }
    if (_weightController.text.isEmpty &&
        widget.entry?.weight != null &&
        widget.entry!.weight != 0) {
      _weightController.text = numberFormat.format(widget.entry!.weight);
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
                  // Date and Time fields in a row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
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
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _timeController,
                          label: AppLocalizations.of(context).time,
                          readOnly: true,
                          suffixIcon: Icons.access_time_rounded,
                          onTap: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _selectedTime = pickedTime;
                                _timeController.text = pickedTime.format(context);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Weight field with +/- buttons
                  _buildWeightField(numberFormat),
                  const SizedBox(height: 24),
                  // Save button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveWeight,
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
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
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
          borderSide: const BorderSide(color: wgerAccentColor, width: 2),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildWeightField(NumberFormat numberFormat) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.grey.shade800.withValues(alpha: 0.5)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Minus buttons
          _buildLabeledButton(
            label: '-1',
            onTap: () => _adjustWeight(-1, numberFormat),
            isFirst: true,
          ),
          _buildLabeledButton(
            label: '-.1',
            onTap: () => _adjustWeight(-0.1, numberFormat),
          ),
          // Weight input
          Expanded(
            child: TextFormField(
              controller: _weightController,
              keyboardType: textInputTypeDecimal,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: TextStyle(
                  color: context.wgerLightGrey,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
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
          ),
          // Plus buttons
          _buildLabeledButton(
            label: '+.1',
            onTap: () => _adjustWeight(0.1, numberFormat),
          ),
          _buildLabeledButton(
            label: '+1',
            onTap: () => _adjustWeight(1, numberFormat),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledButton({
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: isFirst ? 8 : 4,
        right: isLast ? 8 : 4,
        top: 8,
        bottom: 8,
      ),
      child: Material(
        color: wgerAccentColor.withValues(alpha: widget.isDarkMode ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: wgerAccentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _adjustWeight(double delta, NumberFormat numberFormat) {
    try {
      final currentValue = _weightController.text.isNotEmpty
          ? numberFormat.parse(_weightController.text)
          : 0.0;
      final newValue = currentValue + delta;
      if (newValue >= 0) {
        _weightController.text = numberFormat.format(newValue);
      }
    } on FormatException {
      // Ignore format errors
    }
  }

  Future<void> _saveWeight() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final weight = numberFormat.parse(_weightController.text);
    final provider = Provider.of<BodyWeightProvider>(context, listen: false);

    // Combine date and time
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      final entry = WeightEntry(
        id: widget.entry?.id,
        date: dateTime,
        weight: weight,
      );

      if (widget.isNewEntry) {
        await provider.addEntry(entry);
      } else {
        await provider.editEntry(entry);
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
