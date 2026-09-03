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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/charts/overall_change.dart';
import 'package:wger/features/nutrition/models/nutritional_plan.dart';
import 'package:wger/features/nutrition/widgets/plan_weight_chart.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/body_weight.dart';
import '../../../../test_data/profile.dart';
import '../../../helpers/measurement_repository_stubs.dart';
import 'plan_weight_chart_test.mocks.dart';

@GenerateMocks([MeasurementRepository, UserProfileRepository])
void main() {
  late MockMeasurementRepository mockMeasurementRepo;
  late MockUserProfileRepository mockUserProfileRepo;

  setUp(() {
    mockMeasurementRepo = MockMeasurementRepository();
    // The chart reads the official category and its points through their own
    // queries, not the whole list
    stubMeasurementReads(
      mockMeasurementRepo,
      [getBodyWeightCategory()],
      bodyWeightEntries([testWeightEntry2, testWeightEntry1, testWeightEntryLb]),
    );

    mockUserProfileRepo = MockUserProfileRepository();
    when(mockUserProfileRepo.watchDrift()).thenAnswer((_) => Stream.value(tUserProfile1));
  });

  Future<void> pumpChart(WidgetTester tester, NutritionalPlan plan) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          measurementRepositoryProvider.overrideWithValue(mockMeasurementRepo),
          userProfileRepositoryProvider.overrideWithValue(mockUserProfileRepo),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: PlanWeightChart(plan))),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the readings of the plan period', (tester) async {
    // Two of the three entries fall into the period; the january 20th one is
    // after the end and must not be drawn
    await pumpChart(
      tester,
      NutritionalPlan(
        description: 'Cut',
        startDate: DateTime(2021, 1, 1),
        endDate: DateTime(2021, 1, 15),
      ),
    );

    expect(find.text('Weight'), findsOneWidget);
    expect(find.byType(MeasurementOverallChangeWidget), findsOneWidget);
    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    expect(data.lineBarsData.first.spots, hasLength(2));
  });

  testWidgets('an open-ended plan includes everything since its start', (tester) async {
    await pumpChart(
      tester,
      NutritionalPlan(description: 'Bulk', startDate: DateTime(2021, 1, 1)),
    );

    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    expect(data.lineBarsData.first.spots, hasLength(3));
  });

  testWidgets('hidden when fewer than two readings fall into the period', (tester) async {
    await pumpChart(
      tester,
      NutritionalPlan(
        description: 'Cut',
        startDate: DateTime(2021, 1, 5),
        endDate: DateTime(2021, 1, 15),
      ),
    );

    expect(find.byType(LineChart), findsNothing);
    expect(find.text('Weight'), findsNothing);
  });
}
