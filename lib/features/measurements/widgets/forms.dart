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
import 'package:wger/core/widgets/error.dart';
import 'package:wger/core/widgets/form_submit_button.dart';
import 'package:wger/core/widgets/progress_indicator.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

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
    // A category with children is a group whatever its metric type says, which
    // is also how the charts decide. Both the chart type and the parent are
    // meaningless for one
    final categories = ref.watch(measurementProvider).asData?.value ?? [];
    final hasChildren = _draft.id != null && categories.any((c) => c.parentId == _draft.id);

    // What the chart type picker offers: no override, plus what this metric
    // type may be drawn as. Empty for a group, whose chart follows from what
    // its components are to each other rather than from a preference
    final chartTypes = hasChildren || _draft.metricType.availableChartTypes.isEmpty
        ? const <ChartType>[]
        : [ChartType.auto, ..._draft.metricType.availableChartTypes];

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

          // metricType. Official types are reserved for the categories the
          // server manages, components are a structural type: they only exist
          // as the children of their group, which is created with them
          DropdownButtonFormField(
            initialValue: _draft.metricType,
            decoration: InputDecoration(labelText: AppLocalizations.of(context).metricType),
            items: MetricType.values
                .where((t) => (!t.isOfficial && !t.isComponent) || t == _draft.metricType)
                .map((t) => DropdownMenuItem(value: t, child: Text(t.localized(context))))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _draft = _draft.copyWith(metricType: value);
                });
              }
            },
          ),

          // Chart type. Only the shapes that are a matter of taste are offered,
          // and only those the metric type can actually be drawn as; a group
          // gets none, its chart follows from what its components are
          if (chartTypes.isNotEmpty)
            DropdownButtonFormField(
              // A type stored by a client that offers more of them than this
              // one falls back to the derived chart, so it shows as automatic
              initialValue: chartTypes.contains(_draft.chartType)
                  ? _draft.chartType
                  : ChartType.auto,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).chartType),
              items: chartTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.localized(context))))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _draft = _draft.copyWith(chartType: value);
                  });
                }
              },
            ),

          // Parent group (multi-value measurements, e.g. blood pressure).
          // Mirrors the server rules: only top-level, entry-free categories
          // can be parents, a category with children cannot be nested, a typed
          // category stays top-level, and a group takes only its own
          // components (which it is created with).
          Builder(
            builder: (context) {
              if (hasChildren || _draft.metricType != MetricType.custom) {
                return const SizedBox.shrink();
              }

              final candidates = categories
                  .where(
                    (c) =>
                        c.parentId == null &&
                        c.id != _draft.id &&
                        c.entries.isEmpty &&
                        !c.isOfficialBodyWeight &&
                        !c.metricType.isGroup,
                  )
                  .toList();
              if (candidates.isEmpty) {
                return const SizedBox.shrink();
              }

              final initialParent = candidates.any((c) => c.id == _draft.parentId)
                  ? _draft.parentId
                  : null;

              return DropdownButtonFormField<String?>(
                initialValue: initialParent,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).partOfGroup,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(AppLocalizations.of(context).noGroup),
                  ),
                  ...candidates.map(
                    (c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _draft = _draft.copyWith(parentId: value);
                  });
                },
              );
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
                min: category.metricType.limits(category.unit).min,
                max: category.metricType.limits(category.unit).max,
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

                  // Source, external id and extra data are not editable; keep
                  // the existing values so edits to imported entries stay
                  // deduplicable and the entered unit survives
                  final entry = MeasurementEntry(
                    id: _existingId,
                    categoryId: category.id!,
                    date: _date,
                    value: _value!,
                    notes: _notes,
                    source: widget._entry?.source ?? 'user',
                    externalId: widget._entry?.externalId,
                    extraData: widget._entry?.extraData,
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
