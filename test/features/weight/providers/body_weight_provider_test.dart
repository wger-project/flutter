/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 - 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
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
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/weight/providers/body_weight_provider.dart';

import '../../../../test_data/body_weight.dart';
import '../../../../test_data/measurements.dart';
import 'body_weight_provider_test.mocks.dart';

@GenerateMocks([MeasurementRepository])
void main() {
  late MockMeasurementRepository mockRepo;
  late ProviderContainer container;

  ProviderContainer buildContainer(List<MeasurementCategory> categories) {
    when(mockRepo.watchAll()).thenAnswer((_) => Stream.value(categories));
    return ProviderContainer.test(
      overrides: [measurementRepositoryProvider.overrideWithValue(mockRepo)],
    );
  }

  setUp(() {
    mockRepo = MockMeasurementRepository();
  });

  test('selects the official body weight category', () async {
    // A user-created category with the same metric type must not shadow the
    // official one.
    final lookalike = MeasurementCategory(
      id: 'custom',
      name: 'My weight',
      unit: 'kg',
      metricType: MetricType.bodyWeight,
    );
    container = buildContainer([lookalike, ...getMeasurementCategories(), getBodyWeightCategory()]);
    container.listen(bodyWeightCategoryProvider, (_, _) {});
    await pumpEventQueue();

    final category = container.read(bodyWeightCategoryProvider).value;
    expect(category?.id, testBodyWeightCategoryId);
    expect(category?.entries, [testWeightEntry2, testWeightEntry1]);
  });

  test('is null while no official category has been synced', () async {
    container = buildContainer(getMeasurementCategories());
    container.listen(bodyWeightCategoryProvider, (_, _) {});
    await pumpEventQueue();

    final async = container.read(bodyWeightCategoryProvider);
    expect(async.hasValue, isTrue);
    expect(async.value, isNull);
  });
}
