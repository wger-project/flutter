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
    when(measurements.updateLocalDrift(any)).thenAnswer((_) async {});
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
        // A blood pressure reading is the systolic/diastolic pair sharing one
        // timestamp; Health Connect also shares the record uuid between them
        HealthReading(
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          value: 120,
          date: DateTime(2026, 1, 3),
          externalId: 'bp-1',
        ),
        HealthReading(
          type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          value: 80,
          date: DateTime(2026, 1, 3),
          externalId: 'bp-1',
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();
      expect(count, 4);

      final createdCategories = verify(
        measurements.addLocalDriftCategory(captureAny),
      ).captured.cast<MeasurementCategory>();
      expect(
        createdCategories.map((c) => c.metricType),
        containsAll([MetricType.bodyFat, MetricType.height, MetricType.bloodPressure]),
      );

      // Blood pressure becomes a group: the typed parent stays entry-free,
      // the readings go into its ordered children
      final bloodPressure = createdCategories.firstWhere(
        (c) => c.metricType == MetricType.bloodPressure,
      );
      expect(bloodPressure.parentId, isNull);
      final systolic = createdCategories.firstWhere((c) => c.name == 'Systolic');
      final diastolic = createdCategories.firstWhere((c) => c.name == 'Diastolic');
      expect(systolic.parentId, bloodPressure.id);
      expect(systolic.order, 0);
      expect(diastolic.parentId, bloodPressure.id);
      expect(diastolic.order, 1);

      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();

      final bodyFat = entries.firstWhere((e) => e.externalId == 'bf-1');
      expect(bodyFat.value, closeTo(20, 0.001)); // fraction -> percent
      expect(bodyFat.source, 'apple');
      // No unit key (category unit applies), but the conversion provenance
      // keeps the platform's original value
      expect(bodyFat.extraData, {
        'recording_method': 'unknown',
        'record_type': 'BODY_FAT_PERCENTAGE',
        'source_value': 0.2,
      });

      final height = entries.firstWhere((e) => e.externalId == 'h-1');
      expect(height.value, 180.3); // meters -> cm, rounded to two decimals

      final systolicEntry = entries.firstWhere((e) => e.categoryId == systolic.id);
      final diastolicEntry = entries.firstWhere((e) => e.categoryId == diastolic.id);
      expect(systolicEntry.value, 120);
      expect(diastolicEntry.value, 80);
      // The pair keeps its shared timestamp and record uuid
      expect(systolicEntry.date, diastolicEntry.date);
      expect(systolicEntry.externalId, 'bp-1');
      expect(diastolicEntry.externalId, 'bp-1');
      expect(entries, hasLength(4));

      // The newest imported reading date becomes the next sync watermark
      expect(
        await PreferenceHelper.instance.getLastHealthSyncTimestamp(),
        DateTime(2026, 1, 3).toIso8601String(),
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

    test('imports weight only into the official body weight category', () async {
      // A user-created lookalike must not receive the readings
      final lookalike = MeasurementCategory(
        id: 'cat-custom',
        name: 'Weight',
        unit: 'kg',
        metricType: MetricType.bodyWeight,
      );
      final official = MeasurementCategory(
        id: 'cat-official',
        name: 'Weight',
        unit: 'kg',
        metricType: MetricType.bodyWeight,
        isOfficial: true,
      );
      when(measurements.getAllOnce()).thenAnswer((_) async => [lookalike, official]);
      stubReadings([
        HealthReading(
          type: HealthDataType.WEIGHT,
          value: 80.5,
          date: DateTime(2026, 1, 1),
          externalId: 'w-1',
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();
      expect(count, 1);
      verifyNever(measurements.addLocalDriftCategory(any));

      final entry =
          verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(entry.categoryId, 'cat-official');
      // Stored unconverted, with the unit and the recording provenance stamped
      expect(entry.value, 80.5);
      expect(entry.extraData, {
        'unit': 'kg',
        'recording_method': 'unknown',
        'record_type': 'WEIGHT',
      });
    });

    test('converts pound readings to kg and keeps the original', () async {
      final official = MeasurementCategory(
        id: 'cat-official',
        name: 'Weight',
        unit: 'kg',
        metricType: MetricType.bodyWeight,
        isOfficial: true,
      );
      when(measurements.getAllOnce()).thenAnswer((_) async => [official]);
      stubReadings([
        HealthReading(
          type: HealthDataType.WEIGHT,
          value: 177.0,
          unit: HealthDataUnit.POUND,
          date: DateTime(2026, 1, 1),
          externalId: 'w-lb',
          recordingMethod: RecordingMethod.manual,
          sourceName: 'Withings Body+',
        ),
      ]);

      await createNotifier().syncOnAppOpen();

      final entry =
          verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      // 177 lb * 0.45359237 = 80.29 kg
      expect(entry.value, 80.29);
      expect(entry.extraData, {
        'unit': 'kg',
        'recording_method': 'manual',
        'record_type': 'WEIGHT',
        'source_name': 'Withings Body+',
        'source_value': 177.0,
        'source_unit': 'lb',
      });
    });

    test('aggregates heart rate into one entry per day', () async {
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEART_RATE,
          value: 60,
          date: DateTime(2026, 1, 1, 8),
          externalId: 'hr-1',
        ),
        HealthReading(
          type: HealthDataType.HEART_RATE,
          value: 71,
          date: DateTime(2026, 1, 1, 20),
          externalId: 'hr-2',
        ),
        HealthReading(
          type: HealthDataType.HEART_RATE,
          value: 64,
          date: DateTime(2026, 1, 2, 9),
          externalId: 'hr-3',
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();

      // Three samples become two daily entries
      expect(count, 2);
      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      expect(entries, hasLength(2));

      final day1 = entries.firstWhere((e) => e.externalId == 'day-2026-01-01');
      expect(day1.date, DateTime(2026, 1, 1));
      expect(day1.value, 65.5); // (60 + 71) / 2
      expect(day1.extraData, {
        'min': 60,
        'max': 71,
        'sample_count': 2,
        'record_type': 'HEART_RATE',
      });

      final day2 = entries.firstWhere((e) => e.externalId == 'day-2026-01-02');
      expect(day2.value, 64);
      expect(day2.extraData?['sample_count'], 1);

      // The watermark tracks the newest sample, not the aggregate's date
      expect(
        await PreferenceHelper.instance.getLastHealthSyncTimestamp(),
        DateTime(2026, 1, 2, 9).toIso8601String(),
      );
    });

    test('keeps resting heart rate in its own category, imported raw', () async {
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEART_RATE,
          value: 70,
          date: DateTime(2026, 1, 1, 8),
          externalId: 'hr-1',
        ),
        HealthReading(
          type: HealthDataType.RESTING_HEART_RATE,
          value: 52,
          date: DateTime(2026, 1, 1, 4),
          externalId: 'rhr-1',
        ),
      ]);

      await createNotifier().syncOnAppOpen();

      final categories = verify(
        measurements.addLocalDriftCategory(captureAny),
      ).captured.cast<MeasurementCategory>();
      final heartRate = categories.firstWhere((c) => c.metricType == MetricType.heartRate);
      final resting = categories.firstWhere((c) => c.metricType == MetricType.restingHeartRate);
      expect(resting.id, isNot(heartRate.id));

      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      final restingEntry = entries.firstWhere((e) => e.categoryId == resting.id);
      // Raw import: the platform record uuid and timestamp are kept as-is,
      // no day- key and no aggregate extra_data
      expect(restingEntry.externalId, 'rhr-1');
      expect(restingEntry.date, DateTime(2026, 1, 1, 4));
      expect(restingEntry.value, 52);
      expect(restingEntry.extraData, isNot(contains('sample_count')));
    });

    test('updates a daily aggregate when later samples change it', () async {
      final existing = MeasurementCategory(
        id: 'cat-hr',
        name: 'Heart rate',
        unit: 'bpm',
        metricType: MetricType.heartRate,
        entries: [
          MeasurementEntry(
            id: 'e1',
            categoryId: 'cat-hr',
            date: DateTime(2026, 1, 1),
            value: 60,
            notes: '',
            externalId: 'day-2026-01-01',
            extraData: const {
              'min': 60,
              'max': 60,
              'sample_count': 1,
              'record_type': 'HEART_RATE',
            },
          ),
        ],
      );
      when(measurements.getAllOnce()).thenAnswer((_) async => [existing]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEART_RATE,
          value: 60,
          date: DateTime(2026, 1, 1, 8),
          externalId: 'hr-1',
        ),
        // A sample that arrived after the previous sync
        HealthReading(
          type: HealthDataType.HEART_RATE,
          value: 70,
          date: DateTime(2026, 1, 1, 20),
          externalId: 'hr-2',
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();

      expect(count, 1);
      verifyNever(measurements.addLocalDrift(any));
      final updated =
          verify(measurements.updateLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(updated.id, 'e1');
      expect(updated.value, 65);
      expect(updated.extraData, {
        'min': 60,
        'max': 70,
        'sample_count': 2,
        'record_type': 'HEART_RATE',
      });
    });

    test('leaves an unchanged daily aggregate alone', () async {
      final existing = MeasurementCategory(
        id: 'cat-hr',
        name: 'Heart rate',
        unit: 'bpm',
        metricType: MetricType.heartRate,
        entries: [
          MeasurementEntry(
            id: 'e1',
            categoryId: 'cat-hr',
            date: DateTime(2026, 1, 1),
            value: 60,
            notes: '',
            externalId: 'day-2026-01-01',
            extraData: const {
              'min': 60,
              'max': 60,
              'sample_count': 1,
              'record_type': 'HEART_RATE',
            },
          ),
        ],
      );
      when(measurements.getAllOnce()).thenAnswer((_) async => [existing]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEART_RATE,
          value: 60,
          date: DateTime(2026, 1, 1, 8),
          externalId: 'hr-1',
        ),
      ]);

      // Re-reading the same samples within the overlap window must not queue
      // a pointless sync upload
      final count = await createNotifier().syncOnAppOpen();

      expect(count, 0);
      verifyNever(measurements.addLocalDrift(any));
      verifyNever(measurements.updateLocalDrift(any));
    });

    test('imports blood pressure into an existing group by in-group order', () async {
      // The user's own group with different names: components map onto the
      // children by their in-group position, not by name
      final parent = MeasurementCategory(
        id: 'bp',
        name: 'BP',
        unit: 'mmHg',
        metricType: MetricType.bloodPressure,
      );
      final upper = MeasurementCategory(id: 'upper', name: 'Upper', unit: 'mmHg', parentId: 'bp');
      final lower = MeasurementCategory(
        id: 'lower',
        name: 'Lower',
        unit: 'mmHg',
        parentId: 'bp',
        order: 1,
      );
      when(measurements.getAllOnce()).thenAnswer((_) async => [parent, upper, lower]);
      stubReadings([
        HealthReading(
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          value: 120,
          date: DateTime(2026, 1, 3),
          externalId: 'bp-1',
        ),
        HealthReading(
          type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          value: 80,
          date: DateTime(2026, 1, 3),
          externalId: 'bp-1',
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();
      expect(count, 2);
      verifyNever(measurements.addLocalDriftCategory(any));

      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      expect(entries.firstWhere((e) => e.value == 120).categoryId, 'upper');
      expect(entries.firstWhere((e) => e.value == 80).categoryId, 'lower');
    });

    test('skips blood pressure when the matching category holds entries', () async {
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2020-01-01T00:00:00.000');
      // A plain leaf category of the blood pressure type: attaching children
      // would make its entries invalid (measurements only on leaves), so the
      // import must not touch it
      final leaf = MeasurementCategory(
        id: 'bp',
        name: 'Blood pressure',
        unit: 'mmHg',
        metricType: MetricType.bloodPressure,
        entries: [
          MeasurementEntry(
            id: 'e1',
            categoryId: 'bp',
            date: DateTime(2026, 1, 1),
            value: 118,
            notes: '',
          ),
        ],
      );
      when(measurements.getAllOnce()).thenAnswer((_) async => [leaf]);
      stubReadings([
        HealthReading(
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          value: 120,
          date: DateTime(2026, 1, 3),
          externalId: 'bp-1',
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();

      // Nothing is written and the watermark holds, so the readings are
      // retried once the conflict is resolved
      expect(count, 0);
      verifyNever(measurements.addLocalDriftCategory(any));
      verifyNever(measurements.addLocalDrift(any));
      expect(
        await PreferenceHelper.instance.getLastHealthSyncTimestamp(),
        '2020-01-01T00:00:00.000',
      );
    });

    test('duration records keep their interval end as date_to', () async {
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 180,
          date: DateTime.utc(2026, 1, 1, 8),
          dateTo: DateTime.utc(2026, 1, 1, 9),
          externalId: 'h-interval',
        ),
      ]);

      await createNotifier().syncOnAppOpen();

      final entry =
          verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(entry.extraData?['date_to'], '2026-01-01T09:00:00.000Z');
    });

    test('skips weight while the official category has not been synced', () async {
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2020-01-01T00:00:00.000');
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.WEIGHT,
          value: 80.5,
          date: DateTime(2026, 1, 1),
          externalId: 'w-1',
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();

      // Never creates the official category; the reading stays unimported (no
      // watermark advance) and is retried on the next sync
      expect(count, 0);
      verifyNever(measurements.addLocalDriftCategory(any));
      verifyNever(measurements.addLocalDrift(any));
      expect(
        await PreferenceHelper.instance.getLastHealthSyncTimestamp(),
        '2020-01-01T00:00:00.000',
      );
    });

    test('keeps the watermark when weight is skipped but other metrics import', () async {
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2020-01-01T00:00:00.000');
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.WEIGHT,
          value: 80.5,
          date: DateTime(2026, 1, 1),
          externalId: 'w-1',
        ),
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: 'h-1',
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();

      // Height imports, but the watermark must not advance past the weight
      // readings: they would leave the overlap window before the official
      // category ever syncs and be lost for good
      expect(count, 1);
      expect(
        await PreferenceHelper.instance.getLastHealthSyncTimestamp(),
        '2020-01-01T00:00:00.000',
      );
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
