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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/widgets/form_submit_button.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/exercises/providers/exercises_notifier.dart';
import 'package:wger/features/measurements/models/measurement_calculation.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/widgets/calculation_params.dart';
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

  /// What the name and the unit field were last seeded with, and the key they
  /// are rebuilt under. Picking a calculation prefills both, which a
  /// controllerless field only takes as a new [Key].
  late String _nameSeed;
  late String _unitSeed;

  /// Whether the user wrote the name or the unit themselves. A prefill is a
  /// suggestion, so it stops as soon as there is something to overwrite; an
  /// existing category counts as written throughout.
  late bool _nameEdited;
  late bool _unitEdited;

  @override
  void initState() {
    super.initState();
    _draft = widget._category ?? MeasurementCategory();
    _nameSeed = _draft.name;
    _unitSeed = _draft.unit;
    _nameEdited = widget._category != null;
    _unitEdited = widget._category != null;
  }

  /// Switches the form to [type]: its parameters start at their defaults, and
  /// name and unit are prefilled as long as the user has not written their own.
  ///
  /// [exercises] is the local catalogue, for the calculations that start with
  /// a selection.
  void _pickCalculation(CalculationType type, List<Exercise> exercises) {
    setState(() {
      _draft = _draft.copyWith(dynamicType: type.slug, dynamicParams: defaultParams(type));
      if (!_nameEdited) {
        _nameSeed = type.localizedName(context);
        _draft = _draft.copyWith(name: _nameSeed);
      }
      if (!_unitEdited) {
        _unitSeed = type.unit;
        _draft = _draft.copyWith(unit: _unitSeed);
      }
      // Bench press, squat and deadlift, the total most people mean. The
      // catalogue is local, so an instance that never synced them just starts
      // with nothing
      final multi = type.params.whereType<ExercisesParam>().firstOrNull;
      if (multi != null) {
        final bigThree = [
          for (final uuid in bigThreeUuids)
            ...exercises.where((e) => e.uuid == uuid).map((e) => e.id),
        ];
        if (bigThree.length == bigThreeUuids.length) {
          _draft = _draft.copyWith(
            dynamicParams: {...?_draft.dynamicParams, multi.key: bigThree},
          );
        }
      }
    });
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

    // Name and unit belong to the user only for a free-form category. A typed
    // one takes both from its metric type, which is also what is shown for it
    final isCustom = _draft.metricType == MetricType.custom;

    final i18n = AppLocalizations.of(context);
    // Watched rather than read where the prefill happens: a read subscribes
    // the stream and returns before it has emitted, i.e. an empty catalogue
    final exercises = ref.watch(exercisesProvider).value?.exercises ?? const <Exercise>[];

    return Form(
      key: _form,
      // Scrolls itself: the form grows by a whole block when a calculation is
      // picked, and the screen hands it the space rather than a viewport
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Name. The key is the prefill rather than the text: a controllerless
            // field takes a new seed only as a new key, and one that followed
            // what is typed would rebuild the field on every keystroke
            if (isCustom)
              TextFormField(
                key: ValueKey('name-$_nameSeed'),
                initialValue: _nameSeed,
                decoration: InputDecoration(
                  labelText: i18n.name,
                  helperText: i18n.measurementCategoriesHelpText,
                ),
                maxLength: MeasurementCategory.maxNameChars,
                onChanged: (_) => _nameEdited = true,
                onSaved: (value) => _draft = _draft.copyWith(name: value ?? ''),
                validator: (value) {
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
                key: ValueKey('unit-$_unitSeed'),
                initialValue: _unitSeed,
                decoration: InputDecoration(
                  labelText: i18n.unit,
                  helperText: i18n.measurementEntriesHelpText,
                ),
                maxLength: MeasurementCategory.maxUnitChars,
                onChanged: (_) => _unitEdited = true,
                onSaved: (value) => _draft = _draft.copyWith(unit: value ?? ''),
                validator: (value) {
                  // A calculation defines what the number is, so it may well be
                  // a bare ratio without a unit
                  if (value!.isEmpty) {
                    return _draft.isCalculated ? null : i18n.enterValue;
                  }
                  if (value.length > MeasurementCategory.maxUnitChars) {
                    return i18n.enterMaxCharacters(MeasurementCategory.maxUnitChars.toString());
                  }
                  return null;
                },
              ),

            _CalculationSection(
              draft: _draft,
              stored: widget._category,
              categories: categories,
              // A typed category is written by the health import or by the
              // server itself, and a group carries no entries at all
              canCalculate: isCustom,
              onPick: (type) => _pickCalculation(type, exercises),
              onManual: () => setState(() {
                _draft = _draft.copyWith(dynamicType: noDynamicType, dynamicParams: null);
              }),
              onParamsChanged: (params) => setState(() {
                _draft = _draft.copyWith(dynamicParams: params);
              }),
            ),

            // The metric type is picked when the category is created (see
            // MetricPickerSheet) and fixed from then on: the key of a typed
            // category is derived from it, and the server refuses a change
            _ChartSettingsSection(
              draft: _draft,
              hasChildren: hasChildren,
              onChartTypeChanged: (value) => setState(() {
                _draft = _draft.copyWith(chartType: value);
              }),
              onSettingChanged: (key, value) => setState(() {
                _draft = _draft.withChartSetting(key, value);
              }),
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
      ),
    );
  }
}

