/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:flutter/foundation.dart';
import 'package:wger/core/consts.dart';

const _KG_PER_LB = 0.45359237;

/// Converts [value] between [WEIGHT_UNIT_KG] and [WEIGHT_UNIT_LB].
///
/// Anything else (the server also knows custom units such as plates) is
/// returned untouched — there is no sensible factor for those.
///
/// The result is snapped to [rounding] when given (the routine's
/// `weightRounding`), otherwise to the nearest half unit, so switching units
/// mid-session yields a number that exists on a rack rather than 176.3696.
num convertWeight(num value, {required int from, required int to, num? rounding}) {
  if (from == to) {
    return value;
  }

  final num converted;
  if (from == WEIGHT_UNIT_KG && to == WEIGHT_UNIT_LB) {
    converted = value / _KG_PER_LB;
  } else if (from == WEIGHT_UNIT_LB && to == WEIGHT_UNIT_KG) {
    converted = value * _KG_PER_LB;
  } else {
    return value;
  }

  final step = (rounding == null || rounding <= 0) ? 0.5 : rounding;
  return (converted / step).round() * step;
}

@immutable
class WeightUnit {
  final int id;
  final String name;

  const WeightUnit({required this.id, required this.name});

  // Equality is based on `id`, needed e.g. for DropdownButton
  @override
  bool operator ==(Object other) => identical(this, other) || other is WeightUnit && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
