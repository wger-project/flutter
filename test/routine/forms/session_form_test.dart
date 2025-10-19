// test/widgets/routines/forms/session_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/forms/session.dart';

import 'session_form_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  late MockRoutinesProvider mockRoutinesProvider;

  setUp(() {
    mockRoutinesProvider = MockRoutinesProvider();
  });

  Future<void> pumpSessionForm(
    WidgetTester tester, {
    WorkoutSession? session,
    int routineId = 1,
    Function()? onSaved,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<RoutinesProvider>.value(
            value: mockRoutinesProvider,
          ),
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
        id: 1,
        routineId: 1,
        notes: 'Existing notes',
        impression: 1,
        date: DateTime.now(),
        timeStart: const TimeOfDay(hour: 10, minute: 0),
        timeEnd: const TimeOfDay(hour: 11, minute: 0),
      );

      //Act
      await pumpSessionForm(tester, session: existingSession);

      //Assert
      expect(find.widgetWithText(TextFormField, 'Existing notes'), findsOneWidget);
      final toggleButtons = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
      expect(toggleButtons.isSelected, [true, false, false]); // Bad impression
      expect(find.widgetWithText(TextFormField, '10:00'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '11:00'), findsOneWidget);
    });

    testWidgets('saves a new session', (WidgetTester tester) async {
      // Arrange
      bool onSavedCalled = false;
      await pumpSessionForm(tester, onSaved: () => onSavedCalled = true);

      when(mockRoutinesProvider.addSession(any, any)).thenAnswer(
        (_) async => WorkoutSession(id: 1, routineId: 1, date: DateTime.now()),
      );

      // Act
      await tester.enterText(find.widgetWithText(TextFormField, 'Notes'), 'New session notes');
      await tester.tap(find.byKey(const ValueKey('save-button')));
      await tester.pumpAndSettle();

      // Assert
      verify(mockRoutinesProvider.addSession(any, 1)).called(1);
      expect(onSavedCalled, isTrue);
    });

    testWidgets('saves an existing session', (WidgetTester tester) async {
      // Arrange
      bool onSavedCalled = false;
      final existingSession = WorkoutSession(
        id: 1,
        routineId: 1,
        notes: 'Old notes',
        impression: 2,
        date: DateTime.now(),
      );
      when(mockRoutinesProvider.editSession(any)).thenAnswer(
        (_) async => WorkoutSession(
          id: 1,
          routineId: 1,
          date: DateTime.now(),
        ),
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
          verify(mockRoutinesProvider.editSession(captureAny)).captured.single as WorkoutSession;
      expect(captured.notes, 'Updated notes');
      expect(onSavedCalled, isTrue);
    });

    testWidgets('shows server side error messages', (WidgetTester tester) async {
      // Arrange
      await pumpSessionForm(tester);
      when(mockRoutinesProvider.addSession(any, any)).thenThrow(
        WgerHttpException.fromMap({
          'name': ['The name is not valid'],
        }),
      );

      // Act
      await tester.tap(find.byKey(const ValueKey('save-button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('The name is not valid'), findsOneWidget, reason: 'Error message is shown');
    });
  });
}
