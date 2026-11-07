/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/network/auth_credentials_storage.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

import '../../../../test_data/measurements.dart';
import 'measurement_notifier_test.mocks.dart';

@GenerateMocks([MeasurementRepository, AuthCredentialsStorage])
void main() {
  late MockMeasurementRepository mockRepo;
  late MockAuthCredentialsStorage mockCredentials;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockMeasurementRepository();
    mockCredentials = MockAuthCredentialsStorage();
    when(mockCredentials.dbOwnerUserId()).thenAnswer((_) async => '2');

    // Default stubs
    when(mockRepo.deleteLocalDrift(any)).thenAnswer((_) async {});
    when(mockRepo.updateLocalDrift(any)).thenAnswer((_) async {});
    when(mockRepo.addLocalDrift(any)).thenAnswer((_) async {});

    when(mockRepo.addLocalDriftGroupEntries(any)).thenAnswer((_) async {});

    when(mockRepo.deleteLocalDriftCategory(any)).thenAnswer((_) async {});
    when(mockRepo.updateLocalDriftCategory(any)).thenAnswer((_) async {});
    when(mockRepo.addLocalDriftCategory(any)).thenAnswer((_) async {});
    when(mockRepo.addLocalDriftCategoryGroup(any)).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockRepo),
        authCredentialsStorageProvider.overrideWithValue(mockCredentials),
      ],
    );
  });

  group('MeasurementProvider', () {
    // Entries
    test('deleteEntry calls repository', () async {
      final notifier = container.read(measurementProvider.notifier);
      await notifier.deleteEntry('123');
      verify(mockRepo.deleteLocalDrift('123')).called(1);
    });

    test('updateEntry calls repository', () async {
      final notifier = container.read(measurementProvider.notifier);

      await notifier.updateEntry(testMeasurementEntry1);
      verify(mockRepo.updateLocalDrift(testMeasurementEntry1)).called(1);
    });

    test('addEntry calls repository', () async {
      final notifier = container.read(measurementProvider.notifier);

      await notifier.addEntry(testMeasurementEntry1);
      verify(mockRepo.addLocalDrift(testMeasurementEntry1)).called(1);
    });

    // Categories
    test('deleteCategory calls repository', () async {
      final notifier = container.read(measurementProvider.notifier);
      await notifier.deleteCategory('cat1');
      verify(mockRepo.deleteLocalDriftCategory('cat1')).called(1);
    });

    test('updateCategory calls repository', () async {
      final notifier = container.read(measurementProvider.notifier);
      final category = getMeasurementCategories().first;

      await notifier.updateCategory(category);
      verify(mockRepo.updateLocalDriftCategory(category)).called(1);
    });

    test('addCategory calls repository', () async {
      final notifier = container.read(measurementProvider.notifier);
      final category = getMeasurementCategories().first;

      await notifier.addCategory(category);
      verify(mockRepo.addLocalDriftCategory(category)).called(1);
    });

    test('addCategory derives the id of a typed category', () async {
      final notifier = container.read(measurementProvider.notifier);

      await notifier.addCategory(
        MeasurementCategory(
          name: 'Steps',
          unit: 'count',
          metricType: MetricType.steps,
        ),
      );

      final added =
          verify(
                mockRepo.addLocalDriftCategoryGroup(captureAny),
              ).captured.single
              as List<MeasurementCategory>;
      expect(added.single.id, deterministicCategoryId('2', MetricType.steps));
    });

    test('addCategory creates a group with its components', () async {
      final notifier = container.read(measurementProvider.notifier);

      await notifier.addCategory(
        MeasurementCategory(
          name: 'Blood pressure',
          unit: 'mmHg',
          metricType: MetricType.bloodPressure,
        ),
      );

      final added =
          verify(
                mockRepo.addLocalDriftCategoryGroup(captureAny),
              ).captured.single
              as List<MeasurementCategory>;
      expect(
        added.map((c) => (c.metricType, c.name, c.order)),
        [
          (MetricType.bloodPressure, 'Blood pressure', 0),
          (MetricType.bloodPressureSystolic, 'Systolic', 0),
          (MetricType.bloodPressureDiastolic, 'Diastolic', 1),
        ],
      );
      expect(added.last.parentId, added.first.id);
      expect(added.last.id, deterministicCategoryId('2', MetricType.bloodPressureDiastolic));
    });

    test('the notifier reads nothing, it only writes', () async {
      // What the screens show is watched through the providers next to it;
      // instantiating the notifier to delete an entry must not start a read
      container.read(measurementProvider.notifier);

      verifyNever(mockRepo.watchAllWithoutEntries());
      verifyNever(mockRepo.watchLatestEntries());
    });
  });

  group('addGroupEntries', () {
    test('addGroupEntries calls repository', () async {
      final notifier = container.read(measurementProvider.notifier);
      final entries = [testNeasurementEntry9, testNeasurementEntry10];

      await notifier.addGroupEntries(entries);
      verify(mockRepo.addLocalDriftGroupEntries(entries)).called(1);
    });

    test('addGroupEntries forwards empty list to repository', () async {
      final notifier = container.read(measurementProvider.notifier);

      await notifier.addGroupEntries([]);
      verify(mockRepo.addLocalDriftGroupEntries([])).called(1);
    });
  });

  group('setCategoryOrder', () {
    // The list the sort screen shows: its top-level categories, in the order
    // they are drawn in. Which categories those are is the screen's business
    final categories = [
      ...getMeasurementCategories(),
      testMeasurementCategoryBloodPressure,
    ];

    setUp(() {
      when(mockRepo.reorderCategories(any)).thenAnswer((_) async {});
    });

    test('moves an item down (newIndex already adjusted, onReorderItem semantics)', () async {
      final notifier = container.read(measurementProvider.notifier);

      await notifier.setCategoryOrder(categories, 0, 2);
      verify(mockRepo.reorderCategories(['2', 'bp', '1'])).called(1);
    });

    test('moves an item up', () async {
      final notifier = container.read(measurementProvider.notifier);

      await notifier.setCategoryOrder(categories, 2, 0);
      verify(mockRepo.reorderCategories(['bp', '1', '2'])).called(1);
    });

    test('leaves the list it was given alone', () async {
      // It belongs to the screen, which rebuilds from the stream rather than
      // from a list reordered under it
      final notifier = container.read(measurementProvider.notifier);

      await notifier.setCategoryOrder(categories, 0, 2);
      expect(categories.map((c) => c.id), ['1', '2', 'bp']);
    });
  });
}
