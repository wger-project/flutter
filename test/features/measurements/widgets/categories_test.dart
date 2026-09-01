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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/app_settings_notifier.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/categories.dart';
import 'package:wger/features/measurements/widgets/categories_card.dart';
import 'package:wger/features/measurements/widgets/measurement_tile.dart';
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
      // A fresh accessor per test: the app-wide singleton keeps the
      // in-memory store of the first test alive across the file
      appSettingsPrefsProvider.overrideWithValue(SharedPreferencesAsync()),
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
    // The shared chart range hydrates from SharedPreferences on first read
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    mockRepo = MockMeasurementRepository();
  });

  group('CategoriesList', () {
    testWidgets('two top-level categories render two grid tiles', (tester) async {
      stubMeasurementReads(mockRepo, getMeasurementCategories(), getMeasurementEntries());

      await tester.pumpWidget(
        _wrap(
          mockRepo,
          categories: getMeasurementCategories(),
          entries: getMeasurementEntries(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementTile), findsNWidgets(2));
    });

    testWidgets('children of multi-value groups are not rendered as own tiles', (
      tester,
    ) async {
      // Only 'bp' should produce a tile; the components live behind it.
      stubMeasurementReads(mockRepo, getBloodPressureGroup(), getBloodPressureEntries());

      await tester.pumpWidget(
        _wrap(
          mockRepo,
          categories: getBloodPressureGroup(),
          entries: getBloodPressureEntries(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementTile), findsOneWidget);
      expect(find.text('Blood pressure'), findsOneWidget);
    });

    testWidgets('body weight keeps its full card on top of the grid', (tester) async {
      // The card is the way into the weight screen and stays a card, the one
      // format decision the grid does not touch
      final categories = [...getMeasurementCategories(), getBodyWeightCategory()];
      final entries = {...getMeasurementEntries(), ...bodyWeightEntries()};
      stubMeasurementReads(mockRepo, categories, entries);
      // Tall enough for the card and the grid together
      tester.view.physicalSize = const Size(800, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(mockRepo, categories: categories, entries: entries));
      await tester.pumpAndSettle();

      // Once, on top: the official category is left out of the grid below
      expect(find.byType(CategoriesCard), findsOneWidget);
      expect(find.byType(MeasurementTile), findsNWidgets(2));
      expect(find.text('Weight'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Weight')).dy,
        lessThan(tester.getTopLeft(find.text('Body fat')).dy),
      );
    });

    testWidgets('empty list renders neither card nor tiles', (tester) async {
      stubMeasurementReads(mockRepo, []);

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesCard), findsNothing);
      expect(find.byType(MeasurementTile), findsNothing);
    });
  });
}
