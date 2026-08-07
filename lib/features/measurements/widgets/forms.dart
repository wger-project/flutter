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
    final categories = ref.watch(measurementCategoriesProvider).value ?? const [];
    final hasChildren = _draft.id != null && categories.any((c) => c.parentId == _draft.id);
    // Which categories hold entries, for the group check below: the map has a
    // key exactly for those, and is loaded for the screens anyway
    final withEntries = ref.watch(latestMeasurementEntriesProvider).value ?? const {};

    // What the chart type picker offers: no override, plus what this metric
    // type may be drawn as. Empty for a group, whose chart follows from what
    // its components are to each other rather than from a preference
    final chartTypes = hasChildren || _draft.metricType.availableChartTypes.isEmpty
        ? const <ChartType>[]
        : [ChartType.auto, ..._draft.metricType.availableChartTypes];

    // Name and unit belong to the user only for a free-form category. A typed
    // one takes both from its metric type, which is also what is shown for it
    final isCustom = _draft.metricType == MetricType.custom;

    // The trend line and the moving average are parts of the line chart: a
    // category that can never be drawn as one is not offered them at all, and
    // one that is currently drawn as something else keeps its settings but
    // cannot change them
    final canDrawLine =
        !hasChildren && _draft.metricType.availableChartTypes.contains(ChartType.line);
    final drawsLine = _draft.metricType.resolveChartType(_draft.chartType) == ChartType.line;
    final settings = _draft.chartSettings;

    return Form(
      key: _form,
      child: Column(
        children: [
          // Name
          if (isCustom)
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
          if (isCustom)
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

          // The metric type is picked when the category is created (see
          // MetricPickerSheet) and fixed from then on: the key of a typed
          // category is derived from it, and the server refuses a change

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

          // Trend character and average window, disabled while the category is
          // drawn as something that has neither
          if (canDrawLine) ...[
            DropdownButtonFormField<TrendCharacter>(
              initialValue: settings.trend,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).chartTrend),
              items: TrendCharacter.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.localized(context))))
                  .toList(),
              onChanged: drawsLine
                  ? (value) {
                      if (value != null) {
                        setState(() {
                          _draft = _draft.withChartSetting('trend', value.wireValue);
                        });
                      }
                    }
                  : null,
            ),
            DropdownButtonFormField<int>(
              initialValue: settings.averageWindow,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).chartAverageWindow,
              ),
              items: ChartSettings.averageWindows
                  .map(
                    (days) => DropdownMenuItem(
                      value: days,
                      child: Text(AppLocalizations.of(context).chartAverageWindowDays(days)),
                    ),
                  )
                  .toList(),
              onChanged: drawsLine
                  ? (value) {
                      if (value != null) {
                        setState(() {
                          _draft = _draft.withChartSetting('average_window', value);
                        });
                      }
                    }
                  : null,
            ),
          ],

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
                        !withEntries.containsKey(c.id) &&
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
    _notesController.text = _draft.notes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
                controller: _notesController,
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