/// How a category is drawn: the chart it is shown as, and the two settings of
/// the line. Renders nothing where the metric type leaves no choice.
class _ChartSettingsSection extends StatelessWidget {
  const _ChartSettingsSection({
    required this.draft,
    required this.hasChildren,
    required this.onChartTypeChanged,
    required this.onSettingChanged,
  });

  /// The category as the form currently holds it
  final MeasurementCategory draft;

  /// Whether the category is a group. One is drawn by what its components are
  /// to each other rather than by a preference, whatever its metric type says.
  final bool hasChildren;

  final ValueChanged<ChartType> onChartTypeChanged;

  /// Writes one key of `chart_config`, see [MeasurementCategory.withChartSetting]
  final void Function(String key, Object value) onSettingChanged;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    // What the chart type picker offers: no override, plus what this metric
    // type may be drawn as. Empty for a group, whose chart follows from what
    // its components are to each other rather than from a preference
    final chartTypes = hasChildren || draft.metricType.availableChartTypes.isEmpty
        ? const <ChartType>[]
        : [ChartType.auto, ...draft.metricType.availableChartTypes];

    // The trend line and the moving average are parts of the line chart: a
    // category that can never be drawn as one is not offered them at all, and
    // one that is currently drawn as something else keeps its settings but
    // cannot change them
    final canDrawLine =
        !hasChildren && draft.metricType.availableChartTypes.contains(ChartType.line);
    final drawsLine = draft.metricType.resolveChartType(draft.chartType) == ChartType.line;
    final settings = draft.chartSettings;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Only the shapes that are a matter of taste are offered, and only
        // those the metric type can actually be drawn as
        if (chartTypes.isNotEmpty)
          DropdownButtonFormField<ChartType>(
            // A type stored by a client that offers more of them than this one
            // falls back to the derived chart, so it shows as automatic
            initialValue: chartTypes.contains(draft.chartType) ? draft.chartType : ChartType.auto,
            decoration: InputDecoration(labelText: i18n.chartType),
            items: [
              for (final type in chartTypes)
                DropdownMenuItem(value: type, child: Text(type.localized(context))),
            ],
            onChanged: (value) {
              if (value != null) {
                onChartTypeChanged(value);
              }
            },
          ),

        // Disabled while the category is drawn as something that has neither
        if (canDrawLine) ...[
          DropdownButtonFormField<TrendCharacter>(
            initialValue: settings.trend,
            decoration: InputDecoration(labelText: i18n.chartTrend),
            items: [
              for (final trend in TrendCharacter.values)
                DropdownMenuItem(value: trend, child: Text(trend.localized(context))),
            ],
            onChanged: drawsLine
                ? (value) {
                    if (value != null) {
                      onSettingChanged('trend', value.wireValue);
                    }
                  }
                : null,
          ),
          // The window is a number, "off" is the string the server stores, so
          // the two share one field only as objects
          DropdownButtonFormField<Object>(
            initialValue: settings.averageWindow ?? chartLineOff,
            decoration: InputDecoration(labelText: i18n.chartAverageWindow),
            items: [
              DropdownMenuItem(value: chartLineOff, child: Text(i18n.off)),
              for (final days in ChartSettings.averageWindows)
                DropdownMenuItem(value: days, child: Text(i18n.chartAverageWindowDays(days))),
            ],
            onChanged: drawsLine
                ? (value) {
                    if (value != null) {
                      onSettingChanged('average_window', value);
                    }
                  }
                : null,
          ),
        ],
      ],
    );
  }
}

/// Who fills a category in: the user by hand, or the server by computing it.
///
/// Only free-form categories can be calculated: a typed one is written by the
/// health import or by the server itself, and the server refuses the
/// combination. Renders nothing where none of that applies.
class _CalculationSection extends ConsumerWidget {
  const _CalculationSection({
    required this.draft,
    required this.stored,
    required this.categories,
    required this.canCalculate,
    required this.onPick,
    required this.onManual,
    required this.onParamsChanged,
  });

  /// The category as the form currently holds it
  final MeasurementCategory draft;

  /// The category as the form was opened with, null while one is created.
  /// What a category computes is fixed once it exists, so this is what
  /// decides whether the calculation is still up for change.
  final MeasurementCategory? stored;

  /// Every category of the user, for the duplicate checks and for the name
  /// the ratio reads
  final List<MeasurementCategory> categories;

  /// Whether this category could be calculated at all
  final bool canCalculate;

