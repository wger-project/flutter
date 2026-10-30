import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/widgets/datetime_input.dart';
import 'package:wger/core/widgets/decimal_input.dart';
import 'package:wger/features/nutrition/models/log.dart';
import 'package:wger/features/nutrition/providers/nutrition_repository.dart';
import 'package:wger/features/nutrition/widgets/forms/diary_entry_edit.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/localizations_delegates.dart';

import '../../../../helpers/fake_connectivity.dart';
import 'diary_entry_edit_test.mocks.dart';

@GenerateMocks([NutritionRepository])
void main() {
  installFakeConnectivity();
  late MockNutritionRepository repo;
  late LogItem entry;

  setUp(() {
    repo = MockNutritionRepository();
    when(repo.watchAllDrift()).thenAnswer((_) => const Stream.empty());
    when(repo.watchAllLogsHydrated()).thenAnswer((_) => Stream.value([]));
    when(repo.watchAllMealsHydrated()).thenAnswer((_) => Stream.value([]));
    when(
      repo.editLogLocalDrift(
        id: anyNamed('id'),
        amount: anyNamed('amount'),
        datetime: anyNamed('datetime'),
        weightUnitId: anyNamed('weightUnitId'),
      ),
    ).thenAnswer((_) async {});
    entry = LogItem(
      id: 'entry',
      planId: 'plan',
      mealId: 'meal',
      ingredientId: 1,
      weightUnitId: 10,
      amount: 100,
      datetime: DateTime.utc(2026, 10, 25, 1, 30),
      comment: 'Keep',
    );
  });

  Future<void> open(WidgetTester tester, {String locale = 'en'}) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [nutritionRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => DiaryEntryEditDialog(entry: entry),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Finder amountField() => find.descendant(
    of: find.byType(DecimalInputWidget),
    matching: find.byType(TextFormField),
  );

  testWidgets('cancel leaves the original entry unchanged and performs no write', (tester) async {
    await open(tester);
    expect(find.text('100'), findsOneWidget);
    await tester.enterText(amountField(), '80.5');
    await tester.tap(find.byKey(const Key('diary-edit-cancel')));
    await tester.pumpAndSettle();
    expect(find.byType(DiaryEntryEditDialog), findsNothing);
    expect(entry.amount, 100);
    expect(entry.weightUnitId, 10);
    verifyNever(
      repo.editLogLocalDrift(
        id: anyNamed('id'),
        amount: anyNamed('amount'),
        datetime: anyNamed('datetime'),
        weightUnitId: anyNamed('weightUnitId'),
      ),
    );
  });

  for (final text in ['80.5', '80,5']) {
    testWidgets('German input $text saves 80.5 and explicitly clears the unit', (tester) async {
      await open(tester, locale: 'de');
      await tester.enterText(amountField(), text);
      await tester.tap(find.byKey(const Key('diary-edit-grams')));
      await tester.tap(find.byKey(const Key('diary-edit-save')));
      await tester.pumpAndSettle();
      verify(
        repo.editLogLocalDrift(
          id: 'entry',
          amount: 80.5,
          datetime: entry.datetime.toLocal(),
          weightUnitId: null,
        ),
      ).called(1);
      expect(entry.amount, 100);
      expect(entry.weightUnitId, 10);
      expect(find.byType(DiaryEntryEditDialog), findsNothing);
    });
  }

  testWidgets('date and time changes persist the chosen local instant', (tester) async {
    await open(tester);
    tester.widget<DateInputWidget>(find.byType(DateInputWidget)).onChanged(DateTime(2026, 10, 26));
    await tester.pump();
    tester
        .widget<TimeInputWidget>(find.byType(TimeInputWidget))
        .onChanged(
          const TimeOfDay(hour: 9, minute: 45),
        );
    await tester.pump();
    await tester.tap(find.byKey(const Key('diary-edit-save')));
    await tester.pumpAndSettle();
    verify(
      repo.editLogLocalDrift(
        id: 'entry',
        amount: 100,
        datetime: DateTime(2026, 10, 26, 9, 45),
        weightUnitId: 10,
      ),
    ).called(1);
    expect(entry.datetime, DateTime.utc(2026, 10, 25, 1, 30));
  });

  testWidgets('confirming the same date and time preserves the second DST occurrence', (
    tester,
  ) async {
    await open(tester);
    final local = entry.datetime.toLocal();
    tester
        .widget<DateInputWidget>(find.byType(DateInputWidget))
        .onChanged(
          DateTime(local.year, local.month, local.day),
        );
    await tester.pump();
    tester
        .widget<TimeInputWidget>(find.byType(TimeInputWidget))
        .onChanged(TimeOfDay.fromDateTime(local));
    await tester.pump();
    await tester.tap(find.byKey(const Key('diary-edit-save')));
    await tester.pumpAndSettle();
    final saved =
        verify(
              repo.editLogLocalDrift(
                id: 'entry',
                amount: 100,
                datetime: captureAnyNamed('datetime'),
                weightUnitId: 10,
              ),
            ).captured.single
            as DateTime;
    expect(saved.toUtc(), DateTime.utc(2026, 10, 25, 1, 30));
  });

  testWidgets('changing minutes keeps the second DST occurrence when still valid', (tester) async {
    await open(tester);
    final local = entry.datetime.toLocal();
    tester
        .widget<TimeInputWidget>(find.byType(TimeInputWidget))
        .onChanged(
          TimeOfDay(hour: local.hour, minute: 45),
        );
    await tester.pump();
    await tester.tap(find.byKey(const Key('diary-edit-save')));
    await tester.pumpAndSettle();
    final saved =
        verify(
              repo.editLogLocalDrift(
                id: 'entry',
                amount: 100,
                datetime: captureAnyNamed('datetime'),
                weightUnitId: 10,
              ),
            ).captured.single
            as DateTime;
    expect(saved.toUtc(), DateTime.utc(2026, 10, 25, 1, 45));
  });

  testWidgets('a failed local write keeps the dialog open and shows an error', (tester) async {
    when(
      repo.editLogLocalDrift(
        id: anyNamed('id'),
        amount: anyNamed('amount'),
        datetime: anyNamed('datetime'),
        weightUnitId: anyNamed('weightUnitId'),
      ),
    ).thenThrow(StateError('Entry was deleted'));
    await open(tester);
    await tester.tap(find.byKey(const Key('diary-edit-save')));
    await tester.pumpAndSettle();
    expect(find.byType(DiaryEntryEditDialog), findsOneWidget);
    expect(find.byKey(const Key('diary-edit-error')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending save cannot be submitted twice', (tester) async {
    final pending = Completer<void>();
    when(
      repo.editLogLocalDrift(
        id: anyNamed('id'),
        amount: anyNamed('amount'),
        datetime: anyNamed('datetime'),
        weightUnitId: anyNamed('weightUnitId'),
      ),
    ).thenAnswer((_) => pending.future);
    await open(tester);
    await tester.tap(find.byKey(const Key('diary-edit-save')));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byKey(const Key('diary-edit-save'))).onPressed, isNull);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(DiaryEntryEditDialog), findsNothing);
  });

  testWidgets('an out-of-range portion does not write to the repository', (tester) async {
    await open(tester);
    await tester.enterText(amountField(), '0.99');
    await tester.tap(find.byKey(const Key('diary-edit-save')));
    await tester.pumpAndSettle();
    expect(find.byType(DiaryEntryEditDialog), findsOneWidget);
    verifyNever(
      repo.editLogLocalDrift(
        id: anyNamed('id'),
        amount: anyNamed('amount'),
        datetime: anyNamed('datetime'),
        weightUnitId: anyNamed('weightUnitId'),
      ),
    );
  });
}
