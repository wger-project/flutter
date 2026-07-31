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

// Platform record ids are UUIDs in production and only pass through unchanged
// if they are, so the fixtures use real ones behind readable names.
const _idBf1 = '00000001-0000-4000-8000-000000000001'; // bf-1
const _idBf2 = '00000002-0000-4000-8000-000000000002'; // bf-2
const _idBp1 = '00000003-0000-4000-8000-000000000003'; // bp-1
const _idH1 = '00000004-0000-4000-8000-000000000004'; // h-1
const _idHInterval = '00000005-0000-4000-8000-000000000005'; // h-interval
const _idHr1 = '00000006-0000-4000-8000-000000000006'; // hr-1
const _idHr2 = '00000007-0000-4000-8000-000000000007'; // hr-2
const _idHr3 = '00000008-0000-4000-8000-000000000008'; // hr-3
const _idRhr1 = '00000009-0000-4000-8000-000000000009'; // rhr-1
const _idS1 = '0000000a-0000-4000-8000-000000000010'; // s-1
const _idS2 = '0000000b-0000-4000-8000-000000000011'; // s-2
const _idS3 = '0000000c-0000-4000-8000-000000000012'; // s-3
const _idW1 = '0000000d-0000-4000-8000-000000000013'; // w-1
const _idWLb = '0000000e-0000-4000-8000-000000000014'; // w-lb

