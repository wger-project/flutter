/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

/// Read-only field that opens a time picker on tap.
///
/// The selected time is reported through [onChanged]; the caller keeps the
/// source of truth and decides how to store it. The displayed text uses the
/// active locale's time format (12h with AM/PM where the device prefers it),
/// so it must never be parsed back into a [TimeOfDay].
///
/// When [onCleared] is provided, a clear button is shown while a value is set.
class TimeInputWidget extends StatefulWidget {
  const TimeInputWidget({
    required this.value,
    required this.onChanged,
    required this.labelText,
    this.onCleared,
    this.validator,
    super.key,
  });

  /// The currently selected time, or null when unset.
  final TimeOfDay? value;

  /// Called with the time picked from the dialog.
  final ValueChanged<TimeOfDay> onChanged;

  final String labelText;

  /// When provided, a clear button is shown while [value] is set; tapping it
  /// invokes this callback.
  final VoidCallback? onCleared;

  /// Optional form validator. The argument is the displayed text; cross-field
  /// rules should read the source of truth from the surrounding state instead.
  final FormFieldValidator<String>? validator;

  @override
  State<TimeInputWidget> createState() => _TimeInputWidgetState();
}

class _TimeInputWidgetState extends State<TimeInputWidget> {
  late final TextEditingController _controller;
  TimeOfDay? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    // initialize controller in initState(), format time in didChangeDependencies()
    _controller = TextEditingController(text: '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.text = _value?.format(context) ?? '';
  }

  @override
  void didUpdateWidget(TimeInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // rebuild if new value received from parent and format the time
    if (widget.value != oldWidget.value) {
      _value = widget.value;
      _controller.text = _value?.format(context) ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: _controller,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        errorMaxLines: 2,
        suffixIcon: widget.onCleared != null && _value != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _value = null;
                    _controller.clear();
                  });
                  widget.onCleared!();
                },
              )
            : const Icon(Icons.access_time_outlined),
      ),
      onTap: () async {
        // Stop the keyboard from appearing for the read-only field.
        FocusScope.of(context).requestFocus(FocusNode());

        final picked = await showTimePicker(
          context: context,
          initialTime: _value ?? TimeOfDay.now(),
        );
        if (picked != null && context.mounted) {
          setState(() {
            _value = picked;
            _controller.text = picked.format(context);
          });
          widget.onChanged(picked);
        }
      },
    );
  }
}

/// Read-only field that opens a date picker on tap.
///
/// The selected date is reported through [onChanged]; the caller keeps the
/// source of truth and decides how to store it. The displayed text uses the
/// active locale's date format.
///
/// When [onCleared] is provided, a clear button is shown while a value is set.
class DateInputWidget extends StatefulWidget {
  const DateInputWidget({
    required this.value,
    required this.onChanged,
    required this.labelText,
    this.firstDate,
    this.lastDate,
    this.onCleared,
    this.validator,
    this.helperText,
    super.key,
  });

  /// The currently selected date, or null when unset.
  final DateTime? value;

  /// Called with the date picked from the dialog.
  final ValueChanged<DateTime> onChanged;

  final String labelText;

  /// Optional hint shown below the field.
  final String? helperText;

  /// Earliest selectable date. Defaults to the year 2000.
  final DateTime? firstDate;

  /// Latest selectable date. Defaults to the year 2100.
  final DateTime? lastDate;

  /// When provided, a clear button is shown while [value] is set; tapping it
  /// invokes this callback.
  final VoidCallback? onCleared;

  /// Optional form validator. The argument is the displayed text; cross-field
  /// rules should read the source of truth from the surrounding state instead.
  final FormFieldValidator<String>? validator;

  @override
  State<DateInputWidget> createState() => _DateInputWidgetState();
}

class _DateInputWidgetState extends State<DateInputWidget> {
  late final TextEditingController _controller;
  DateTime? _value;
  late DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    _dateFormat = DateFormat.yMd('en');
    _controller = TextEditingController(text: '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update formatter if locale changes
    final locale = Localizations.localeOf(context).languageCode;
    final newPattern = DateFormat.yMd(locale).pattern;
    if (newPattern != _dateFormat.pattern) {
      _dateFormat = DateFormat.yMd(locale);
      _controller.text = _formatDate(_value);
    }
  }

  @override
  void didUpdateWidget(DateInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _value = widget.value;
      _controller.text = _formatDate(_value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    return date != null ? _dateFormat.format(date) : '';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: _controller,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
        errorMaxLines: 2,
        suffixIcon: widget.onCleared != null && _value != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _value = null;
                    _controller.clear();
                  });
                  widget.onCleared!();
                },
              )
            : const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        // Stop the keyboard from appearing for the read-only field.
        FocusScope.of(context).requestFocus(FocusNode());

        final picked = await showDatePicker(
          context: context,
          initialDate: _value ?? DateTime.now(),
          firstDate: widget.firstDate ?? DateTime(2000),
          lastDate: widget.lastDate ?? DateTime(2100),
        );
        if (picked != null && context.mounted) {
          setState(() {
            _value = picked;
            _controller.text = _formatDate(_value);
          });
          widget.onChanged(picked);
        }
      },
    );
  }
}
