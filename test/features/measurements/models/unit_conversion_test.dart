/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';

MeasurementEntry entry(num value, {Map<String, dynamic>? extraData}) => MeasurementEntry(
  categoryId: 'c',
  date: DateTime(2026, 1, 1),
  value: value,
  notes: '',
  extraData: extraData,
);

void main() {
  group('convertWeight', () {
    test('same unit passes through unquantized', () {
      expect(convertWeight(80.567, from: 'kg', to: 'kg'), 80.567);
    });

    test('kg to lb matches the server rounding (two decimals)', () {
      // 80.5 * 2.20462262 = 177.4721...
      expect(convertWeight(80.5, from: 'kg', to: 'lb'), 177.47);
    });

    test('lb to kg matches the server rounding (two decimals)', () {
      // 176.4 * 0.45359237 = 80.0137...
      expect(convertWeight(176.4, from: 'lb', to: 'kg'), 80.01);
    });

    test('label-only units are never converted', () {
      expect(convertWeight(42, from: 'cm', to: 'kg'), 42);
      expect(convertWeight(42, from: 'kg', to: 'cm'), 42);
    });
  });

  group('MeasurementEntryUnit', () {
    test('unitOrFallback prefers the stamped unit', () {
      expect(entry(80, extraData: {'unit': 'lb'}).unitOrFallback('kg'), 'lb');
    });

    test('unitOrFallback uses the category unit when absent or empty', () {
      expect(entry(80).unitOrFallback('kg'), 'kg');
      expect(entry(80, extraData: {}).unitOrFallback('kg'), 'kg');
      // Same chain as the server: an empty string counts as absent
      expect(entry(80, extraData: {'unit': ''}).unitOrFallback('kg'), 'kg');
    });

    test('valueIn converts a stamped entry to the target unit', () {
      expect(entry(176.4, extraData: {'unit': 'lb'}).valueIn('kg', categoryUnit: 'kg'), 80.01);
    });

    test('valueIn passes unstamped entries through via the category unit', () {
      expect(entry(80).valueIn('kg', categoryUnit: 'kg'), 80);
      expect(entry(80).valueIn('lb', categoryUnit: 'kg'), 176.37);
    });

    test('boundIn follows the value through the same conversion', () {
      // The bounds of an aggregate are stored in the value's unit, so reading
      // the value in lb and the bounds in kg would put the band 2.2x off
      final aggregate = entry(80, extraData: {'min': 70, 'max': 90});

      expect(aggregate.valueIn('lb', categoryUnit: 'kg'), 176.37);
      expect(aggregate.boundIn(70, 'lb', categoryUnit: 'kg'), 154.32);
      expect(aggregate.boundIn(90, 'lb', categoryUnit: 'kg'), 198.42);
    });

    test('boundIn honours the entry stamp like valueIn does', () {
      final stamped = entry(176.4, extraData: {'unit': 'lb'});

      expect(stamped.boundIn(176.4, 'kg', categoryUnit: 'kg'), 80.01);
      // and leaves label-only units alone
      expect(entry(60).boundIn(50, 'bpm', categoryUnit: 'bpm'), 50);
    });
  });
}
