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

/// The calculations the server can run for a measurement category.
///
/// The server owns the maths and the validation; this table is what the app
/// needs to render a form for a calculation and to read one back. It is
/// mirrored here rather than fetched: the labels and the help texts are
/// translated in the app anyway, as with the metric types. Keep it next to
/// wger/measurements/dynamic/types.py.
library;

import 'package:flutter/material.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// One parameter of a calculation, as the form has to render it.
///
/// The bounds repeat what the server validates. They are here so the user does
/// not run into a round trip that can only fail; the server stays the
/// authority and refuses anything outside them either way.
sealed class CalculationParam {
  /// Key the value is stored under in `dynamic_params`
  final String key;

  const CalculationParam(this.key);
}

/// The units a length can be written in, as the server reads them (see
/// LENGTH_UNITS in measurements/dynamic/types.py).
///
/// Spelled-out and translated forms are deliberately left out: that list has
/// no end, and a category whose unit is not among these is offered but
/// disabled, which shows the user what to change instead of hiding the
/// category from them.
const lengthUnits = [
  'mm',
  'millimeter',
  'millimeters',
  'cm',
  'centimeter',
  'centimeters',
  'm',
  'meter',
  'meters',
  'in',
  'inch',
  'inches',
  '"',
  '\u2033',
];

/// One of the user's own categories, referenced by its id
class CategoryParam extends CalculationParam {
  /// Units a category has to be measured in to be offered
  final List<String> unitFilter;

  const CategoryParam(super.key, {required this.unitFilter});

  /// Whether a category measured in [unit] fits this parameter. A trailing
  /// dot is an abbreviation, not a different unit ("cm.")
  bool accepts(String unit) {
    final normalized = unit.trim().toLowerCase();
    return unitFilter.contains(
      normalized.endsWith('.') ? normalized.substring(0, normalized.length - 1) : normalized,
    );
  }
}

/// A single exercise, stored as its id
class ExerciseParam extends CalculationParam {
  const ExerciseParam(super.key);
}

/// Several exercises, stored as a list of ids
class ExercisesParam extends CalculationParam {
  final int minItems;
  final int maxItems;

  const ExercisesParam(super.key, {required this.minItems, required this.maxItems});
}

/// A bounded number with the value the server falls back to
class IntParam extends CalculationParam {
  final int min;
  final int max;
  final int fallback;

  const IntParam(super.key, {required this.min, required this.max, required this.fallback});
}

/// One calculation the server offers, with everything the form needs for it
class CalculationType {
  /// The server's `dynamic_type`
  final String slug;

  /// Prefill for the category unit; the user can still change it
  final String unit;

  final List<CalculationParam> params;

  /// Needs the height in the user profile, and computes nothing without it
  final bool needsHeight;

  const CalculationType({
    required this.slug,
    required this.unit,
    required this.params,
    this.needsHeight = false,
  });
}

/// The calculations this release knows; the server may support more, or fewer
const calculationTypes = <CalculationType>[
  CalculationType(
    slug: 'BMI',
    unit: 'kg/m²',
    params: [],
    needsHeight: true,
  ),
  CalculationType(
    slug: 'WHTR',
    // A ratio of two lengths, so the number carries no unit
    unit: '',
    params: [
      CategoryParam('category_id', unitFilter: lengthUnits),
    ],
    needsHeight: true,
  ),
  CalculationType(
    slug: 'ONE_REP_MAX',
    unit: 'kg',
    params: [
      ExerciseParam('exercise_id'),
      IntParam('max_reps', min: 1, max: 10, fallback: 5),
    ],
  ),
  CalculationType(
    slug: 'ONE_RM_TOTAL',
    unit: 'kg',
    params: [
      ExercisesParam('exercise_ids', minItems: 2, maxItems: 5),
      IntParam('max_reps', min: 1, max: 10, fallback: 5),
      IntParam('window_days', min: 7, max: 120, fallback: 30),
    ],
  ),
];

/// Bench press, squat and deadlift, the total most people mean.
///
/// An instance that never synced them simply resolves nothing here.
const bigThreeUuids = [
  '3717d144-7815-4a97-9a56-956fb889c996',
  'a2f5b6ef-b780-49c0-8d96-fdaff23e27ce',
  'ee8e8db4-2d82-49e1-ab7f-891e9a354934',
];

/// The calculation [slug] stands for, or null if this release does not know it
CalculationType? calculationTypeOf(String slug) {
  for (final type in calculationTypes) {
    if (type.slug == slug) {
      return type;
    }
  }
  return null;
}

/// Whether a stored calculation is one this release can render. An unknown one
/// comes from a newer server: it is shown, but its parameters are left alone
/// rather than overwritten with what this version happens to understand.
bool isKnownCalculation(String slug) => slug == noDynamicType || calculationTypeOf(slug) != null;

/// The parameters a freshly picked calculation starts with.
///
/// The numbers start at the server's own default so that the user sees it,
/// and emptying the field means it again. Writing it out rather than leaving
/// it absent is what keeps two clients from storing the same configuration
/// differently: the server compares the parameters as they are stored, so an
/// omitted value and a typed one are two configurations to it, and neither
/// would recognise the other as a duplicate.
Map<String, dynamic> defaultParams(CalculationType type) => {
  for (final param in type.params)
    param.key: switch (param) {
      IntParam(:final fallback) => fallback,
      ExercisesParam() => const <int>[],
      _ => null,
    },
};

extension CalculationTypeL10n on CalculationType {
  /// Name the category is prefilled with, and what the type picker shows
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (slug) {
      'BMI' => l10n.calculationNameBmi,
      'WHTR' => l10n.calculationNameWhtr,
      'ONE_REP_MAX' => l10n.calculationNameOneRepMax,
      'ONE_RM_TOTAL' => l10n.calculationNameOneRmTotal,
      // Nothing to translate a calculation this release does not know by; the
      // slug is at least honest about which one it is
      _ => slug,
    };
  }

  /// What the values are computed from, in words. Shown under the type picker
  /// while the calculation is configured, and on the category from then on,
  /// where it doubles as the explanation for one that is still empty.
  ///
  /// Null where the sentence would only repeat what the calculation is called:
  /// a one-rep max reads the exercise it names, which the form asks for right
  /// below and the category carries in its name. [category] names the source
  /// category of the ratio and is ignored by every other type.
  String? localizedDescription(BuildContext context, {String category = ''}) {
    final l10n = AppLocalizations.of(context);
    return switch (slug) {
      'BMI' => l10n.calculationDescriptionBmi,
      'WHTR' => l10n.calculationDescriptionWhtr(category),
      _ => null,
    };
  }
}

extension CalculationParamL10n on CalculationParam {
  /// Label of the field this parameter is entered in
  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      'category_id' => l10n.calculationParamCategory,
      'max_reps' => l10n.calculationParamMaxReps,
      'window_days' => l10n.calculationParamWindowDays,
      // The exercise parameters render their own labels, see the picker
      _ => key,
    };
  }
}
