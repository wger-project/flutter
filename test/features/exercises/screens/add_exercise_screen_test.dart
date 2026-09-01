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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/language.dart';
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/features/account/models/account.dart';
import 'package:wger/features/account/providers/account_repository.dart';
import 'package:wger/features/exercises/models/category.dart';
import 'package:wger/features/exercises/models/equipment.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/exercises/models/muscle.dart';
import 'package:wger/features/exercises/providers/add_exercise_repository.dart';
import 'package:wger/features/exercises/providers/exercise_repository.dart';
import 'package:wger/features/exercises/providers/exercises_notifier.dart';
import 'package:wger/features/exercises/screens/add_exercise_screen.dart';
import 'package:wger/features/exercises/widgets/add_exercise/steps/step_1_basics.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/exercises.dart';
import '../../../helpers/fake_connectivity.dart';
import 'add_exercise_screen_test.mocks.dart';

/// Test suite for the exercise-contribution screen.
///
@GenerateMocks([AddExerciseRepository, AccountRepository, ExerciseRepository])
void main() {
  installFakeConnectivity();

  late MockAddExerciseRepository mockAddExerciseRepository;
  late MockAccountRepository mockAccountRepository;
  late MockExerciseRepository mockExerciseRepository;

  setUp(() {
    mockAddExerciseRepository = MockAddExerciseRepository();
    mockAccountRepository = MockAccountRepository();
    mockExerciseRepository = MockExerciseRepository();
    when(
      mockExerciseRepository.watchAllDrift(),
    ).thenAnswer((_) => Stream.value(ExerciseState(const <Exercise>[])));
  });

  /// Stubs the account fetch so the contribution gate sees a (non-)trustworthy
  /// user. The screen branches on [Account.isTrustworthy].
  void setTrustworthy(bool value) {
    when(mockAccountRepository.fetchAccount()).thenAnswer(
      (_) async => Account(
        username: 'test',
        email: 'test@example.com',
        emailVerified: value,
        isTrustworthy: value,
      ),
    );
  }

  Widget createExerciseScreen({locale = 'en', bool isOnline = true}) {
    return ProviderScope(
      overrides: [
        // Seeded, not empty: the mandatory category and language pickers have
        // to be selectable or the wizard cannot be walked to the last step
        languagesProvider.overrideWith((ref) => Stream<List<Language>>.value(testLanguages)),
        exerciseRepositoryProvider.overrideWithValue(mockExerciseRepository),
        exerciseMusclesProvider.overrideWith(
          (ref) => Stream<List<Muscle>>.value(const [tMuscle1, tMuscle2]),
        ),
        exerciseCategoriesProvider.overrideWith(
          (ref) => Stream<List<ExerciseCategory>>.value(const [testCategoryArms]),
        ),
        exerciseEquipmentProvider.overrideWith(
          (ref) => Stream<List<Equipment>>.value(<Equipment>[]),
        ),
        accountRepositoryProvider.overrideWithValue(mockAccountRepository),
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

  int currentStep(WidgetTester tester) => tester.widget<Stepper>(find.byType(Stepper)).currentStep;

  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(Stepper)));

  Future<void> tapNext(WidgetTester tester) async {
    final next = find.widgetWithText(ElevatedButton, l10nOf(tester).next).first;
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
  }

  Future<void> tapPrevious(WidgetTester tester) async {
    final previous = find.widgetWithText(OutlinedButton, l10nOf(tester).previous).first;
    await tester.ensureVisible(previous);
    await tester.pumpAndSettle();
    await tester.tap(previous);
    await tester.pumpAndSettle();
  }

  /// Picks the single entry of a seeded dropdown.
  Future<void> pickFromDropdown(WidgetTester tester, Key key, String entry) async {
    // The key sits on the wrapper as well as on the DropdownButtonFormField
    final dropdown = find.byKey(key).first;
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(entry).last);
    await tester.pumpAndSettle();
  }

  /// All steps are built at once, so fields are addressed inside their step.
  Finder fieldOf(Type step, int index) =>
      find.descendant(of: find.byType(step), matching: find.byType(TextFormField)).at(index);

  /// Fills the mandatory fields of the first step (name, author, category).
  Future<void> fillBasics(WidgetTester tester, {String name = 'Bench Press'}) async {
    await tester.enterText(fieldOf(Step1Basics, 0), name);
    await tester.enterText(fieldOf(Step1Basics, 2), 'Alice');
    await tester.pumpAndSettle();
    await pickFromDropdown(tester, const Key('category-dropdown'), testCategoryArms.name);
  }

  // --------------------------------------------------------------------------
  // Form Field Validation Tests
  // --------------------------------------------------------------------------

  group('Form Field Validation Tests', () {
    testWidgets('Exercise name field is required and displays validation error', (tester) async {
      setTrustworthy(true);
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
      setTrustworthy(true);
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).first;
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Bench Press');
      await tester.pump();

      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('Alternative names field accepts multiple lines of text', (tester) async {
      setTrustworthy(true);
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);

      final alternativeNamesField = textFields.at(1);
      await tester.enterText(alternativeNamesField, 'Chest Press\nFlat Bench Press');
      await tester.pump();

      expect(find.text('Chest Press\nFlat Bench Press'), findsOneWidget);
    });

    testWidgets('Category dropdown is required for form submission', (tester) async {
      setTrustworthy(true);
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Exercise');
      await tester.pump();

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
      setTrustworthy(true);
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      await fillBasics(tester, name: 'Test Exercise');
      await tapNext(tester);
      expect(currentStep(tester), 1, reason: 'the first step is complete and lets us pass');

      await tapPrevious(tester);

      expect(currentStep(tester), 0);
      expect(find.text('Test Exercise'), findsOneWidget);
    });

    testWidgets('Previous button navigates back to previous step', (tester) async {
      setTrustworthy(true);
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      await fillBasics(tester);
      await tapNext(tester);
      expect(currentStep(tester), 1);

      await tapPrevious(tester);

      expect(currentStep(tester), 0);
    });
  });

  // --------------------------------------------------------------------------
  // Dropdown Selection Tests
  // --------------------------------------------------------------------------

  group('Dropdown Selection Tests', () {
    testWidgets('Category selection widgets exist in form', (tester) async {
      setTrustworthy(true);
      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AddExerciseStepper), findsOneWidget);
      expect(find.byType(Stepper), findsOneWidget);

      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      expect(stepper.steps.length, equals(6));
      expect(stepper.steps[0].content.runtimeType.toString(), contains('Step1Basics'));
    });

    testWidgets('Form contains multiple selection fields', (tester) async {
      setTrustworthy(true);
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

  // Not covered here: submitting from the last step. The stepper has no seam
  // to reach it (onStepTapped is commented out) and walking all six steps in a
  // widget test proved unreliable. The two tests that used to sit here only
  // asserted `steps.length == 6` after stubbing submit(), so they never
  // submitted anything. The error path and the fallback name of the success
  // dialog (the exercise is not in the local DB yet when it is shown) are
  // therefore still untested at screen level; postExerciseToServer itself is
  // covered in add_exercise_notifier_test.dart.

  // --------------------------------------------------------------------------
  // Access Control Tests
  // --------------------------------------------------------------------------

  group('Access Control Tests', () {
    testWidgets('Unverified users cannot access exercise form', (tester) async {
      setTrustworthy(false);

      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      expect(find.byType(EmailNotVerified), findsOneWidget);
      expect(find.byType(AddExerciseStepper), findsNothing);
      expect(find.byType(Stepper), findsNothing);
    });

    testWidgets('Verified users can access all form fields', (tester) async {
      setTrustworthy(true);

      await tester.pumpWidget(createExerciseScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AddExerciseStepper), findsOneWidget);
      expect(find.byType(Stepper), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);

      final stepper = tester.widget<Stepper>(find.byType(Stepper));
      expect(stepper.steps.length, equals(6));
    });

    testWidgets('Email verification warning displays correct message', (tester) async {
      setTrustworthy(false);

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
      setTrustworthy(true);
      await tester.pumpWidget(createExerciseScreen(isOnline: false));
      await tester.pumpAndSettle();

      // The cloud-off icon is the give-away that the placeholder is shown
      // (the wizard would render a Stepper instead).
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.byType(Stepper), findsNothing);
    });

    testWidgets('Wizard is shown when online', (tester) async {
      setTrustworthy(true);
      await tester.pumpWidget(createExerciseScreen(isOnline: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off), findsNothing);
      expect(find.byType(Stepper), findsOneWidget);
    });
  });
}
