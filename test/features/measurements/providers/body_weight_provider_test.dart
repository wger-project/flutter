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
import 'package:wger/features/measurements/providers/body_weight_provider.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

import '../../../../test_data/body_weight.dart';
import 'body_weight_provider_test.mocks.dart';

@GenerateMocks([MeasurementRepository])
void main() {
  late MockMeasurementRepository mockRepo;
  late ProviderContainer container;

  ProviderContainer buildContainer(MeasurementCategory? category) {
    when(
      mockRepo.watchOfficialBodyWeightCategory(),
    ).thenAnswer((_) => Stream.value(category));
    return ProviderContainer.test(
      overrides: [measurementRepositoryProvider.overrideWithValue(mockRepo)],
    );
  }

  setUp(() {
    mockRepo = MockMeasurementRepository();
  });

  test('exposes the official body weight category', () async {
    container = buildContainer(getBodyWeightCategory());
    container.listen(bodyWeightCategoryOnlyProvider, (_, _) {});
    await pumpEventQueue();

    expect(container.read(bodyWeightCategoryOnlyProvider).value?.id, testBodyWeightCategoryId);
  });

  test('is null while no official category has been synced', () async {
    container = buildContainer(null);
    container.listen(bodyWeightCategoryOnlyProvider, (_, _) {});
    await pumpEventQueue();

    final async = container.read(bodyWeightCategoryOnlyProvider);
    expect(async.hasValue, isTrue);
    expect(async.value, isNull);
  });

  test('asks the repository for one category instead of for all of them', () async {
    // Reading every category and keeping one made any other category's entry
    // rebuild the weight screen, and the sync writes five sleep rows a night
    container = buildContainer(getBodyWeightCategory());
    container.listen(bodyWeightCategoryOnlyProvider, (_, _) {});
    await pumpEventQueue();

    verify(mockRepo.watchOfficialBodyWeightCategory()).called(1);
    verifyNever(mockRepo.watchAllWithoutEntries());
  });
}
