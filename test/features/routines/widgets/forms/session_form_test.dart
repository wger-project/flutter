import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/widgets/datetime_input.dart';
import 'package:wger/features/routines/models/session.dart';
import 'package:wger/features/routines/providers/workout_session_repository.dart';
import 'package:wger/features/routines/widgets/forms/session.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import 'session_form_test.mocks.dart';

@GenerateMocks([WorkoutSessionRepository])
void main() {
  late MockWorkoutSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkoutSessionRepository();
  });

  Future<void> pumpSessionForm(
    WidgetTester tester, {
    WorkoutSession? session,
    int routineId = 1,
    Function()? onSaved,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutSessionRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SessionForm(
              routineId,
              session: session,
              onSaved: onSaved,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('SessionForm', () {
    testWidgets('renders correctly for an existing session', (WidgetTester tester) async {
      //Arrange
      final existingSession = WorkoutSession(
        id: '1',
        routineId: 1,
        notes: 'Existing notes',
        impression: WorkoutImpression.bad,
        datetimeStart: DateTime.now().copyWith(hour: 10, minute: 0),
        datetimeEnd: DateTime.now().copyWith(hour: 11, minute: 0),
      );

      //Act
      await pumpSessionForm(tester, session: existingSession);

      //Assert
      expect(find.widgetWithText(TextFormField, 'Existing notes'), findsOneWidget);
      final toggleButtons = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
      expect(toggleButtons.isSelected, [true, false, false]); // Bad impression
      expect(find.widgetWithText(TextFormField, '10:00 AM'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '11:00 AM'), findsOneWidget);
    });

    testWidgets('saves a new session', (WidgetTester tester) async {
      // Arrange
      bool onSavedCalled = false;
      when(mockRepository.addLocalDrift(any)).thenAnswer(
        (inv) async => inv.positionalArguments.first as WorkoutSession,
      );
      await pumpSessionForm(tester, onSaved: () => onSavedCalled = true);

      // Act
      await tester.enterText(find.widgetWithText(TextFormField, 'Notes'), 'New session notes');
      await tester.tap(find.byKey(const ValueKey('save-button')));
      await tester.pumpAndSettle();

      // Assert
      verify(mockRepository.addLocalDrift(any)).called(1);
      expect(onSavedCalled, isTrue);
    });

    testWidgets('saves an existing session', (WidgetTester tester) async {
      // Arrange
      bool onSavedCalled = false;
      final existingSession = WorkoutSession(
        id: '1',
        routineId: 1,
        notes: 'Old notes',
        impression: WorkoutImpression.neutral,
        datetimeStart: DateTime.now(),
      );

      when(mockRepository.editLocalDrift(any as dynamic)).thenAnswer(
        (_) async {},
      );

      // Act
      await pumpSessionForm(
        tester,
        session: existingSession,
        onSaved: () => onSavedCalled = true,
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Old notes'), 'Updated notes');
      await tester.tap(find.byKey(const ValueKey('save-button')));
      await tester.pumpAndSettle();

      // Assert
      final captured =
          verify(mockRepository.editLocalDrift(captureAny as dynamic)).captured.single
              as WorkoutSession;
      expect(captured.notes, 'Updated notes');
      expect(onSavedCalled, isTrue);
    });

    testWidgets('refuses a start moved past the end', (WidgetTester tester) async {
      // Arrange
      final existingSession = WorkoutSession(
        id: '1',
        routineId: 1,
        impression: WorkoutImpression.neutral,
        datetimeStart: DateTime(2026, 8, 13, 10, 0),
        datetimeEnd: DateTime(2026, 8, 13, 11, 0),
      );
      when(mockRepository.editLocalDrift(any as dynamic)).thenAnswer((_) async {});
      await pumpSessionForm(tester, session: existingSession);

      // Act
      tester
          .widget<TimeInputWidget>(find.byKey(const ValueKey('time-start')))
          .onChanged(const TimeOfDay(hour: 12, minute: 0));
      await tester.tap(find.byKey(const ValueKey('save-button')));
      await tester.pumpAndSettle();

      // Assert
      verifyNever(mockRepository.editLocalDrift(any as dynamic));
      expect(find.text('Start time cannot be ahead of end time'), findsOneWidget);
    });

    testWidgets('saves a session that ran past midnight', (WidgetTester tester) async {
      // Arrange
      final existingSession = WorkoutSession(
        id: '1',
        routineId: 1,
        impression: WorkoutImpression.neutral,
        datetimeStart: DateTime(2026, 8, 13, 23, 0),
      );
      when(mockRepository.editLocalDrift(any as dynamic)).thenAnswer((_) async {});
      await pumpSessionForm(tester, session: existingSession);

      // Act
      tester
          .widget<TimeInputWidget>(find.byKey(const ValueKey('time-end')))
          .onChanged(const TimeOfDay(hour: 1, minute: 0));
      await tester.tap(find.byKey(const ValueKey('save-button')));
      await tester.pumpAndSettle();

      // Assert
      final captured =
          verify(mockRepository.editLocalDrift(captureAny as dynamic)).captured.single
              as WorkoutSession;
      expect(captured.datetimeEnd, DateTime(2026, 8, 14, 1, 0));
    });

    // testWidgets('shows server side error messages', (WidgetTester tester) async {
    //   // Arrange
    //   await pumpSessionForm(tester);
    //   // when(mockRoutinesProvider.addSession(any, any)).thenThrow(
    //   //   WgerHttpException.fromMap({
    //   //     'name': ['The name is not valid'],
    //   //   }),
    //   // );
    //
    //   // Act
    //   await tester.tap(find.byKey(const ValueKey('save-button')));
    //   await tester.pumpAndSettle();
    //
    //   // Assert
    //   expect(find.text('The name is not valid'), findsOneWidget, reason: 'Error message is shown');
    // });
  });
}
