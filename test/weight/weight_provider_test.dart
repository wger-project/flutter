/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/body_weight_repository.dart';

import 'weight_provider_test.mocks.dart';

@GenerateMocks([BodyWeightRepository])
void main() {
  late MockBodyWeightRepository mockBodyWeightRepository;
  late ProviderContainer container;

  setUp(() {
    mockBodyWeightRepository = MockBodyWeightRepository();
    when(mockBodyWeightRepository.watchAllDrift()).thenAnswer((_) => Stream.value(<WeightEntry>[]));
    when(mockBodyWeightRepository.deleteLocalDrift(any)).thenAnswer((_) async {});
    when(mockBodyWeightRepository.updateLocalDrift(any)).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [bodyWeightRepositoryProvider.overrideWithValue(mockBodyWeightRepository)],
    );
    addTearDown(container.dispose);
  });

  group('test body weight provider', () {
    test('deleteEntry correctly calls repository.deleteLocalDrift', () async {
      final notifier = container.read(weightEntryProvider().notifier);

      await notifier.deleteEntry('123');
      verify(mockBodyWeightRepository.deleteLocalDrift('123')).called(1);
    });

    test('updateEntry correctly calls repository.updateLocalDrift', () async {
      final notifier = container.read(weightEntryProvider().notifier);
      final entry = WeightEntry(id: '123', date: DateTime.now(), weight: 70.0);

      await notifier.updateEntry(entry);
      verify(mockBodyWeightRepository.updateLocalDrift(entry)).called(1);
    });
  });
}
