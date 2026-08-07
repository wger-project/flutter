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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/categories.dart';
import 'package:wger/features/measurements/widgets/categories_card.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/body_weight.dart';
import '../../../../test_data/measurements.dart';
import '../../../../test_data/profile.dart';
import '../../../helpers/measurement_chart_buckets.dart';
import '../../../helpers/measurement_repository_stubs.dart';
import 'categories_test.mocks.dart';

Widget _wrap(
  MockMeasurementRepository mockRepo, {
  List<MeasurementCategory> categories = const [],
  Map<String, List<MeasurementEntry>> entries = const {},
}) {
  // The weight card needs the display unit, so it only appears once the
  // profile is there
  final mockProfileRepo = MockUserProfileRepository();
  when(mockProfileRepo.watchDrift()).thenAnswer((_) => Stream.value(tUserProfile1));

  return ProviderScope(
    overrides: [
      measurementRepositoryProvider.overrideWithValue(mockRepo),
      userProfileRepositoryProvider.overrideWithValue(mockProfileRepo),
      // The cards read their chart points from the aggregated queries
      measurementChartBucketsProvider.overrideWith(chartBucketsFrom(entries)),
      measurementGroupBucketsProvider.overrideWith(groupBucketsFrom(categories, entries)),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: CategoriesList()),
    ),
  );
}

@GenerateMocks([MeasurementRepository, UserProfileRepository])
void main() {
  late MockMeasurementRepository mockRepo;

  setUp(() {
    mockRepo = MockMeasurementRepository();
  });

  group('CategoriesList', () {
    testWidgets('two top-level categories render two CategoriesCard widgets', (tester) async {
      stubMeasurementReads(mockRepo, getMeasurementCategories(), getMeasurementEntries());

      await tester.pumpWidget(
        _wrap(
          mockRepo,
          categories: getMeasurementCategories(),
          entries: getMeasurementEntries(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesCard), findsNWidgets(2));
    });

    testWidgets('children of multi-value groups are not rendered as own list items', (
      tester,
    ) async {
      // Only 'bp' should produce a CategoriesCard; children stay inside it.
      stubMeasurementReads(mockRepo, getBloodPressureGroup(), getBloodPressureEntries());

      await tester.pumpWidget(
        _wrap(
          mockRepo,
          categories: getBloodPressureGroup(),
          entries: getBloodPressureEntries(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesCard), findsOneWidget);
      expect(find.text('Systolic'), findsOneWidget);
      expect(find.text('Diastolic'), findsOneWidget);
    });

    testWidgets('body weight leads the list, wherever it is sorted', (tester) async {
      // The card is the way into the weight screen, so it stays on top rather
      // than taking the position the category order gives it
      final categories = [...getMeasurementCategories(), getBodyWeightCategory()];
      final entries = {...getMeasurementEntries(), ...bodyWeightEntries()};
      stubMeasurementReads(mockRepo, categories, entries);
      // Tall enough for all three cards; the list builds only what it shows
      tester.view.physicalSize = const Size(800, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(mockRepo, categories: categories, entries: entries));
      await tester.pumpAndSettle();

      // Once, at the top: the official category is left out of the list below
      expect(find.byType(CategoriesCard), findsNWidgets(3));
      expect(find.text('Weight'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Weight')).dy,
        lessThan(tester.getTopLeft(find.text('Body fat')).dy),
      );
    });

    testWidgets('empty list renders no CategoriesCard', (tester) async {
      stubMeasurementReads(mockRepo, []);

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesCard), findsNothing);
    });
  });
}
