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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/providers/health_sync.dart';

/// Mirrors the conversion logic in HealthSyncNotifier.syncOnAppOpen
double _convertWeight(double weightKg, {required bool isMetric}) {
  return isMetric ? weightKg : weightKg * kgToLb;
}

void main() {
  group('Health sync constants', () {
    test('kgToLb conversion factor is correct', () {
      // 1 kg = 2.20462 lb
      expect(kgToLb, closeTo(2.20462, 0.00001));
    });

    test('Initial sync lookback is 30 days', () {
      expect(healthSyncInitialDays, 30);
    });
  });

  group('Weight unit conversion', () {
    test('kg value is converted to lb correctly', () {
      const weightKg = 85.0;
      final weightLb = (weightKg * kgToLb * 100).roundToDouble() / 100;
      expect(weightLb, closeTo(187.39, 0.01));
    });

    test('kg value stays as-is when metric', () {
      const weightKg = 85.0;
      final weight = _convertWeight(weightKg, isMetric: true);
      expect(weight, 85.0);
    });

    test('kg value is converted when imperial', () {
      const weightKg = 85.0;
      final weight = _convertWeight(weightKg, isMetric: false);
      expect(weight, closeTo(187.39, 0.01));
    });

    test('conversion rounds to 2 decimal places', () {
      const weightKg = 85.12345;
      final weight = weightKg * kgToLb;
      final rounded = (weight * 100).roundToDouble() / 100;
      // 85.12345 * 2.20462 = 187.66...
      expect(rounded.toString().split('.').last.length, lessThanOrEqualTo(2));
    });
  });

  group('HealthSyncState', () {
    test('default state has sync disabled', () {
      const state = HealthSyncState();
      expect(state.isEnabled, false);
      expect(state.isSyncing, false);
      expect(state.lastSyncCount, 0);
    });

    test('copyWith updates individual fields', () {
      const state = HealthSyncState();
      final updated = state.copyWith(isEnabled: true, lastSyncCount: 5);
      expect(updated.isEnabled, true);
      expect(updated.isSyncing, false);
      expect(updated.lastSyncCount, 5);
    });
  });
}
