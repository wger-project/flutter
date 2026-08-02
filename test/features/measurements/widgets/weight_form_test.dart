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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/weight_form.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/body_weight.dart';
import '../../../../test_data/profile.dart';
import 'weight_form_test.mocks.dart';

@GenerateMocks([MeasurementRepository, UserProfileRepository])
void main() {
  late MockMeasurementRepository mockRepo;
  late MockUserProfileRepository mockProfileRepo;

  setUp(() {
    mockRepo = MockMeasurementRepository();
    when(mockRepo.watchAll()).thenAnswer((_) => Stream.value(<MeasurementCategory>[]));
    when(mockRepo.addLocalDrift(any)).thenAnswer((_) async {});
    when(mockRepo.updateLocalDrift(any)).thenAnswer((_) async {});

    mockProfileRepo = MockUserProfileRepository();
    when(mockProfileRepo.watchDrift()).thenAnswer((_) => Stream.value(tUserProfile1));
  });

  Widget createWeightForm({
    locale = 'en',
    MeasurementEntry? entry,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockRepo),
        userProfileRepositoryProvider.overrideWithValue(mockProfileRepo),
        ...overrides,
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: WeightForm(getBodyWeightCategory(const []), entry)),
        ),
      ),
    );
  }

  testWidgets('Correctly prefills and localizes the data - en', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm(entry: testWeightEntry1));
    await tester.pumpAndSettle();

    expect(find.text('1/1/2021'), findsOneWidget);
    expect(find.text('3:30 PM'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
  });

  testWidgets('Correctly prefills and localizes the data - de', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm(entry: testWeightEntry1, locale: 'de'));
    await tester.pumpAndSettle();

    expect(find.text('1.1.2021'), findsOneWidget);
    expect(find.text('15:30'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
  });

  testWidgets('It is possible to quick-change the weight', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm(entry: testWeightEntry1));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quickMinus')));
    expect(find.text('79'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quickMinusSmall')));
    expect(find.text('78.9'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quickPlus')));
    expect(find.text('79.9'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quickPlusSmall')));
    expect(find.text('80'), findsOneWidget);
  });

  testWidgets('Non-numeric input never reaches the field', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm(entry: testWeightEntry1));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('weightInput')), 'shiba inu');
    await tester.pumpAndSettle();
    expect(find.text('shiba inu'), findsNothing);

    // Quick-change still works on the now-empty field
    await tester.tap(find.byKey(const Key('quickMinus')));
    await tester.pumpAndSettle();
    expect(find.text('shiba inu'), findsNothing);
  });

  testWidgets('Accepts a dot as decimal separator in the de locale', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm(locale: 'de'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('weightInput')), '81.5');
    await tester.pumpAndSettle();

    expect(find.text('81,5'), findsOneWidget);
  });

  testWidgets('Widget works if there is no last entry', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm());
    await tester.pumpAndSettle();
  });

  testWidgets('Saving keeps an afternoon (PM) time intact', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm(entry: testWeightEntry1));
    await tester.pumpAndSettle();

    // The stored 15:30 renders as a PM time in a 12-hour locale
    expect(find.text('3:30 PM'), findsOneWidget);

    // Save without changing anything
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
    await tester.pumpAndSettle();

    final saved = verify(mockRepo.updateLocalDrift(captureAny)).captured.single as MeasurementEntry;
    expect(saved.categoryId, testBodyWeightCategoryId);
    expect(saved.date.hour, 15);
    expect(saved.date.minute, 30);
  });

  group('units', () {
    testWidgets('New entries default to the profile unit and stamp it on save', (
      WidgetTester tester,
    ) async {
      when(
        mockProfileRepo.watchDrift(),
      ).thenAnswer((_) => Stream.value(UserProfile(id: 1, weightUnitStr: 'lb')));

      // The form reads the profile once on creation, so it must already be
      // loaded, as it always is when the form is reachable in the app
      final container = ProviderContainer.test(
        overrides: [
          measurementRepositoryProvider.overrideWithValue(mockRepo),
          userProfileRepositoryProvider.overrideWithValue(mockProfileRepo),
        ],
      );
      container.listen(userProfileProvider, (_, _) {});
      // pumpEventQueue relies on timers, which testWidgets' fake async only
      // fires via the tester; run it on the real event loop instead
      await tester.runAsync(pumpEventQueue);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: WeightForm(getBodyWeightCategory(const [])),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('lb'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('weightInput')), '180');
      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      final saved = verify(mockRepo.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      // The value is stored as entered, in the entered unit
      expect(saved.value, 180);
      expect(saved.extraData, {'unit': 'lb'});
    });

    testWidgets('Accepts imperial weights over the metric bound', (WidgetTester tester) async {
      when(
        mockProfileRepo.watchDrift(),
      ).thenAnswer((_) => Stream.value(UserProfile(id: 1, weightUnitStr: 'lb')));

      final container = ProviderContainer.test(
        overrides: [
          measurementRepositoryProvider.overrideWithValue(mockRepo),
          userProfileRepositoryProvider.overrideWithValue(mockProfileRepo),
        ],
      );
      container.listen(userProfileProvider, (_, _) {});
      await tester.runAsync(pumpEventQueue);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: WeightForm(getBodyWeightCategory(const [])),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 365 lb are over the numeric kg bound but a perfectly valid weight
      await tester.enterText(find.byKey(const Key('weightInput')), '400');
      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      final saved = verify(mockRepo.addLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(saved.value, 400);
      expect(saved.extraData, {'unit': 'lb'});
    });

    testWidgets('Rejects implausible weights with bounds in the entered unit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWeightForm(entry: testWeightEntryLb));
      await tester.pumpAndSettle();

      // 35 lb are below the plausible minimum
      await tester.enterText(find.byKey(const Key('weightInput')), '35');
      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      verifyNever(mockRepo.updateLocalDrift(any));
      expect(find.text('Please enter a value between 44 and 770'), findsOneWidget);
    });

    testWidgets('Editing shows the stored value in its stored unit, unconverted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWeightForm(entry: testWeightEntryLb));
      await tester.pumpAndSettle();

      expect(find.text('176.4'), findsOneWidget);
      expect(find.text('lb'), findsOneWidget);
    });

    testWidgets('Switching the unit stamps the new unit on save', (WidgetTester tester) async {
      await tester.pumpWidget(createWeightForm(entry: testWeightEntry1));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('unitInput')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('lb').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.updateLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(saved.extraData, {'unit': 'lb'});
      // The typed value itself is not converted, only re-interpreted
      expect(saved.value, 80);
    });
  });
}
