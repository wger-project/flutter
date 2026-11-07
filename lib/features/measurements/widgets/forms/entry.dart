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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/widgets/datetime_input.dart';
import 'package:wger/core/widgets/decimal_input.dart';
import 'package:wger/core/widgets/error.dart';
import 'package:wger/core/widgets/form_submit_button.dart';
import 'package:wger/core/widgets/progress_indicator.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class MeasurementEntryForm extends ConsumerStatefulWidget {
  final String _categoryId;
  final MeasurementEntry? _entry;

  const MeasurementEntryForm(this._categoryId, [MeasurementEntry? entry]) : _entry = entry;

  @override
  ConsumerState<MeasurementEntryForm> createState() => _MeasurementEntryFormState();
}

class _MeasurementEntryFormState extends ConsumerState<MeasurementEntryForm> {
  final _form = GlobalKey<FormState>();

  late MeasurementEntry _draft;

  /// The one field kept outside [_draft]: an entry's value is non-null, while
  /// the field starts empty for a new one and only has a value once it passes
  /// validation. Folded into the draft on save.
  num? _value;

  @override
  void initState() {
    super.initState();
    _draft =
        widget._entry ??
        MeasurementEntry(
          categoryId: widget._categoryId,
          date: DateTime.now(),
          value: 0,
          notes: '',
        );
    _value = widget._entry?.value;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(measurementProvider.notifier);
    // Watched rather than read once: the form only needs name, unit and the
    // limits, and a re-emission leaves the fields it does not feed alone
    final categoryAsync = ref.watch(measurementCategoryProvider(widget._categoryId));

    return categoryAsync.when(
      loading: () => const BoxedProgressIndicator(),
      error: (error, _) => StreamErrorIndicator(error.toString()),
      data: (category) {
        if (category == null) {
          return const Text('Category not found');
        }

        return Form(
          key: _form,
          child: Column(
            children: [
              DateTimeInputWidget(
                value: _draft.date,
                onChanged: (date) => _draft = _draft.copyWith(date: date),
              ),

              // Value
              DecimalInputWidget(
                value: _value,
                labelText: AppLocalizations.of(context).value,
                suffixText: category.unit,
                isRequired: true,
                min: category.metricType.limits(category.unit).min,
                max: category.metricType.limits(category.unit).max,
                onChanged: (value) => _value = value,
              ),
              // Notes
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context).notes),
                initialValue: _draft.notes,
                onSaved: (newValue) {
                  _draft = _draft.copyWith(notes: newValue ?? '');
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

                  // The draft carries what the form does not offer (source,
                  // external id, extra data), so an edited import stays
                  // deduplicable and the unit it was entered in survives
                  final entry = _draft.copyWith(value: _value!);
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
