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
import 'package:health_bridge/health.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/providers/health_repository.dart';

import 'health_repository_test.mocks.dart';

HealthDataPoint dataPoint(HealthDataType type) => HealthDataPoint(
  uuid: '${type.name}-1',
  value: NumericHealthValue(numericValue: 60),
  type: type,
  unit: HealthDataUnit.MINUTE,
  dateFrom: DateTime(2026, 1, 2),
  dateTo: DateTime(2026, 1, 2, 1),
  sourcePlatform: HealthPlatformType.googleHealthConnect,
  sourceDeviceId: 'device',
  sourceId: 'source',
  sourceName: 'test',
);

@GenerateMocks([Health])
void main() {
  late MockHealth health;
  late HealthRepository repository;

  setUp(() {
    health = MockHealth();
    repository = HealthRepository(health);

    when(health.configure()).thenAnswer((_) async {});
    when(
      health.getHealthDataFromTypes(
        types: anyNamed('types'),
        startTime: anyNamed('startTime'),
        endTime: anyNamed('endTime'),
      ),
    ).thenAnswer((_) async => <HealthDataPoint>[]);
    when(health.removeDuplicates(any)).thenAnswer(
      (invocation) => invocation.positionalArguments.first as List<HealthDataPoint>,
    );
  });

  /// The (start, end) of every query the repository sent, in order
  List<(DateTime, DateTime)> capturedWindows() {
    final captured = verify(
      health.getHealthDataFromTypes(
        types: anyNamed('types'),
        startTime: captureAnyNamed('startTime'),
        endTime: captureAnyNamed('endTime'),
      ),
    ).captured;
    return [
      for (var i = 0; i < captured.length; i += 2)
        (captured[i] as DateTime, captured[i + 1] as DateTime),
    ];
  }

  group('read', () {
    test('a range shorter than the window is one query', () async {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 1, 20);

      await repository.read(
        types: [HealthDataType.WEIGHT],
        start: start,
        end: end,
        window: defaultReadWindow,
      );

      expect(capturedWindows(), [(start, end)]);
    });

    test('a long range is read in contiguous windows', () async {
      // A single query over years of a high-frequency type fills the Android
      // app heap, so the platform is asked for one window at a time
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 4, 10);

      await repository.read(
        types: [HealthDataType.HEART_RATE],
        start: start,
        end: end,
        window: highVolumeReadWindow,
      );

      final windows = capturedWindows();
      expect(windows.length, greaterThan(1));
      expect(windows.first.$1, start);
      expect(windows.last.$2, end, reason: 'The last window must not read past the end');
      for (var i = 1; i < windows.length; i++) {
        expect(windows[i].$1, windows[i - 1].$2, reason: 'Windows must leave no gap');
      }
      for (final window in windows) {
        expect(
          window.$2.difference(window.$1),
          lessThanOrEqualTo(highVolumeReadWindow),
        );
      }
    });

    test('every type is windowed on its own', () async {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 3, 1);

      await repository.read(
        types: [HealthDataType.WEIGHT, HealthDataType.HEART_RATE],
        start: start,
        end: end,
        window: defaultReadWindow,
      );

      final windows = capturedWindows();
      // Both types cover the same range, so each window shows up twice
      expect(windows.where((w) => w.$1 == start), hasLength(2));
    });

    test('a failing window does not cost the other types their read', () async {
      when(
        health.getHealthDataFromTypes(
          types: [HealthDataType.HEART_RATE],
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenThrow(Exception('boom'));

      final readings = await repository.read(
        types: [HealthDataType.HEART_RATE, HealthDataType.WEIGHT],
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 4, 1),
        window: defaultReadWindow,
      );

      expect(readings, isEmpty);
      verify(
        health.getHealthDataFromTypes(
          types: [HealthDataType.WEIGHT],
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).called(greaterThan(1));
    });

    test('a type that fails halfway is dropped whole, windows it did read included', () async {
      // The watermark moves with what was imported, so half a type would put
      // the windows that never returned out of reach for good
      var call = 0;
      when(
        health.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_DEEP],
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenAnswer((_) async {
        if (call++ > 0) {
          throw Exception('boom');
        }
        return [dataPoint(HealthDataType.SLEEP_DEEP)];
      });
      when(
        health.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_REM],
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenAnswer((_) async => [dataPoint(HealthDataType.SLEEP_REM)]);

      final readings = await repository.read(
        types: [HealthDataType.SLEEP_DEEP, HealthDataType.SLEEP_REM],
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 4, 1),
        window: defaultReadWindow,
      );

      expect(readings.map((r) => r.type).toSet(), {HealthDataType.SLEEP_REM});
    });

    test('a wholesale failure still propagates', () async {
      when(
        health.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenThrow(Exception('boom'));

      expect(
        () => repository.read(
          types: [HealthDataType.WEIGHT],
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 2, 1),
          window: defaultReadWindow,
        ),
        throwsException,
      );
    });
  });
}
