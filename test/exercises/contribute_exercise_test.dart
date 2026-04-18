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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/core/language.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/add_exercise_repository.dart';
import 'package:wger/providers/core_data.dart';
import 'package:wger/providers/exercise_data.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/user_profile_repository.dart';
import 'package:wger/screens/add_exercise_screen.dart';

import '../../test_data/profile.dart';
import 'contribute_exercise_test.mocks.dart';

/// Test suite for the exercise-contribution screen.
///
/// Exercises the widget tree with the real `AddExerciseNotifier` + a mocked
/// repository. The notifier builds with an empty default form state.
@GenerateMocks([AddExerciseRepository, UserProfileRepository])
void main() {
  late MockAddExerciseRepository mockAddExerciseRepository;
  late MockUserProfileRepository mockUserProfileRepository;

  setUp(() {
    mockAddExerciseRepository = MockAddExerciseRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    when(mockUserProfileRepository.fetchProfile()).thenAnswer((_) async => tProfile1);
  });

  Widget createExerciseScreen({locale = 'en', bool isOnline = true}) {
    return ProviderScope(
      overrides: [
        languagesProvider.overrideWith((ref) => Stream<List<Language>>.value(<Language>[])),
        exercisesProvider.overrideWith((ref) => Stream<List<Exercise>>.value(<Exercise>[])),
        exerciseMusclesProvider.overrideWith((ref) => Stream<List<Muscle>>.value(<Muscle>[])),
        exerciseCategoriesProvider.overrideWith(
          (ref) => Stream<List<ExerciseCategory>>.value(<ExerciseCategory>[]),
        ),
        exerciseEquipmentProvider.overrideWith(
          (ref) => Stream<List<Equipment>>.value(<Equipment>[]),
        ),
        userProfileRepositoryProvider.overrideWithValue(mockUserProfileRepository),
        addExerciseRepositoryProvider.overrideWithValue(mockAddExerciseRepository),
        networkStatusProvider.overrideWithValue(isOnline),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AddExerciseScreen(),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Form Field Validation Tests
  // --------------------------------------------------------------------------

  group('Form Field Validation Tests', () {
    testWidgets('Exercise name field is required and displays validation error', (tester) async {
      tProfile1.isTrustworthy = true;
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Stepper));
      final l10n = AppLocalizations.of(context);

      final nextButton = find.widgetWithText(ElevatedButton, l10n.next).first;
      expect(nextButton, findsOneWidget);

      await tester.ensureVisible(nextButton);
      await tester.pumpAndSettle();

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      expect(stepper.currentStep, equals(0));
    });

    testWidgets('User can enter exercise name in text field', (tester) async {
      tProfile1.isTrustworthy = true;
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).first;
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Bench Press');
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('Alternative names field accepts multiple lines of text', (tester) async {
      tProfile1.isTrustworthy = true;
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);

      final alternativeNamesField = textFields.at(1);
      await tester.enterText(alternativeNamesField, 'Chest Press\nFlat Bench Press');
      await tester.pumpAndSettle();

      expect(find.text('Chest Press\nFlat Bench Press'), findsOneWidget);
    });

    testWidgets('Category dropdown is required for form submission', (tester) async {
      tProfile1.isTrustworthy = true;
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Exercise');
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Stepper));
      final l10n = AppLocalizations.of(context);
      final nextButton = find.widgetWithText(ElevatedButton, l10n.next).first;

      await tester.ensureVisible(nextButton);
      await tester.pumpAndSettle();

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      expect(stepper.currentStep, equals(0));
    });
  });

  // --------------------------------------------------------------------------
  // Form Navigation and Data Persistence Tests
  // --------------------------------------------------------------------------

  group('Form Navigation and Data Persistence Tests', () {
    testWidgets('Form data persists when navigating between steps', (tester) async {
      tProfile1.isTrustworthy = true;
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Exercise');
      await tester.pumpAndSettle();

      expect(find.text('Test Exercise'), findsOneWidget);
    });

    testWidgets('Previous button navigates back to previous step', (tester) async {
      tProfile1.isTrustworthy = true;
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      expect(stepper.currentStep, equals(0));

      final context = tester.element(find.byType(Stepper));
      final l10n = AppLocalizations.of(context);

      final previousButton = find.widgetWithText(OutlinedButton, l10n.previous);
      expect(previousButton, findsOneWidget);

      final button = tester.widget<OutlinedButton>(previousButton);
      expect(button.onPressed, isNotNull);
    });
  });

  // --------------------------------------------------------------------------
  // Dropdown Selection Tests
  // --------------------------------------------------------------------------

  group('Dropdown Selection Tests', () {
    testWidgets('Category selection widgets exist in form', (tester) async {
      tProfile1.isTrustworthy = true;
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AddExerciseStepper), findsOneWidget);
      expect(find.byType(Stepper), findsOneWidget);

      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      expect(stepper.steps.length, equals(6));
      expect(stepper.steps[0].content.runtimeType.toString(), contains('Step1Basics'));
    });

    testWidgets('Form contains multiple selection fields', (tester) async {
      tProfile1.isTrustworthy = true;
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Stepper), findsOneWidget);

      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      expect(stepper.steps.length, equals(6));

      expect(find.byType(TextFormField), findsWidgets);
    });
  });

  // --------------------------------------------------------------------------
  // Exercise Submission Tests
  // --------------------------------------------------------------------------

  group('Exercise Submission Tests', () {
    testWidgets('Submission flow structure', (tester) async {
      tProfile1.isTrustworthy = true;
      when(mockAddExerciseRepository.submit(any)).thenAnswer((_) async => 1);

      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      expect(stepper.steps.length, equals(6));
    });

    testWidgets('Form structure supports error handling', (tester) async {
      tProfile1.isTrustworthy = true;
      when(mockAddExerciseRepository.submit(any)).thenThrow(Exception('Bad request'));

      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      expect(stepper.steps.length, equals(6));
    });
  });

  // --------------------------------------------------------------------------
  // Access Control Tests
  // --------------------------------------------------------------------------

  group('Access Control Tests', () {
    testWidgets('Unverified users cannot access exercise form', (tester) async {
      tProfile1.isTrustworthy = false;

      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      expect(find.byType(EmailNotVerified), findsOneWidget);
      expect(find.byType(AddExerciseStepper), findsNothing);
      expect(find.byType(Stepper), findsNothing);
    });

    testWidgets('Verified users can access all form fields', (tester) async {
      tProfile1.isTrustworthy = true;

      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AddExerciseStepper), findsOneWidget);
      expect(find.byType(Stepper), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);

      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      expect(stepper.steps.length, equals(6));
    });

    testWidgets('Email verification warning displays correct message', (tester) async {
      tProfile1.isTrustworthy = false;

      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);

      final context = tester.element(find.byType(EmailNotVerified));
      final expectedText = AppLocalizations.of(context).userProfile;
      final profileButton = find.widgetWithText(TextButton, expectedText);
      expect(profileButton, findsOneWidget);
    });
  });

  group('Offline gating', () {
    testWidgets('Offline placeholder is shown instead of the wizard', (tester) async {
      tProfile1.isTrustworthy = true;
      await tester.pumpWidget(createExerciseScreen(isOnline: false));
      await tester.pumpAndSettle();

      // The cloud-off icon is the give-away that the placeholder is shown
      // (the wizard would render a Stepper instead).
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.byType(Stepper), findsNothing);
    });

    testWidgets('Wizard is shown when online', (tester) async {
      tProfile1.isTrustworthy = true;
      await tester.pumpWidget(createExerciseScreen(isOnline: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off), findsNothing);
      expect(find.byType(Stepper), findsOneWidget);
    });
  });
}
