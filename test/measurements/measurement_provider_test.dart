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
import 'package:wger/providers/measurement_notifier.dart';
import 'package:wger/providers/measurement_repository.dart';

import '../../test_data/measurements.dart';
import 'measurement_provider_test.mocks.dart';

@GenerateMocks([MeasurementRepository])
void main() {
  late MockMeasurementRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockMeasurementRepository();

    // Default stubs
    when(mockRepo.watchAll()).thenAnswer((_) => Stream.value([]));
    when(mockRepo.deleteLocalDrift(any)).thenAnswer((_) async {});
    when(mockRepo.updateLocalDrift(any)).thenAnswer((_) async {});
    when(mockRepo.addLocalDrift(any)).thenAnswer((_) async {});

    when(mockRepo.deleteLocalDriftCategory(any)).thenAnswer((_) async {});
    when(mockRepo.updateLocalDriftCategory(any)).thenAnswer((_) async {});
    when(mockRepo.addLocalDriftCategory(any)).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockRepo),
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

    test('build watches repository stream', () async {
      container.read(measurementProvider);

      verify(mockRepo.watchAll()).called(1);
    });
  });
}
