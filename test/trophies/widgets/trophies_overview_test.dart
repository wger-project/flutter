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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:wger/providers/trophies.dart';
import 'package:wger/widgets/trophies/trophies_overview.dart';

import '../../test_data/trophies.dart';
import 'dashboard_trophies_widget_test.mocks.dart';

@GenerateMocks([TrophyRepository])
void main() {
  testWidgets('TrophiesOverview shows trophies', (WidgetTester tester) async {
    // Arrange
    final mockRepository = MockTrophyRepository();
    when(
      mockRepository.fetchProgression(
        filterQuery: anyNamed('filterQuery'),
        language: anyNamed('language'),
      ),
    ).thenAnswer((_) async => getUserTrophyProgression());

    // Act
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trophyRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TrophiesOverview()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('New Year, New Me'), findsOneWidget);
      expect(find.text('Work out on January 1st'), findsOneWidget);

      expect(find.text('Unstoppable'), findsOneWidget);
      expect(find.text('Maintain a 30-day workout streak'), findsOneWidget);
    });
  });
}
