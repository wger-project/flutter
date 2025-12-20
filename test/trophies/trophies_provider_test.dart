/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2025 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/trophies.dart';

import 'trophies_provider_test.mocks.dart';

const trophyJson = {
  'id': 1,
  'uuid': '550e8400-e29b-41d4-a716-446655440000',
  'name': 'First Steps',
  'description': 'Awarded for the first workout',
  'image': 'https://example.org/trophy.png',
  'trophy_type': 'count',
  'is_hidden': false,
  'is_progressive': true,
};

@GenerateMocks([WgerBaseProvider])
void main() {
  group('Trophy repository', () {
    test('fetches list of trophies', () async {
      // Arrange
      final mockBase = MockWgerBaseProvider();
      when(mockBase.fetchPaginated(any)).thenAnswer((_) async => [trophyJson]);
      when(
        mockBase.makeUrl(
          any,
          id: anyNamed('id'),
          objectMethod: anyNamed('objectMethod'),
          query: anyNamed('query'),
        ),
      ).thenReturn(Uri.parse('https://example.org/trophies'));
      final repository = TrophyRepository(mockBase);

      // Act
      final result = await repository.fetchTrophies();

      // Assert
      expect(result, isA<List>());
      expect(result, hasLength(1));
      final trophy = result.first;
      expect(trophy.id, 1);
      expect(trophy.name, 'First Steps');
      expect(trophy.type.toString(), contains('count'));
    });

    test('fetches list of user trophy progression', () async {
      // Arrange
      final progressionJson = {
        'trophy': trophyJson,
        'is_earned': true,
        'earned_at': '2020-01-02T15:04:05Z',
        'progress': 42.5,
        'current_value': '12.5',
        'target_value': '100',
        'progress_display': '12.5/100',
      };

      final mockBase = MockWgerBaseProvider();
      when(mockBase.fetchPaginated(any)).thenAnswer((_) async => [progressionJson]);
      when(
        mockBase.makeUrl(
          any,
          id: anyNamed('id'),
          objectMethod: anyNamed('objectMethod'),
          query: anyNamed('query'),
        ),
      ).thenReturn(Uri.parse('https://example.org/user_progressions'));
      final repository = TrophyRepository(mockBase);

      // Act
      final result = await repository.fetchProgression();

      // Assert
      expect(result, isA<List>());
      expect(result, hasLength(1));
      final p = result.first;
      expect(p.isEarned, isTrue);
      expect(p.progress, 42.5);
      expect(p.currentValue, 12.5);
      expect(p.progressDisplay, '12.5/100');

      verify(mockBase.fetchPaginated(any)).called(1);
    });
  });
}
