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
import 'package:wger/core/widgets/datetime_input.dart';
import 'package:wger/core/widgets/decimal_input.dart';
import 'package:wger/core/widgets/form_submit_button.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Entry form for a multi-value group (e.g. blood pressure): one value field
/// per component, saved as one entry per component with a shared timestamp.
class GroupMeasurementEntryForm extends ConsumerStatefulWidget {
  final MeasurementCategory _group;

  const GroupMeasurementEntryForm(this._group);

  @override
  ConsumerState<GroupMeasurementEntryForm> createState() => _GroupMeasurementEntryFormState();
}

class _GroupMeasurementEntryFormState extends ConsumerState<GroupMeasurementEntryForm> {
  final _form = GlobalKey<FormState>();

  DateTime _date = DateTime.now();
  late final Map<String, num?> _values = {
    for (final child in widget._group.children) child.id!: null,
  };

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          // Date and time are shared by all components of the reading
          DateTimeInputWidget(
            value: _date,
            onChanged: (date) => _date = date,
          ),

          // One value field per component, each bounded by its own type:
          // systolic and diastolic do not share a range
          for (final child in widget._group.children)
            DecimalInputWidget(
              value: _values[child.id],
              labelText: child.displayName(context),
              suffixText: child.unit.isNotEmpty ? child.unit : widget._group.unit,
              isRequired: true,
              min: child.metricType.limits(child.unit).min,
              max: child.metricType.limits(child.unit).max,
              onChanged: (value) => _values[child.id!] = value,
            ),

          FormSubmitButton(
            label: AppLocalizations.of(context).save,
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }
              _form.currentState!.save();

              final entries = widget._group.children
                  .map(
                    (child) => MeasurementEntry(
                      categoryId: child.id!,
                      date: _date,
                      value: _values[child.id]!,
                      notes: '',
                    ),
                  )
                  .toList();
              await ref.read(measurementProvider.notifier).addGroupEntries(entries);

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
