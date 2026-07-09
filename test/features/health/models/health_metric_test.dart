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

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';

HealthMetric _metric(MetricType type) => healthMetrics.firstWhere((m) => m.metricType == type);

void main() {
  group('Enabled metric set', () {
    test('only body fat and height are imported in V1', () {
      expect(
        enabledHealthMetrics.map((m) => m.metricType),
        containsAll([MetricType.bodyFat, MetricType.height]),
      );
      expect(enabledHealthMetrics.length, 2);
    });

    test('every disabled metric explains why', () {
      final disabled = healthMetrics.where((m) => !m.enabled);
      expect(disabled, isNotEmpty);
      expect(disabled.every((m) => m.disabledReason != null), isTrue);
    });

    test('metric types are unique', () {
      final types = healthMetrics.map((m) => m.metricType).toList();
      expect(types.length, types.toSet().length);
    });
  });

  group('Body fat conversion', () {
    final bodyFat = _metric(MetricType.bodyFat);

    test('iOS fraction is scaled to a percentage', () {
      expect(bodyFat.toCategoryValue(0.15), closeTo(15, 0.001));
    });

    test('Health Connect percentage is kept as-is', () {
      expect(bodyFat.toCategoryValue(15), closeTo(15, 0.001));
    });
  });

  group('Height conversion', () {
    final height = _metric(MetricType.height);

    test('meters are converted to centimeters', () {
      expect(height.toCategoryValue(1.75), closeTo(175, 0.001));
    });

    test('a value already in centimeters is kept as-is', () {
      expect(height.toCategoryValue(180), closeTo(180, 0.001));
    });
  });

  test('enabledHealthMetrics matches the enabled flag', () {
    expect(
      enabledHealthMetrics,
      healthMetrics.where((m) => m.enabled).toList(),
    );
    // sanity: the disabled ones really are excluded
    expect(enabledHealthMetrics.firstWhereOrNull((m) => m.metricType == MetricType.steps), isNull);
  });
}