  /// Switches to a calculation, which also prefills the name and the unit
  final ValueChanged<CalculationType> onPick;

  /// Hands the category back to the user
  final VoidCallback onManual;

  final ValueChanged<Map<String, dynamic>> onParamsChanged;

  /// Whether the user already has this calculation, decided while the type is
  /// picked. Only a calculation without parameters can be judged that early:
  /// what the others compute depends on settings picked afterwards, so those
  /// are judged on save, see [_isDuplicate].
  bool _isTaken(CalculationType type) =>
      type.params.isEmpty && categories.any((c) => c.dynamicType == type.slug && c.id != draft.id);

  /// Whether the draft would compute exactly what another category already
  /// computes. Mirrors _duplicate_calculation on the server, including its
  /// limitation: a number left out and the same number typed in read as two
  /// configurations, which lets a duplicate through rather than refusing two
  /// categories that differ.
  bool _isDuplicate() =>
      draft.isCalculated &&
      categories.any(
        (c) =>
            c.id != draft.id &&
            c.dynamicType == draft.dynamicType &&
            const DeepCollectionEquality().equals(
              c.dynamicParams ?? const {},
              draft.dynamicParams ?? const {},
            ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    // A calculation from a newer server: shown, but not rewritten from here.
    // The parameters this release cannot render stay exactly as they are
    final isUnknown = !isKnownCalculation(draft.dynamicType);
    final calculation = calculationTypeOf(draft.dynamicType);
    // Stopping a calculation means deleting the category, and the server
    // refuses a change either way
    final isLocked = stored?.isCalculated ?? false;
    // BMI and the ratio divide by the height in the profile and compute
    // nothing while it is missing. Null also covers a profile that has not
    // synced yet, where the hint is a guess rather than a fact, so it waits
    final profile = ref.watch(userProfileProvider).value;
    final heightMissing = profile != null && profile.height == null;
    // The ratio names the category it reads, so its description needs the name
    final sourceName =
        categories
            .where((c) => c.id == draft.dynamicParams?['category_id'])
            .firstOrNull
            ?.displayName(context) ??
        '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isUnknown) _InfoBox(i18n.calculationUnknown),
        // Only while the category is being created: the server fixes what a
        // category computes on the first save, so a switch offered later
        // could only ever go one way and would read as one that goes both
        if (stored == null && canCalculate) ...[
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(i18n.calculationValuesManual)),
              ButtonSegment(value: true, label: Text(i18n.calculationValuesCalculated)),
            ],
            selected: {draft.isCalculated},
            onSelectionChanged: (selection) => selection.single
                // A type the user already has would be refused on save, so the
                // switch lands on the first one still free
                ? onPick(
                    calculationTypes.firstWhereOrNull((t) => !_isTaken(t)) ??
                        calculationTypes.first,
                  )
                : onManual(),
          ),
        ],
        if (calculation != null) ...[
          DropdownButtonFormField<String>(
            key: const Key('calculation-type'),
            initialValue: calculation.slug,
            decoration: InputDecoration(
              labelText: i18n.calculationType,
              helperText: isLocked ? i18n.calculationLocked : null,
            ),
            items: [
              for (final type in calculationTypes)
                if (_isTaken(type))
                  DropdownMenuItem(
                    value: type.slug,
                    enabled: false,
                    child: Text('${type.localizedName(context)} (${i18n.metricAlreadyTracked})'),
                  )
                else
                  DropdownMenuItem(value: type.slug, child: Text(type.localizedName(context))),
            ],
            validator: (_) => _isDuplicate()
                ? i18n.calculationDuplicate(calculation.localizedName(context))
                : null,
            onChanged: isLocked
                ? null
                : (slug) {
                    final picked = slug == null ? null : calculationTypeOf(slug);
                    if (picked != null) {
                      onPick(picked);
                    }
                  },
          ),
          const SizedBox(height: 8),
          if (calculation.localizedDescription(context, category: sourceName)
              case final String description)
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
          if (calculation.needsHeight && heightMissing)
            _InfoBox(i18n.calculationMissingHeight, isWarning: true),
          CalculationParamsBlock(
            // Keyed by the calculation: the fields of two types share a
            // parameter key, and a field that survives the switch would go on
            // showing what the user typed for the type before it
            key: ValueKey(calculation.slug),
            type: calculation,
            params: draft.dynamicParams ?? const {},
            categoryId: draft.id,
            onChanged: onParamsChanged,
          ),
        ],
      ],
    );
  }
}

/// A boxed note next to the calculation fields: what is blocked, what cannot
/// be changed here, what will not be computed yet.
class _InfoBox extends StatelessWidget {
  const _InfoBox(this.body, {this.isWarning = false});

  final String body;

  /// Something the user has to act on, rather than something to know
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isWarning ? scheme.onErrorContainer : scheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning ? scheme.errorContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(body, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
    );
  }
}
