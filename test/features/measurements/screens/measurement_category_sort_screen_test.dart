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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/screens/measurement_category_sort_screen.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/measurements.dart';
import 'measurement_category_sort_screen_test.mocks.dart';

@GenerateMocks([MeasurementRepository])
void main() {
  late MockMeasurementRepository mockRepo;

  // Three top-level categories: Body fat ('1'), Biceps ('2') and the blood
  // pressure group parent ('bp'); its children must not be listed.
  final categories = [
    ...getMeasurementCategories(),
    ...getBloodPressureGroup(),
  ];

  setUp(() {
    mockRepo = MockMeasurementRepository();
    when(mockRepo.watchAll()).thenAnswer((_) => Stream.value(categories));
    when(mockRepo.reorderCategories(any)).thenAnswer((_) async {});
  });

  Widget createSortScreen() {
    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MeasurementCategorySortScreen(),
      ),
    );
  }

  testWidgets('lists only top-level categories', (tester) async {
    await tester.pumpWidget(createSortScreen());
    await tester.pumpAndSettle();

    expect(find.text('Body fat'), findsOneWidget);
    expect(find.text('Biceps'), findsOneWidget);
    expect(find.text('Blood pressure'), findsOneWidget);
    expect(find.text('Systolic'), findsNothing);
    expect(find.text('Diastolic'), findsNothing);
    expect(find.byIcon(Icons.drag_handle), findsNWidgets(3));
  });

  testWidgets('dragging an item to the bottom persists the new order', (tester) async {
    await tester.pumpWidget(createSortScreen());
    await tester.pumpAndSettle();

    final firstHandle = find.byIcon(Icons.drag_handle).first;
    final itemHeight = tester.getSize(find.byType(ListTile).first).height;
    await tester.timedDrag(
      firstHandle,
      Offset(0, itemHeight * 3),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    verify(mockRepo.reorderCategories(['2', 'bp', '1'])).called(1);
  });
}
