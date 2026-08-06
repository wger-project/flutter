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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_bridge/health.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/network/auth_credentials_storage.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/models/health_reading.dart';
import 'package:wger/features/health/providers/health_importer.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

import 'health_importer_test.mocks.dart';

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
const _idS4 = '0000000f-0000-4000-8000-000000000015'; // s-4
const _idW1 = '0000000d-0000-4000-8000-000000000013'; // w-1
const _idWLb = '0000000e-0000-4000-8000-000000000014'; // w-lb

// Category ids are UUIDs too, and dailyAggregateExternalId parses them as the
// v5 namespace.
const _catHrId = 'aaaaaaaa-0000-4000-8000-000000000001';
const _catSleepId = 'bbbbbbbb-0000-4000-8000-000000000002';

/// Whether the local zone shifts its clocks in the night the DST test uses.
///
/// The zone belongs to the process, so a single test cannot pick its own; where
/// there is no shift, that test cannot tell the two ways of counting a day
/// apart and is skipped rather than passing without meaning.
final _springsForward =
    DateTime(2026, 3, 29).timeZoneOffset != DateTime(2026, 3, 30).timeZoneOffset;

@GenerateMocks([HealthRepository, MeasurementRepository, AuthCredentialsStorage])
void main() {
  // SharedPreferencesAsync needs a binding for its platform channel
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHealthRepository health;
  late MockMeasurementRepository measurements;
  late MockAuthCredentialsStorage credentials;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    // SharedPreferencesAsync captures the platform instance in its constructor,
    // and PreferenceHelper builds its own once for the whole run, so the line
    // above only takes effect for the first test. Clear what this suite writes
    await PreferenceHelper.instance.clearHealthSyncPreferences();
    await PreferenceHelper.instance.setHealthSyncEnabled(true);

    health = MockHealthRepository();
    measurements = MockMeasurementRepository();
    credentials = MockAuthCredentialsStorage();
    when(credentials.dbOwnerUserId()).thenAnswer((_) async => '2');

    when(health.ensureAuthorized(any)).thenAnswer((_) async => true);
    when(health.readableTypes(any)).thenAnswer(
      (invocation) async => (invocation.positionalArguments.first as List<HealthDataType>).toSet(),
    );
    when(health.sourceName).thenReturn('apple');
    when(measurements.addLocalDrift(any)).thenAnswer((_) async {});
    when(measurements.updateLocalDrift(any)).thenAnswer((_) async {});
    when(measurements.addLocalDriftCategory(any)).thenAnswer((_) async {});
    when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
    when(measurements.getExternalIds(any)).thenAnswer((_) async => <String>{});
    when(
      measurements.getEntriesByExternalId(any),
    ).thenAnswer((_) async => <String, MeasurementEntry>{});
    when(measurements.hasEntries(any)).thenAnswer((_) async => false);
  });

  HealthImporter createImporter() => HealthImporter(
    health: health,
    measurements: measurements,
    prefs: PreferenceHelper.instance,
    credentials: credentials,
  );

  /// One run, reduced to the number of entries it wrote.
  Future<int> runImport() async => (await createImporter().run()).imported;

  /// A category for every enabled metric, components included, all on the ids
  /// the sync derives. Without them the sync reads the full history instead of
  /// starting from the watermark.
  List<MeasurementCategory> categoriesForEveryMetric() {
    final categories = <MeasurementCategory>[];
    for (final metric in enabledHealthMetrics) {
      if (metric.metricType == MetricType.bodyWeight) {
        categories.add(
          MeasurementCategory(
            id: 'official-body-weight',
            name: 'Body weight',
            unit: 'kg',
            metricType: MetricType.bodyWeight,
            isOfficial: true,
          ),
        );
        continue;
      }

      final parentId = deterministicCategoryId('2', metric.metricType);
      categories.add(
        MeasurementCategory(
          id: parentId,
          name: metric.canonicalName,
          unit: metric.unit,
          metricType: metric.metricType,
        ),
      );
      for (final (order, metricType) in metric.metricType.components.indexed) {
        categories.add(
          MeasurementCategory(
            id: deterministicCategoryId('2', metricType),
            name: metricType.canonicalName,
            unit: metricType.defaultUnit,
            metricType: metricType,
            parentId: parentId,
            order: order,
          ),
        );
      }
    }
    return categories;
  }

  /// The start of the window the sync asked the platform for, per data type.
  ///
  /// Every metric is read separately and a metric that aggregates per day
  /// starts at the beginning of its own day, so the starts differ.
  Map<HealthDataType, DateTime> capturedReadStarts() {
    final captured = verify(
      health.read(
        types: captureAnyNamed('types'),
        start: captureAnyNamed('start'),
        end: anyNamed('end'),
        window: anyNamed('window'),
      ),
    ).captured;

    final starts = <HealthDataType, DateTime>{};
    for (var i = 0; i < captured.length; i += 2) {
      for (final type in captured[i] as List<HealthDataType>) {
        starts[type] = captured[i + 1] as DateTime;
      }
    }
    return starts;
  }

  /// The start of the window for the metric reading [type], body weight by
  /// default: a plain sample metric, which reads from the unrounded start
  DateTime capturedReadStart([HealthDataType type = HealthDataType.WEIGHT]) =>
      capturedReadStarts()[type]!;

  /// Every health data type the sync asked the platform for
  List<HealthDataType> capturedReadTypes() => verify(
    health.read(
      types: captureAnyNamed('types'),
      start: anyNamed('start'),
      end: anyNamed('end'),
      window: anyNamed('window'),
    ),
  ).captured.cast<List<HealthDataType>>().expand((types) => types).toList();

  void stubReadings(List<HealthReading> readings) {
    when(
      health.read(
        types: anyNamed('types'),
        start: anyNamed('start'),
        end: anyNamed('end'),
        window: anyNamed('window'),
      ),
    ).thenAnswer((_) async => readings);
  }

  group('run', () {
    test('never asks for permissions itself, it would prompt out of nowhere', () async {
      stubReadings([]);

      await runImport();

      verify(health.readableTypes(any)).called(1);
      verifyNever(health.ensureAuthorized(any));
    });

    test('flags missing permissions instead of reading', () async {
      when(health.readableTypes(any)).thenAnswer((_) async => <HealthDataType>{});

      final result = await createImporter().run();

      expect(result.imported, 0);
      expect(result.issue, HealthSyncIssue.permissionsMissing);
      verifyNever(
        health.read(
          types: anyNamed('types'),
          start: anyNamed('start'),
          end: anyNamed('end'),
          window: anyNamed('window'),
        ),
      );
    });

    test('a metric without access costs only itself its import', () async {
      // Both platforms hand out access per type, and Health Connect invites
      // the user to untick single ones, so one declined type must not stop
      // everything else
      final bloodPressure = enabledHealthMetrics.firstWhere(
        (m) => m.metricType == MetricType.bloodPressure,
      );
      when(health.readableTypes(any)).thenAnswer(
        (invocation) async => (invocation.positionalArguments.first as List<HealthDataType>)
            .toSet()
            .difference(bloodPressure.dataTypes.toSet()),
      );
      stubReadings([
        HealthReading(
          type: HealthDataType.BODY_FAT_PERCENTAGE,
          value: 0.2,
          date: DateTime(2026, 1, 1),
          externalId: _idBf1,
        ),
      ]);

      final result = await createImporter().run();

      expect(result.imported, 1);
      expect(result.issue, isNull);
      // The declined types are not even asked for
      final requested = capturedReadTypes();
      expect(requested, isNot(contains(HealthDataType.BLOOD_PRESSURE_SYSTOLIC)));
      expect(requested, contains(HealthDataType.BODY_FAT_PERCENTAGE));
    });

    test('reads the full history when a type becomes readable', () async {
      // Granting access to a type that was declined leaves the same hole as a
      // deleted category: nothing was ever imported for it
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2026-06-01T12:00:00.000');
      await PreferenceHelper.instance.setHealthSyncReadableTypes([
        HealthDataType.BODY_FAT_PERCENTAGE.name,
      ]);
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => categoriesForEveryMetric());
      stubReadings([]);

      await runImport();

      expect(capturedReadStart(), DateTime(2020));
    });

    test('stays on the watermark while the readable types are unchanged', () async {
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2026-06-01T12:00:00.000');
      await PreferenceHelper.instance.setHealthSyncReadableTypes([
        for (final metric in enabledHealthMetrics)
          for (final type in metric.dataTypes) type.name,
      ]);
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => categoriesForEveryMetric());
      stubReadings([]);

      await runImport();

      expect(capturedReadStart(), DateTime(2026, 5, 2, 12));
    });

    test('a read the platform refuses for authorization is a permission issue', () async {
      // The one permission problem iOS reports at all, and what a reinstall
      // leaves behind: the preference says enabled, HealthKit disagrees
      when(
        health.read(
          types: anyNamed('types'),
          start: anyNamed('start'),
          end: anyNamed('end'),
          window: anyNamed('window'),
        ),
      ).thenThrow(
        PlatformException(
          code: 'HEALTH_ERROR',
          message: 'Error getting health data: Authorization not determined',
        ),
      );

      final result = await createImporter().run();

      expect(result.imported, 0);
      expect(result.issue, HealthSyncIssue.permissionsMissing);
    });

    test('any other failure is reported as a plain failure', () async {
      when(
        health.read(
          types: anyNamed('types'),
          start: anyNamed('start'),
          end: anyNamed('end'),
          window: anyNamed('window'),
        ),
      ).thenThrow(Exception('boom'));

      final result = await createImporter().run();

      expect(result.imported, 0);
      expect(result.issue, HealthSyncIssue.failed);
    });

    test('one failing metric does not cost the others their import', () async {
      // Writing the body fat entry fails; height must still make it in, and
      // the watermark must stay put so the lost readings stay in the window
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      when(measurements.addLocalDrift(any)).thenAnswer((invocation) async {
        final entry = invocation.positionalArguments.first as MeasurementEntry;
        if (entry.value == 20) {
          throw Exception('write failed');
        }
      });
      stubReadings([
        HealthReading(
          type: HealthDataType.BODY_FAT_PERCENTAGE,
          value: 0.2,
          date: DateTime(2026, 1, 1),
          externalId: _idBf1,
        ),
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: _idH1,
        ),
      ]);

      final result = await createImporter().run();

      expect(result.imported, 1);
      expect(result.issue, HealthSyncIssue.failed);
      expect(await PreferenceHelper.instance.getLastHealthSyncTimestamp(), isNull);
    });

    test('imports enabled metrics into new categories with converted values', () async {
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
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

      final count = await runImport();
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
      final systolic = createdCategories.firstWhere(
        (c) => c.metricType == MetricType.bloodPressureSystolic,
      );
      final diastolic = createdCategories.firstWhere(
        (c) => c.metricType == MetricType.bloodPressureDiastolic,
      );
      expect(systolic.name, 'Systolic');
      expect(systolic.parentId, bloodPressure.id);
      expect(systolic.order, 0);
      expect(diastolic.name, 'Diastolic');
      expect(diastolic.parentId, bloodPressure.id);
      expect(diastolic.order, 1);

      // Every created category takes the id derived from user and metric
      // type, which is the one the server derives as well
      for (final category in createdCategories) {
        expect(category.id, deterministicCategoryId('2', category.metricType));
      }

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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: 'not-a-uuid-42',
        ),
      ]);

      await runImport();

      final entry =
          verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(entry.externalId, matches(RegExp(r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$')));
      // The platform's own id survives for the later delete sync
      expect(entry.extraData?['source_record_id'], 'not-a-uuid-42');
    });

    test('passes a valid platform UUID through untouched', () async {
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: '3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        ),
      ]);

      await runImport();

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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => [existing]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: 'not-a-uuid-42',
        ),
      ]);

      await runImport();
      final firstId =
          (verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry)
              .externalId!;

      // Same reading again, with the entry already stored under the folded id
      when(measurements.getExternalIds(_catHrId)).thenAnswer((_) async => {firstId});

      final count = await runImport();

      expect(count, 0);
      verifyNever(measurements.addLocalDrift(any));
    });

    test('skips readings already imported (dedup by externalId)', () async {
      final existing = MeasurementCategory(
        id: 'cat-bf',
        name: 'Body fat',
        unit: '%',
        metricType: MetricType.bodyFat,
      );
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => [existing]);
      when(measurements.getExternalIds('cat-bf')).thenAnswer((_) async => {_idBf1});
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

      final count = await runImport();
      expect(count, 1);
      verifyNever(measurements.addLocalDriftCategory(any));

      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      expect(entries.single.externalId, _idBf2);
    });

    test('drops a reading outside the limits of its metric type', () async {
      stubReadings([
        HealthReading(
          type: HealthDataType.BODY_FAT_PERCENTAGE,
          value: 0.9, // 90 %, more than the server accepts
          date: DateTime(2026, 1, 1),
          externalId: _idBf1,
        ),
        HealthReading(
          type: HealthDataType.BODY_FAT_PERCENTAGE,
          value: 0.22,
          date: DateTime(2026, 1, 3),
          externalId: _idBf2,
        ),
      ]);

      final count = await runImport();

      expect(count, 1);
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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => [lookalike, official]);
      stubReadings([
        HealthReading(
          type: HealthDataType.WEIGHT,
          value: 80.5,
          date: DateTime(2026, 1, 1),
          externalId: _idW1,
        ),
      ]);

      final count = await runImport();
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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => [official]);
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

      await runImport();

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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
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

      final count = await runImport();

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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
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

      await runImport();

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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
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

      final count = await runImport();

      // All three segments belong to 2026-01-02, and only the total collects
      // them: the stage categories have no samples of their own here
      expect(count, 1);
      final entry =
          verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      final categoryId = _sleepCategoryId(measurements, MetricType.sleepTotal);
      expect(entry.categoryId, categoryId);
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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
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

      final count = await runImport();

      expect(count, 2);
      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      final categoryId = _sleepCategoryId(measurements, MetricType.sleepTotal);
      final byDay = {
        for (final e in entries) e.externalId: e.value,
      };
      expect(byDay[dailyAggregateExternalId(categoryId, DateTime(2026, 1, 1))], 20);
      expect(byDay[dailyAggregateExternalId(categoryId, DateTime(2026, 1, 2))], 400);
    });

    test(
      'keeps a night across a time change as one aggregate',
      () async {
        // With +24h the two halves of the night key apart but format to the same
        // date, so both would claim one external id
        when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
        stubReadings([
          HealthReading(
            type: HealthDataType.SLEEP_ASLEEP,
            value: 120,
            date: DateTime(2026, 3, 29, 23, 0),
            dateTo: DateTime(2026, 3, 30, 1, 0),
            externalId: _idS1,
          ),
          HealthReading(
            type: HealthDataType.SLEEP_ASLEEP,
            value: 300,
            date: DateTime(2026, 3, 30, 1, 0),
            dateTo: DateTime(2026, 3, 30, 6, 0),
            externalId: _idS2,
          ),
        ]);

        final count = await runImport();

        expect(count, 1);
        final entry =
            verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
        final categoryId = _sleepCategoryId(measurements, MetricType.sleepTotal);
        expect(entry.externalId, dailyAggregateExternalId(categoryId, DateTime(2026, 3, 30)));
        expect(entry.date, DateTime(2026, 3, 30));
        expect(entry.value, 420);
      },
      skip: _springsForward ? false : 'needs a time zone that shifts on 2026-03-30 (CI: Berlin)',
    );

    test('imports each sleep stage into its own category', () async {
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        // A night as a watch records it: stages rather than one asleep block
        HealthReading(
          type: HealthDataType.SLEEP_LIGHT,
          value: 120,
          date: DateTime(2026, 1, 1, 23, 0),
          dateTo: DateTime(2026, 1, 2, 1, 0),
          externalId: _idS1,
        ),
        HealthReading(
          type: HealthDataType.SLEEP_DEEP,
          value: 90,
          date: DateTime(2026, 1, 2, 1, 0),
          dateTo: DateTime(2026, 1, 2, 2, 30),
          externalId: _idS2,
        ),
        HealthReading(
          type: HealthDataType.SLEEP_REM,
          value: 60,
          date: DateTime(2026, 1, 2, 2, 30),
          dateTo: DateTime(2026, 1, 2, 3, 30),
          externalId: _idS3,
        ),
        HealthReading(
          type: HealthDataType.SLEEP_AWAKE,
          value: 15,
          date: DateTime(2026, 1, 2, 3, 30),
          dateTo: DateTime(2026, 1, 2, 3, 45),
          externalId: _idS4,
        ),
      ]);

      await runImport();

      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      final categories = verify(
        measurements.addLocalDriftCategory(captureAny),
      ).captured.cast<MeasurementCategory>();
      final typeOf = {for (final c in categories) c.id: c.metricType};
      final byType = {for (final e in entries) typeOf[e.categoryId]: e.value};

      expect(byType[MetricType.sleepLight], 120);
      expect(byType[MetricType.sleepDeep], 90);
      expect(byType[MetricType.sleepRem], 60);
      expect(byType[MetricType.sleepAwake], 15);
      // The stages roll up into the total, the waking quarter hour does not
      expect(byType[MetricType.sleepTotal], 270);
      // The group itself never carries entries
      expect(byType.containsKey(MetricType.sleep), isFalse);
    });

    test('counts a night reported by two sources once', () async {
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        // The phone writes the whole night as undifferentiated sleep while the
        // watch writes the very same night as its stages. Adding the durations
        // up would report twice the sleep.
        HealthReading(
          type: HealthDataType.SLEEP_ASLEEP,
          value: 240,
          date: DateTime(2026, 1, 1, 23, 0),
          dateTo: DateTime(2026, 1, 2, 3, 0),
          externalId: _idS1,
        ),
        HealthReading(
          type: HealthDataType.SLEEP_LIGHT,
          value: 180,
          date: DateTime(2026, 1, 1, 23, 0),
          dateTo: DateTime(2026, 1, 2, 2, 0),
          externalId: _idS2,
        ),
        HealthReading(
          type: HealthDataType.SLEEP_DEEP,
          value: 60,
          date: DateTime(2026, 1, 2, 2, 0),
          dateTo: DateTime(2026, 1, 2, 3, 0),
          externalId: _idS3,
        ),
      ]);

      await runImport();

      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      final totalId = _sleepCategoryId(measurements, MetricType.sleepTotal);
      final total = entries.firstWhere((e) => e.categoryId == totalId);

      expect(total.value, 240);
      expect(total.extraData!['record_type'], 'SLEEP_ASLEEP,SLEEP_DEEP,SLEEP_LIGHT');
    });

    test('updates a daily aggregate when later samples change it', () async {
      final existing = MeasurementCategory(
        id: _catHrId,
        name: 'Heart rate',
        unit: 'bpm',
        metricType: MetricType.heartRate,
      );
      final stored = MeasurementEntry(
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
      );
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => [existing]);
      when(
        measurements.getEntriesByExternalId(_catHrId),
      ).thenAnswer((_) async => {stored.externalId!: stored});
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

      final count = await runImport();

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
      );
      final stored = MeasurementEntry(
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
      );
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => [existing]);
      when(
        measurements.getEntriesByExternalId(_catHrId),
      ).thenAnswer((_) async => {stored.externalId!: stored});
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
      final count = await runImport();

      expect(count, 0);
      verifyNever(measurements.addLocalDrift(any));
      verifyNever(measurements.updateLocalDrift(any));
    });

    test('imports blood pressure into an existing group by component type', () async {
      // The user's own group with different names: components map onto the
      // children by their metric type, not by name
      final parent = MeasurementCategory(
        id: 'bp',
        name: 'BP',
        unit: 'mmHg',
        metricType: MetricType.bloodPressure,
      );
      final upper = MeasurementCategory(
        id: 'upper',
        name: 'Upper',
        unit: 'mmHg',
        metricType: MetricType.bloodPressureSystolic,
        parentId: 'bp',
      );
      final lower = MeasurementCategory(
        id: 'lower',
        name: 'Lower',
        unit: 'mmHg',
        metricType: MetricType.bloodPressureDiastolic,
        parentId: 'bp',
        order: 1,
      );
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => [parent, upper, lower]);
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

      final count = await runImport();
      expect(count, 2);
      verifyNever(measurements.addLocalDriftCategory(any));

      final entries = verify(
        measurements.addLocalDrift(captureAny),
      ).captured.cast<MeasurementEntry>();
      expect(entries.firstWhere((e) => e.value == 120).categoryId, 'upper');
      expect(entries.firstWhere((e) => e.value == 80).categoryId, 'lower');
    });

    test(
      'a category with the canonical name is not adopted, only the metric type counts',
      () async {
        // Matching by name made the target depend on the UI language, so a
        // hand-kept category is only used once it carries the metric type
        final handMade = MeasurementCategory(id: 'own', name: 'Body fat', unit: '%');
        when(measurements.getCategoriesOnce()).thenAnswer((_) async => [handMade]);
        stubReadings([
          HealthReading(
            type: HealthDataType.BODY_FAT_PERCENTAGE,
            value: 0.2,
            date: DateTime(2026, 1, 1),
            externalId: _idBf1,
          ),
        ]);

        await runImport();

        final created = verify(
          measurements.addLocalDriftCategory(captureAny),
        ).captured.cast<MeasurementCategory>();
        expect(created.single.metricType, MetricType.bodyFat);
        expect(created.single.id, deterministicCategoryId('2', MetricType.bodyFat));

        final entries = verify(
          measurements.addLocalDrift(captureAny),
        ).captured.cast<MeasurementEntry>();
        expect(entries.single.categoryId, created.single.id);
      },
    );

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
      );
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => [leaf]);
      when(measurements.hasEntries('bp')).thenAnswer((_) async => true);
      stubReadings([
        HealthReading(
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          value: 120,
          date: DateTime(2026, 1, 3),
          externalId: _idBp1,
        ),
      ]);

      final count = await runImport();

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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 180,
          date: DateTime.utc(2026, 1, 1, 8),
          dateTo: DateTime.utc(2026, 1, 1, 9),
          externalId: _idHInterval,
        ),
      ]);

      await runImport();

      final entry =
          verify(measurements.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(entry.extraData?['date_to'], '2026-01-01T09:00:00.000Z');
    });

    test('skips weight while the official category has not been synced', () async {
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2020-01-01T00:00:00.000');
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
      stubReadings([
        HealthReading(
          type: HealthDataType.WEIGHT,
          value: 80.5,
          date: DateTime(2026, 1, 1),
          externalId: _idW1,
        ),
      ]);

      final count = await runImport();

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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
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

      final count = await runImport();

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
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => categoriesForEveryMetric());
      stubReadings([]);

      await runImport();

      // 30 days before the watermark, so late-arriving backdated records
      // (e.g. a scale syncing days after the measurement) are still picked up
      expect(capturedReadStart(), DateTime(2026, 5, 2, 12));
    });

    test('a metric the platform has nothing for stops forcing the full history', () async {
      // No reading means no category, and a metric without one is what asks
      // for the full window: it would do so on every sync, for every metric
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2026-06-01T12:00:00.000');
      when(measurements.getCategoriesOnce()).thenAnswer(
        (_) async =>
            categoriesForEveryMetric().where((c) => c.metricType != MetricType.bodyFat).toList(),
      );
      stubReadings([]);

      await runImport();
      expect(capturedReadStart(), DateTime(2020));

      await runImport();
      expect(capturedReadStart(), DateTime(2026, 5, 2, 12));
    });

    test('a deleted category is read again even after an empty run', () async {
      // Only a metric without a category is remembered as empty, so deleting
      // the category of one that has data still gets its history back
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2026-06-01T12:00:00.000');
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => categoriesForEveryMetric());
      stubReadings([]);

      await runImport();
      expect(capturedReadStart(), DateTime(2026, 5, 2, 12));

      when(measurements.getCategoriesOnce()).thenAnswer(
        (_) async =>
            categoriesForEveryMetric().where((c) => c.metricType != MetricType.bodyFat).toList(),
      );

      await runImport();
      expect(capturedReadStart(), DateTime(2020));
    });

    test('an aggregating metric reads from the start of its own day', () async {
      // The overlap start is a time of day, and a daily aggregate is
      // recomputed from what the window returns: cutting into the day would
      // overwrite that day's stored value with the part that was read
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2026-06-01T12:00:00.000');
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => categoriesForEveryMetric());
      stubReadings([]);

      await runImport();

      final starts = capturedReadStarts();
      // A sample metric has no aggregate to protect and reads from the
      // watermark minus the overlap
      expect(starts[HealthDataType.WEIGHT], DateTime(2026, 5, 2, 12));
      // Heart rate is stored as one aggregate per calendar day
      expect(starts[HealthDataType.HEART_RATE], DateTime(2026, 5, 2));
      // The sleep day of 2 May began at 18:00 on 1 May
      expect(starts[HealthDataType.SLEEP_ASLEEP], DateTime(2026, 5, 1, 18));
    });

    test('reads the full history when a category was deleted', () async {
      // Deleting a category takes its entries with it, and the watermark says
      // nothing about a metric that has no history left: reading from it would
      // import only what happened since and leave the rest missing
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2026-06-01T12:00:00.000');
      final remaining = categoriesForEveryMetric()
          .where((c) => c.metricType != MetricType.bodyFat)
          .toList();
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => remaining);
      stubReadings([]);

      await runImport();

      expect(capturedReadStart(), DateTime(2020));
    });

    test('reads the full history when one component of a group was deleted', () async {
      // The readings live in the components, so a group that lost one of them
      // has the same hole as a metric without any category
      await PreferenceHelper.instance.setLastHealthSyncTimestamp('2026-06-01T12:00:00.000');
      final remaining = categoriesForEveryMetric()
          .where((c) => c.metricType != MetricType.bloodPressureDiastolic)
          .toList();
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => remaining);
      stubReadings([]);

      await runImport();

      expect(capturedReadStart(), DateTime(2020));
    });

    test('each metric is read with the window its density affords', () async {
      // A month of heart rate does not fit into the Android app heap, a month
      // of scale readings is nothing, so the window comes from the metric
      stubReadings([]);

      await runImport();

      final calls = verify(
        health.read(
          types: captureAnyNamed('types'),
          start: anyNamed('start'),
          end: anyNamed('end'),
          window: captureAnyNamed('window'),
        ),
      ).captured;
      final windowByType = <HealthDataType, Duration>{
        for (var i = 0; i < calls.length; i += 2)
          for (final type in calls[i] as List<HealthDataType>) type: calls[i + 1] as Duration,
      };

      expect(windowByType[HealthDataType.HEART_RATE], highVolumeReadWindow);
      expect(windowByType[HealthDataType.BODY_FAT_PERCENTAGE], defaultReadWindow);
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
}

/// The id of the sleep category with [metricType] among the ones the sync
/// created. Sleep is a group, so a run creates the group plus one child per
/// stage; consumes the recorded calls, so call it once per test.
String _sleepCategoryId(MockMeasurementRepository measurements, MetricType metricType) => verify(
  measurements.addLocalDriftCategory(captureAny),
).captured.cast<MeasurementCategory>().firstWhere((c) => c.metricType == metricType).id!;
