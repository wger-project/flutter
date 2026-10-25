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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/features/exercises/providers/exercises_notifier.dart';
import 'package:wger/features/exercises/widgets/autocompleter.dart';
import 'package:wger/features/measurements/models/measurement_calculation.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// The parameter fields of a calculation, between the type picker and the rest
/// of the category form. Which fields appear follows from the type, see
/// [CalculationType].
///
/// The fields validate against the same bounds the server does, so an invalid
/// configuration is refused here rather than on the next push. That matters
/// beyond saving a round trip: a category created offline reaches the server
/// only later, and a refusal then arrives without the form that caused it.
class CalculationParamsBlock extends ConsumerWidget {
  const CalculationParamsBlock({
    required this.type,
    required this.params,
    required this.onChanged,
    this.categoryId,
    super.key,
  });

  final CalculationType type;
  final Map<String, dynamic> params;
  final ValueChanged<Map<String, dynamic>> onChanged;

  /// The category being edited, which cannot be its own source
  final String? categoryId;

  /// The ids a parameter holds, as a list, whether it takes one or several
  static List<int> _idsOf(CalculationParam param, Map<String, dynamic> params) {
    final value = params[param.key];
    return switch (value) {
      final List<dynamic> list => list.cast<int>(),
      final int id => [id],
      _ => const [],
    };
  }

  void _set(String key, Object? value) => onChanged({...params, key: value});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final param in type.params)
          switch (param) {
            final CategoryParam p => _categoryPicker(context, ref, p),
            final ExerciseParam p => _exercisePicker(context, ref, p),
            final ExercisesParam p => _exercisePicker(context, ref, p),
            final IntParam p => _number(context, p),
          },
      ],
    );
  }

  /// A picker over the user's own categories. A calculated category cannot
  /// feed another one, and nothing can feed itself; the server refuses both,
  /// so neither is offered. One measured in a unit this calculation cannot
  /// read is offered but disabled, see below.
  Widget _categoryPicker(BuildContext context, WidgetRef ref, CategoryParam param) {
    final i18n = AppLocalizations.of(context);
    final candidates = [
      for (final candidate
          in ref.watch(measurementCategoriesProvider).value ?? const <MeasurementCategory>[])
        if (candidate.id != categoryId && !candidate.isCalculated) candidate,
    ];

    // Still a field rather than a bare sentence: with nothing to pick there
    // is nothing to save either, and without a validator here the form would
    // let a configuration through that the server can only refuse. The helper
    // gives way to the same sentence as an error once the user tries
    if (candidates.isEmpty) {
      return FormField<void>(
        key: Key('calculation-param-${param.key}'),
        validator: (_) => i18n.calculationNoSourceCategory,
        builder: (field) => InputDecorator(
          decoration: InputDecoration(
            border: InputBorder.none,
            helperText: i18n.calculationNoSourceCategory,
            helperMaxLines: 3,
            errorText: field.errorText,
            errorMaxLines: 3,
          ),
          child: const SizedBox.shrink(),
        ),
      );
    }

    final selected = params[param.key];
    return DropdownButtonFormField<String>(
      key: Key('calculation-param-${param.key}'),
      initialValue: candidates.any((c) => c.id == selected) ? selected as String : null,
      decoration: InputDecoration(labelText: param.localizedLabel(context)),
      items: [
        // A category whose unit this calculation cannot read is shown rather
        // than hidden: the unit next to it is what the user has to change, and
        // a silently short list explains nothing
        for (final candidate in candidates)
          DropdownMenuItem(
            value: candidate.id,
            enabled: param.accepts(candidate.unit),
            child: Text('${candidate.displayName(context)} (${candidate.unit})'),
          ),
      ],
      validator: (value) => value == null ? i18n.calculationParamsIncomplete : null,
      onChanged: (value) => _set(param.key, value),
    );
  }

  /// The exercises a calculation reads, as removable chips over a search
  /// field. One or several, depending on the parameter.
  Widget _exercisePicker(BuildContext context, WidgetRef ref, CalculationParam param) {
    final i18n = AppLocalizations.of(context);
    final multi = param is ExercisesParam;
    final selected = _idsOf(param, params);
    final full = multi && selected.length >= param.maxItems;

    // Names for the stored ids: the whole catalogue is local, so an existing
    // configuration reads as exercises rather than as the numbers it is
    final exercises = ref.watch(exercisesProvider).value;
    final languageCode = Localizations.localeOf(context).languageCode;
    String nameOf(int id) {
      final exercise = exercises?.getByIdOrNull(id);
      return exercise == null ? '#$id' : exercise.getTranslation(languageCode).name;
    }

    return FormField<List<int>>(
      key: Key('calculation-param-${param.key}'),
      initialValue: selected,
      validator: (value) {
        final count = value?.length ?? 0;
        if (multi) {
          return count < param.minItems || count > param.maxItems
              ? i18n.calculationParamsIncomplete
              : null;
        }
        return count == 0 ? i18n.calculationParamsIncomplete : null;
      },
      builder: (field) {
        // The one place the selection changes: the field validates against
        // its own value while the parameters are what gets stored, so the two
        // are written together or they drift apart
        void update(List<int> next) {
          field.didChange(next);
          _set(param.key, multi ? next : next.firstOrNull);
        }

        return InputDecorator(
          decoration: InputDecoration(
            helperText: multi
                ? i18n.calculationHelpExercises(param.minItems, param.maxItems, selected.length)
                : null,
            errorText: field.errorText,
            border: InputBorder.none,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selected.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: [
                    for (final id in selected)
                      InputChip(
                        label: Text(nameOf(id)),
                        onDeleted: () => update([
                          for (final e in selected)
                            if (e != id) e,
                        ]),
                      ),
                  ],
                ),
              // The search field goes away once the parameter holds as many
              // exercises as it may, so the only way on is removing one
              if (!full)
                ExerciseAutocompleter(
                  onExerciseSelected: (exercise) {
                    if (!multi) {
                      update([exercise.id]);
                    } else if (!selected.contains(exercise.id)) {
                      update([...selected, exercise.id]);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// A bounded number, e.g. how many repetitions a set may have to still
  /// count.
  ///
  /// Empty is a valid state: the parameter is dropped and the server applies
  /// its own default, which is what the hint behind the empty field shows.
  Widget _number(BuildContext context, IntParam param) {
    final i18n = AppLocalizations.of(context);
    final help = param.key == 'max_reps'
        ? i18n.calculationHelpMaxReps(param.min, param.max)
        : i18n.calculationHelpWindowDays(param.min, param.max);

    return TextFormField(
      key: Key('calculation-param-${param.key}'),
      initialValue: params[param.key]?.toString() ?? '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: param.localizedLabel(context),
        helperText: help,
        hintText: '${param.fallback}',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        final parsed = int.tryParse(value);
        return parsed == null || parsed < param.min || parsed > param.max ? help : null;
      },
      onChanged: (value) {
        // An emptied field drops the key rather than storing a blank: absent
        // is what tells the server to use its own default
        if (value.isEmpty) {
          onChanged({
            for (final entry in params.entries)
              if (entry.key != param.key) entry.key: entry.value,
          });
          return;
        }
        final parsed = int.tryParse(value);
        if (parsed != null) {
          _set(param.key, parsed);
        }
      },
    );
  }
}
