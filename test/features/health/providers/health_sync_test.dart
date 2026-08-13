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
import 'package:wger/core/network/auth_credentials_storage.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/health/models/health_reading.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/health/providers/health_sync.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

import 'health_sync_test.mocks.dart';

// A platform record id, as a real UUID. What happens to one that is not is
// the importer's business, not this one's.
const _idH1 = '00000004-0000-4000-8000-000000000004';

@GenerateMocks([HealthRepository, MeasurementRepository, AuthCredentialsStorage])
void main() {
  // The notifier registers an AppLifecycleListener for the resume re-sync,
  // which needs a live widgets binding even in plain tests
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

  late ProviderContainer container;

  HealthSyncNotifier createNotifier() {
    container = ProviderContainer.test(
      overrides: [
        healthRepositoryProvider.overrideWithValue(health),
        measurementRepositoryProvider.overrideWithValue(measurements),
        authCredentialsStorageProvider.overrideWithValue(credentials),
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
        window: anyNamed('window'),
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
        health.read(
          types: anyNamed('types'),
          start: anyNamed('start'),
          end: anyNamed('end'),
          window: anyNamed('window'),
        ),
      );
    });

    test('persists the preference and runs an initial import', () async {
      await PreferenceHelper.instance.setHealthSyncEnabled(false);
      when(measurements.getCategoriesOnce()).thenAnswer((_) async => <MeasurementCategory>[]);
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
      await PreferenceHelper.instance.setHealthSyncWatermarks({
        'height': '2026-06-01T12:00:00.000',
      });
      final notifier = createNotifier();
      // let _loadPersistedState finish so it cannot re-enable the state later
      await pumpEventQueue();
      expect(container.read(healthSyncProvider).isEnabled, isTrue);

      await notifier.disableSync();

      expect(await PreferenceHelper.instance.getHealthSyncEnabled(), isFalse);
      expect(await PreferenceHelper.instance.getHealthSyncWatermarks(), isEmpty);
      expect(container.read(healthSyncProvider).isEnabled, isFalse);
    });
  });

  group('sync', () {
    test('does nothing while the preference is off', () async {
      await PreferenceHelper.instance.setHealthSyncEnabled(false);

      expect(await createNotifier().sync(), 0);
      verifyNever(health.readableTypes(any));
    });

    test('does nothing while a run is already going', () async {
      // The resume listener fires while a manual sync is still running, and a
      // second pass would re-read the same window for nothing
      stubReadings([]);
      final notifier = createNotifier();
      final first = notifier.sync();

      expect(await notifier.sync(), 0);
      await first;
      verify(health.readableTypes(any)).called(1);
    });

    test('stamps lastSyncTime after a completed run, even an empty one', () async {
      stubReadings([]);
      final notifier = createNotifier();

      expect(container.read(healthSyncProvider).lastSyncTime, isNull);
      await notifier.sync();

      expect(container.read(healthSyncProvider).lastSyncTime, isNotNull);
      expect(container.read(healthSyncProvider).isSyncing, isFalse);
      expect(container.read(healthSyncProvider).issue, isNull);
    });

    test('a run that gave up early reports the issue and keeps the timestamp', () async {
      // Nothing was read, so the last time the metrics were looked at still
      // stands; the state says why this attempt delivered nothing
      stubReadings([]);
      final notifier = createNotifier();
      await notifier.sync();
      final stamped = container.read(healthSyncProvider).lastSyncTime;

      when(health.readableTypes(any)).thenAnswer((_) async => <HealthDataType>{});
      await notifier.sync();

      expect(container.read(healthSyncProvider).issue, HealthSyncIssue.permissionsMissing);
      expect(container.read(healthSyncProvider).lastSyncTime, stamped);
    });

    test('carries the imported count into the state', () async {
      stubReadings([
        HealthReading(
          type: HealthDataType.HEIGHT,
          value: 1.8,
          date: DateTime(2026, 1, 2),
          externalId: _idH1,
        ),
      ]);

      await createNotifier().sync();

      expect(container.read(healthSyncProvider).lastSyncCount, 1);
    });
  });

  group('syncIfDue', () {
    test('runs when nothing was imported yet', () async {
      stubReadings([]);

      await createNotifier().syncIfDue();

      verify(health.readableTypes(any)).called(1);
    });

    test('skips a run that follows a completed one', () async {
      // Every run re-reads a month of platform records per metric, so the app
      // being restarted twice in a row must not read it twice
      stubReadings([]);
      final notifier = createNotifier();
      await notifier.sync();

      await notifier.syncIfDue();

      verify(health.readableTypes(any)).called(1);
    });

    test('runs again once the pause is over', () async {
      stubReadings([]);
      final notifier = createNotifier();
      await notifier.sync();
      await PreferenceHelper.instance.setHealthSyncLastRun(
        DateTime.now().subtract(const Duration(hours: 1)),
      );

      await notifier.syncIfDue();

      verify(health.readableTypes(any)).called(2);
    });

    test('skips after a restart, since the last run is persisted', () async {
      // The timestamp only lived in the notifier state before, so a cold start
      // always read the full overlap window again
      stubReadings([]);
      await createNotifier().sync();

      await createNotifier().syncIfDue();

      verify(health.readableTypes(any)).called(1);
    });
  });
}
