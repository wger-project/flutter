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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_bridge/health.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/health/models/health_reading.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/health/providers/health_sync.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

import 'health_sync_test.mocks.dart';

@GenerateMocks([HealthRepository, MeasurementRepository])
void main() {
  late MockHealthRepository health;
  late MockMeasurementRepository measurements;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    await PreferenceHelper.instance.setHealthSyncEnabled(true);

    health = MockHealthRepository();
    measurements = MockMeasurementRepository();

    when(health.ensureAuthorized(any)).thenAnswer((_) async => true);
    when(health.sourceName).thenReturn('apple');
    when(measurements.addLocalDrift(any)).thenAnswer((_) async {});
    when(measurements.addLocalDriftCategory(any)).thenAnswer((_) async {});
  });

  late ProviderContainer container;

  HealthSyncNotifier createNotifier() {
    container = ProviderContainer.test(
      overrides: [
        healthRepositoryProvider.overrideWithValue(health),
        measurementRepositoryProvider.overrideWithValue(measurements),
      ],
    );
    return container.read(healthSyncProvider.notifier);
  }

  void stubReadings(List<HealthReading> readings) {
    when(
      health.read(
        types: anyNamed('types'),
        start: anyNamed('start'),
        end: anyNamed('end'),
      ),
    ).thenAnswer((_) async => readings);
  }

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

  group('enableSync', () {
    test('returns null and stays disabled when permissions are denied', () async {
      await PreferenceHelper.instance.setHealthSyncEnabled(false);
      when(health.ensureAuthorized(any)).thenAnswer((_) async => false);

      final count = await createNotifier().enableSync();

      expect(count, isNull);
      expect(await PreferenceHelper.instance.getHealthSyncEnabled(), isFalse);
      verifyNever(
        health.read(types: anyNamed('types'), start: anyNamed('start'), end: anyNamed('end')),
      );
    });

    test('persists the preference and runs an initial import', () async {
      await PreferenceHelper.instance.setHealthSyncEnabled(false);
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: 'h-1',
        ),
      ]);

      final count = await createNotifier().enableSync();

      expect(count, 1);
      expect(await PreferenceHelper.instance.getHealthSyncEnabled(), isTrue);
    });
  });

  group('disableSync', () {
    test('clears the preferences and resets the state', () async {
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2026-06-01T12:00:00.000');
      final notifier = createNotifier();
      // let _loadPersistedState finish so it cannot re-enable the state later
      await pumpEventQueue();
      expect(container.read(healthSyncProvider).isEnabled, isTrue);

      await notifier.disableSync();

      expect(await PreferenceHelper.instance.getHealthSyncEnabled(), isFalse);
      expect(await PreferenceHelper.instance.getLastHealthSyncTimestamp(), isNull);
      expect(container.read(healthSyncProvider).isEnabled, isFalse);
    });
  });

  group('syncOnAppOpen', () {
    test('imports enabled metrics into new categories with converted values', () async {
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.BODY_FAT_PERCENTAGE,
          value: 0.2,
          date: DateTime(2026, 1, 1),
          externalId: 'bf-1',
        ),
        HealthReading(
          type: HealthDataType.HEIGHT,
          // 1.803 * 100 is 180.29999999999998 in double arithmetic; the
          // server's Decimal(2) validation requires the stored value to be
          // rounded to exactly 180.3
          value: 1.803,
          date: DateTime(2026, 1, 2),
          externalId: 'h-1',
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();
      expect(count, 2);

      final createdCategories = verify(
        measurements.addLocalDriftCategory(captureAny),
      ).captured.cast<MeasurementCategory>();
      expect(
        createdCategories.map((c) => c.metricType),
        containsAll([MetricType.bodyFat, MetricType.height]),
      );

      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();

      final bodyFat = entries.firstWhere((e) => e.externalId == 'bf-1');
      expect(bodyFat.value, closeTo(20, 0.001)); // fraction -> percent
      expect(bodyFat.source, 'apple');

      final height = entries.firstWhere((e) => e.externalId == 'h-1');
      expect(height.value, 180.3); // meters -> cm, rounded to two decimals

      // The newest imported reading date becomes the next sync watermark
      expect(
        await PreferenceHelper.instance.getLastHealthSyncTimestamp(),
        DateTime(2026, 1, 2).toIso8601String(),
      );
    });

    test('skips readings already imported (dedup by externalId)', () async {
      final existing = MeasurementCategory(
        id: 'cat-bf',
        name: 'Body fat',
        unit: '%',
        metricType: MetricType.bodyFat,
        entries: [
          MeasurementEntry(
            id: 'e1',
            categoryId: 'cat-bf',
            date: DateTime(2026, 1, 1),
            value: 20,
            notes: '',
            externalId: 'bf-1',
          ),
        ],
      );
      when(measurements.getAllOnce()).thenAnswer((_) async => [existing]);
      stubReadings([
        HealthReading(
          type: HealthDataType.BODY_FAT_PERCENTAGE,
          value: 0.2,
          date: DateTime(2026, 1, 1),
          externalId: 'bf-1', // already imported
        ),
        HealthReading(
          type: HealthDataType.BODY_FAT_PERCENTAGE,
          value: 0.22,
          date: DateTime(2026, 1, 3),
          externalId: 'bf-2', // new
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();
      expect(count, 1);
      verifyNever(measurements.addLocalDriftCategory(any));

      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      expect(entries.single.externalId, 'bf-2');
    });

    test('reads with an overlap window before the stored watermark', () async {
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2026-06-01T12:00:00.000');
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([]);

      await createNotifier().syncOnAppOpen();

      final start =
          verify(
                health.read(
                  types: anyNamed('types'),
                  start: captureAnyNamed('start'),
                  end: anyNamed('end'),
                ),
              ).captured.single
              as DateTime;
      // 30 days before the watermark, so late-arriving backdated records
      // (e.g. a scale syncing days after the measurement) are still picked up
      expect(start, DateTime(2026, 5, 2, 12));
    });

    test('does nothing when sync is disabled', () async {
      await PreferenceHelper.instance.setHealthSyncEnabled(false);

      final count = await createNotifier().syncOnAppOpen();
      expect(count, 0);
      verifyNever(
        health.read(
          types: anyNamed('types'),
          start: anyNamed('start'),
          end: anyNamed('end'),
        ),
      );
    });
  });
}