// Category ids are UUIDs too, and dailyAggregateExternalId parses them as the
// v5 namespace.
const _catHrId = 'aaaaaaaa-0000-4000-8000-000000000001';
const _catSleepId = 'bbbbbbbb-0000-4000-8000-000000000002';

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
          externalId: _idH1,
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

  group('dailyAggregateExternalId', () {
    test('is a UUID', () {
      // The server stores external_id as a UUIDField and rejects anything
      // else permanently, so a readable day key would silently lose every
      // aggregate on push
      expect(
        dailyAggregateExternalId(_catHrId, DateTime(2026, 1, 1)),
        matches(RegExp(r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$')),
      );
    });

    test('is stable per category and day, and differs across both', () {
      final id = dailyAggregateExternalId(_catHrId, DateTime(2026, 1, 1));
      expect(dailyAggregateExternalId(_catHrId, DateTime(2026, 1, 1)), id);
      expect(dailyAggregateExternalId(_catHrId, DateTime(2026, 1, 2)), isNot(id));
      expect(dailyAggregateExternalId(_catSleepId, DateTime(2026, 1, 1)), isNot(id));
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
          externalId: _idBf1,
        ),
        HealthReading(
          type: HealthDataType.HEIGHT,
          // 1.803 * 100 is 180.29999999999998 in double arithmetic; the
          // server's Decimal(2) validation requires the stored value to be
          // rounded to exactly 180.3
          value: 1.803,
          date: DateTime(2026, 1, 2),
          externalId: _idH1,
        ),
        // A blood pressure reading is the systolic/diastolic pair sharing one
        // timestamp; Health Connect also shares the record uuid between them
        HealthReading(
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          value: 120,
          date: DateTime(2026, 1, 3),
          externalId: _idBp1,
        ),
        HealthReading(
          type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          value: 80,
          date: DateTime(2026, 1, 3),
          externalId: _idBp1,
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

      final bodyFat = entries.firstWhere((e) => e.externalId == _idBf1);
      expect(bodyFat.value, closeTo(20, 0.001)); // fraction -> percent
      expect(bodyFat.source, 'apple');
      // No unit key (category unit applies), but the conversion provenance
      // keeps the platform's original value
      expect(bodyFat.extraData, {
        'recording_method': 'unknown',
        'record_type': 'BODY_FAT_PERCENTAGE',
        'source_value': 0.2,
      });

      final height = entries.firstWhere((e) => e.externalId == _idH1);
      expect(height.value, 180.3); // meters -> cm, rounded to two decimals

      final systolicEntry = entries.firstWhere((e) => e.categoryId == systolic.id);
      final diastolicEntry = entries.firstWhere((e) => e.categoryId == diastolic.id);
      expect(systolicEntry.value, 120);
      expect(diastolicEntry.value, 80);
      // The pair keeps its shared timestamp and record uuid
      expect(systolicEntry.date, diastolicEntry.date);
      expect(systolicEntry.externalId, _idBp1);
      expect(diastolicEntry.externalId, _idBp1);
      expect(entries, hasLength(4));

      // The newest imported reading date becomes the next sync watermark
      expect(
        await PreferenceHelper.instance.getLastHealthSyncTimestamp(),
        DateTime(2026, 1, 3).toIso8601String(),
      );
    });

    test('folds a non-UUID platform id into a UUID and keeps the original', () async {
      // Health Connect only documents Metadata.id as a String; a non-UUID would
      // be rejected permanently by the server's UUIDField
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: 'not-a-uuid-42',
        ),
      ]);

      await createNotifier().syncOnAppOpen();

      final entry =
          verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(entry.externalId, matches(RegExp(r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$')));
      // The platform's own id survives for the later delete sync
      expect(entry.extraData?['source_record_id'], 'not-a-uuid-42');
    });

    test('passes a valid platform UUID through untouched', () async {
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: '3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        ),
      ]);

      await createNotifier().syncOnAppOpen();

      final entry =
          verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(entry.externalId, '3f2504e0-4f89-41d3-9a0c-0305e82c3301');
      expect(entry.extraData, isNot(contains('source_record_id')));
    });

    test('dedups folded ids on re-import', () async {
      // The fold is deterministic, so the second sync recognises the entry
      final existing = MeasurementCategory(
        id: _catHrId,
        name: 'Height',
        unit: 'cm',
        metricType: MetricType.height,
      );
      when(measurements.getAllOnce()).thenAnswer((_) async => [existing]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: 'not-a-uuid-42',
        ),
      ]);

      await createNotifier().syncOnAppOpen();
      final firstId =
          (verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry)
              .externalId!;

      // Same reading again, with the entry already stored under the folded id
      when(measurements.getAllOnce()).thenAnswer(
        (_) async => [
          existing.copyWith(
            entries: [
              MeasurementEntry(
                id: 'e1',
                categoryId: _catHrId,
                date: DateTime(2026, 1, 2),
                value: 180,
                notes: '',
                externalId: firstId,
              ),
            ],
          ),
        ],
      );

      final count = await createNotifier().syncOnAppOpen();

      expect(count, 0);
      verifyNever(measurements.addLocalDrift(any));
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
            externalId: _idBf1,
          ),
        ],
      );
      when(measurements.getAllOnce()).thenAnswer((_) async => [existing]);
      stubReadings([
        HealthReading(
          type: HealthDataType.BODY_FAT_PERCENTAGE,
          value: 0.2,
          date: DateTime(2026, 1, 1),
          externalId: _idBf1, // already imported
        ),
        HealthReading(
          type: HealthDataType.BODY_FAT_PERCENTAGE,
          value: 0.22,
          date: DateTime(2026, 1, 3),
          externalId: _idBf2, // new
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();
      expect(count, 1);
      verifyNever(measurements.addLocalDriftCategory(any));

      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      expect(entries.single.externalId, _idBf2);
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
          externalId: _idW1,
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
          externalId: _idWLb,
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
          externalId: _idHr1,
        ),
        HealthReading(
          type: HealthDataType.HEART_RATE,
          value: 71,
          date: DateTime(2026, 1, 1, 20),
          externalId: _idHr2,
        ),
        HealthReading(
          type: HealthDataType.HEART_RATE,
          value: 64,
          date: DateTime(2026, 1, 2, 9),
          externalId: _idHr3,
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();

      // Three samples become two daily entries
      expect(count, 2);
      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      expect(entries, hasLength(2));

      final categoryId =
          (verify(measurements.addLocalDriftCategory(captureAny)).captured.single
                  as MeasurementCategory)
              .id!;

      final day1 = entries.firstWhere(
        (e) => e.externalId == dailyAggregateExternalId(categoryId, DateTime(2026, 1, 1)),
      );
      expect(day1.date, DateTime(2026, 1, 1));
      expect(day1.value, 65.5); // (60 + 71) / 2
      expect(day1.extraData, {
        'min': 60,
        'max': 71,
        'sample_count': 2,
        'record_type': 'HEART_RATE',
      });

      final day2 = entries.firstWhere(
        (e) => e.externalId == dailyAggregateExternalId(categoryId, DateTime(2026, 1, 2)),
      );
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
          externalId: _idHr1,
        ),
        HealthReading(
          type: HealthDataType.RESTING_HEART_RATE,
          value: 52,
          date: DateTime(2026, 1, 1, 4),
          externalId: _idRhr1,
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
      expect(restingEntry.externalId, _idRhr1);
      expect(restingEntry.date, DateTime(2026, 1, 1, 4));
      expect(restingEntry.value, 52);
      expect(restingEntry.extraData, isNot(contains('sample_count')));
    });

    test('sums a night of sleep onto the wake day', () async {
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        // One night, split into segments across midnight: everything from
        // 18:00 onwards counts towards the following day
        HealthReading(
          type: HealthDataType.SLEEP_ASLEEP,
          value: 90,
          date: DateTime(2026, 1, 1, 22, 30),
          dateTo: DateTime(2026, 1, 2, 0, 0),
          externalId: _idS1,
        ),
        HealthReading(
          type: HealthDataType.SLEEP_ASLEEP,
          value: 360,
          date: DateTime(2026, 1, 2, 0, 0),
          dateTo: DateTime(2026, 1, 2, 6, 0),
          externalId: _idS2,
        ),
        // A nap in the afternoon lands on its own calendar day
        HealthReading(
          type: HealthDataType.SLEEP_ASLEEP,
          value: 30,
          date: DateTime(2026, 1, 2, 14, 0),
          dateTo: DateTime(2026, 1, 2, 14, 30),
          externalId: _idS3,
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();

      // All three segments belong to 2026-01-02
      expect(count, 1);
      final entry =
          verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      final categoryId =
          (verify(measurements.addLocalDriftCategory(captureAny)).captured.single
                  as MeasurementCategory)
              .id!;
      expect(entry.externalId, dailyAggregateExternalId(categoryId, DateTime(2026, 1, 2)));
      expect(entry.date, DateTime(2026, 1, 2));
      expect(entry.value, 480); // 90 + 360 + 30 minutes
      expect(entry.extraData, {
        'sample_count': 3,
        'record_type': 'SLEEP_ASLEEP',
        // The window the segments really cover, since the entry's date is the
        // wake day rather than the samples' calendar day
        'date_from': DateTime(2026, 1, 1, 22, 30).toIso8601String(),
        'date_to': DateTime(2026, 1, 2, 14, 30).toIso8601String(),
      });
      // A summed metric has no meaningful per-sample min/max
      expect(entry.extraData, isNot(contains('min')));
    });

    test('splits sleep into separate days at the rollover hour', () async {
      when(measurements.getAllOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        // 17:59 still belongs to the first day, 18:00 already to the next
        HealthReading(
          type: HealthDataType.SLEEP_ASLEEP,
          value: 20,
          date: DateTime(2026, 1, 1, 17, 59),
          externalId: _idS1,
        ),
        HealthReading(
          type: HealthDataType.SLEEP_ASLEEP,
          value: 400,
          date: DateTime(2026, 1, 1, 18, 0),
          externalId: _idS2,
        ),
      ]);

      final count = await createNotifier().syncOnAppOpen();

      expect(count, 2);
      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      final categoryId =
          (verify(measurements.addLocalDriftCategory(captureAny)).captured.single
                  as MeasurementCategory)
              .id!;
      final byDay = {
        for (final e in entries) e.externalId: e.value,
      };
      expect(byDay[dailyAggregateExternalId(categoryId, DateTime(2026, 1, 1))], 20);
      expect(byDay[dailyAggregateExternalId(categoryId, DateTime(2026, 1, 2))], 400);
    });

    test('updates a daily aggregate when later samples change it', () async {
      final existing = MeasurementCategory(
        id: _catHrId,
        name: 'Heart rate',
        unit: 'bpm',
        metricType: MetricType.heartRate,
        entries: [
          MeasurementEntry(
            id: 'e1',
            categoryId: _catHrId,
            date: DateTime(2026, 1, 1),
            value: 60,
            notes: '',
            externalId: dailyAggregateExternalId(_catHrId, DateTime(2026, 1, 1)),
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
          externalId: _idHr1,
        ),
        // A sample that arrived after the previous sync
        HealthReading(
          type: HealthDataType.HEART_RATE,
          value: 70,
          date: DateTime(2026, 1, 1, 20),
          externalId: _idHr2,
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
        id: _catHrId,
        name: 'Heart rate',
        unit: 'bpm',
        metricType: MetricType.heartRate,
        entries: [
          MeasurementEntry(
            id: 'e1',
            categoryId: _catHrId,
            date: DateTime(2026, 1, 1),
            value: 60,
            notes: '',
            externalId: dailyAggregateExternalId(_catHrId, DateTime(2026, 1, 1)),
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
          externalId: _idHr1,
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
          externalId: _idBp1,
        ),
        HealthReading(
          type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          value: 80,
          date: DateTime(2026, 1, 3),
          externalId: _idBp1,
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
          externalId: _idBp1,
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
          externalId: _idHInterval,
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
          externalId: _idW1,
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
          externalId: _idW1,
        ),
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: _idH1,
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
