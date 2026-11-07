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
import 'package:wger/features/health/models/health_reading.dart';
import 'package:wger/features/health/providers/health_repository.dart';

import 'health_repository_test.mocks.dart';

HealthDataPoint dataPoint(
  HealthDataType type, {
  String? uuid,
  DateTime? dateFrom,
  DateTime? dateTo,
}) => HealthDataPoint(
  uuid: uuid ?? '${type.name}-1',
  value: NumericHealthValue(numericValue: 60),
  type: type,
  unit: HealthDataUnit.MINUTE,
  dateFrom: dateFrom ?? DateTime(2026, 1, 2),
  dateTo: dateTo ?? dateFrom ?? DateTime(2026, 1, 2, 1),
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

  /// Runs a read and collects everything the batches delivered.
  Future<List<HealthReading>> readAll({
    required List<HealthDataType> types,
    required DateTime start,
    required DateTime end,
    required Duration window,
  }) async {
    final readings = <HealthReading>[];
    await repository.read(
      types: types,
      start: start,
      end: end,
      window: window,
      onBatch: (batch, _) async => readings.addAll(batch),
    );
    return readings;
  }

  group('read', () {
    test('a range shorter than the window is one query', () async {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 1, 20);

      await readAll(
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

      await readAll(
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

      await readAll(
        types: [HealthDataType.WEIGHT, HealthDataType.HEART_RATE],
        start: start,
        end: end,
        window: defaultReadWindow,
      );

      final windows = capturedWindows();
      // Both types cover the same range, so each window shows up twice
      expect(windows.where((w) => w.$1 == start), hasLength(2));
    });

    test('hands each window over before the next one is read', () async {
      // Holding the whole history until the end would fill the same Android
      // heap the windowing exists to protect
      final events = <String>[];
      var window = 0;
      when(
        health.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenAnswer((_) async {
        window++;
        events.add('read window $window');
        return [dataPoint(HealthDataType.WEIGHT, uuid: 'w-$window')];
      });

      await repository.read(
        types: [HealthDataType.WEIGHT],
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 3, 1),
        window: defaultReadWindow,
        onBatch: (batch, _) async => events.add('batch of ${batch.length}'),
      );

      expect(events, ['read window 1', 'batch of 1', 'read window 2', 'batch of 1']);
    });

    test('reports every window, empty ones included', () async {
      // Most windows of a full history return nothing, so a progress counter
      // fed by the batches alone would sit at zero for minutes and then jump
      var windows = 0;

      await repository.read(
        types: [HealthDataType.WEIGHT],
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 4, 1),
        window: defaultReadWindow,
        onBatch: (batch, _) async {},
        onWindow: () => windows++,
      );

      expect(windows, 3);
      expect(windows, capturedWindows().length);
    });

    test('a record on the window boundary is delivered once', () async {
      // Both windows of a contiguous pair contain their shared boundary, so a
      // record sitting exactly on it comes back from both queries
      final boundary = DateTime(2026, 1, 1).add(defaultReadWindow);
      when(
        health.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenAnswer(
        (_) async => [dataPoint(HealthDataType.WEIGHT, uuid: 'w-1', dateFrom: boundary)],
      );

      final readings = await readAll(
        types: [HealthDataType.WEIGHT],
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 2, 15),
        window: defaultReadWindow,
      );

      expect(readings, hasLength(1));
    });

    test('an interval spanning several windows is delivered once', () async {
      // A duration record overlaps every window it reaches into and comes
      // back from each of their queries
      when(
        health.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenAnswer(
        (_) async => [
          dataPoint(
            HealthDataType.SLEEP_ASLEEP,
            uuid: 's-1',
            dateFrom: DateTime(2026, 1, 2),
            dateTo: DateTime(2026, 1, 8),
          ),
        ],
      );

      final readings = await readAll(
        types: [HealthDataType.SLEEP_ASLEEP],
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 10),
        window: highVolumeReadWindow,
      );

      expect(readings, hasLength(1));
    });

    test('a failing window does not cost the other types their read', () async {
      when(
        health.getHealthDataFromTypes(
          types: [HealthDataType.HEART_RATE],
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenThrow(Exception('boom'));

      final readings = await readAll(
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

    test('a type that fails halfway keeps its delivered windows and stops', () async {
      // What a batch delivered is already written; the failing type is only
      // dropped from the remaining windows, and the caller's unchanged
      // watermark makes the re-read harmless
      var call = 0;
      when(
        health.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_DEEP],
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenAnswer((invocation) async {
        if (call++ > 0) {
          throw Exception('boom');
        }
        return [
          dataPoint(
            HealthDataType.SLEEP_DEEP,
            dateFrom: invocation.namedArguments[#startTime] as DateTime,
          ),
        ];
      });
      when(
        health.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_REM],
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenAnswer(
        (invocation) async => [
          dataPoint(
            HealthDataType.SLEEP_REM,
            uuid: 'rem-${invocation.namedArguments[#startTime]}',
            dateFrom: invocation.namedArguments[#startTime] as DateTime,
          ),
        ],
      );

      final readings = await readAll(
        types: [HealthDataType.SLEEP_DEEP, HealthDataType.SLEEP_REM],
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 4, 1),
        window: defaultReadWindow,
      );

      // The first window of the failing type was handed over; the other type
      // delivered every window
      expect(readings.where((r) => r.type == HealthDataType.SLEEP_DEEP), hasLength(1));
      expect(readings.where((r) => r.type == HealthDataType.SLEEP_REM), hasLength(3));
      // After the failure the type is not asked again
      verify(
        health.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_DEEP],
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).called(2);
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
        () => readAll(
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
