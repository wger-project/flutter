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

import 'package:material_ui/material_ui.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

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
  TimeOfDay? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(TimeInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keyed initialValue, not a controller: a controller notifies the enclosing
    // Form on assignment, which crashes if that happens during a build.
    return TextFormField(
      key: ValueKey(_value),
      readOnly: true,
      initialValue: _value?.format(context) ?? '',
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        errorMaxLines: 2,
        suffixIcon: widget.onCleared != null && _value != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() => _value = null);
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
          setState(() => _value = picked);
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
  DateTime? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(DateInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = localizedDate(context);
    // Keyed initialValue, not a controller: a controller notifies the enclosing
    // Form on assignment, which crashes if that happens during a build.
    return TextFormField(
      key: ValueKey(_value),
      readOnly: true,
      initialValue: _value != null ? dateFormat.format(_value!) : '',
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
        errorMaxLines: 2,
        suffixIcon: widget.onCleared != null && _value != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() => _value = null);
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
          setState(() => _value = picked);
          widget.onChanged(picked);
        }
      },
    );
  }
}

/// The two halves of one [DateTime]: a date field above a time field, each
/// reporting the whole moment through [onChanged].
///
/// For the entries that are stamped with a single point in time. Where date
/// and time are stored apart (a meal has a time and no date), the two fields
/// are used on their own instead.
class DateTimeInputWidget extends StatefulWidget {
  const DateTimeInputWidget({
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  /// The moment both fields show, and the one edits are applied to.
  final DateTime value;

  /// Called with the full moment after either half was picked.
  final ValueChanged<DateTime> onChanged;

  /// Earliest selectable date, ten years back by default.
  final DateTime? firstDate;

  /// Latest selectable date, today by default.
  final DateTime? lastDate;

  @override
  State<DateTimeInputWidget> createState() => _DateTimeInputWidgetState();
}

class _DateTimeInputWidgetState extends State<DateTimeInputWidget> {
  /// The moment as far as it has been edited. Kept here because the callers
  /// collect what they build without rebuilding, so the value passed in would
  /// still be the one the form started with when the second half is picked.
  late DateTime _value = widget.value;

  void _report(DateTime value) {
    setState(() => _value = value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Column(
      children: [
        DateInputWidget(
          value: _value,
          labelText: i18n.date,
          firstDate: widget.firstDate ?? DateTime(DateTime.now().year - 10),
          lastDate: widget.lastDate ?? DateTime.now(),
          onChanged: (date) => _report(
            _value.copyWith(year: date.year, month: date.month, day: date.day),
          ),
        ),
        TimeInputWidget(
          value: TimeOfDay.fromDateTime(_value),
          labelText: i18n.time,
          onChanged: (time) => _report(
            _value.copyWith(hour: time.hour, minute: time.minute, second: 0),
          ),
        ),
      ],
    );
  }
}
