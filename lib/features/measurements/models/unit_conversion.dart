/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:wger/features/measurements/models/measurement_entry.dart';

// Mirror the server's constants (wger/utils/units.py) so both sides round to
// the same two-decimal results.
const _lbPerKg = 2.20462262;
const _kgPerLb = 0.45359237;

/// Units the app can convert between. Anything else (custom category units)
/// is a plain label and values pass through unchanged.
const convertibleUnits = {'kg', 'lb'};

/// The canonical unit weight values are displayed in for the profile setting.
/// Use `weightUnit` from the chart helpers for the localized label.
String weightDisplayUnit(bool isMetric) => isMetric ? 'kg' : 'lb';

/// Converts [value] from [from] to [to] (kg/lb, quantized to two decimals like
/// the server's `Measurement.value_in`). Non-convertible units pass through.
double convertWeight(num value, {required String from, required String to}) {
  if (from == to || !convertibleUnits.contains(from) || !convertibleUnits.contains(to)) {
    return value.toDouble();
  }
  final converted = from == 'kg' ? value * _lbPerKg : value * _kgPerLb;
  return (converted * 100).roundToDouble() / 100;
}

/// The unit a value was entered in: [stored], falling back to [categoryUnit]
/// when it is absent or empty (same chain as the server).
String unitOrFallback(Object? stored, String categoryUnit) =>
    stored is String && stored.isNotEmpty ? stored : categoryUnit;

extension MeasurementEntryUnit on MeasurementEntry {
  /// The unit this entry's value was entered in.
  String unitOrFallbackFor(String categoryUnit) => unitOrFallback(extraData?['unit'], categoryUnit);

  /// The entry's value in [targetUnit]. The single way to read a measurement
  /// value for display or calculation; a category can hold mixed units, so
  /// the raw value alone is meaningless.
  double valueIn(String targetUnit, {required String categoryUnit}) {
    return convertWeight(value, from: unitOrFallbackFor(categoryUnit), to: targetUnit);
  }

  /// A number stored in `extra_data` next to [value] in [targetUnit], such as
  /// the bounds of a daily aggregate. They are written in the value's unit, so
  /// they have to follow it through the same conversion.
  double boundIn(num bound, String targetUnit, {required String categoryUnit}) {
    return convertWeight(bound, from: unitOrFallbackFor(categoryUnit), to: targetUnit);
  }
}
