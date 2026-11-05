import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/features/nutrition/models/log.dart';
import 'package:wger/features/nutrition/models/nutritional_plan.dart';
import 'package:wger/features/nutrition/widgets/forms/diary_entry_edit.dart';
import 'package:wger/features/nutrition/widgets/nutrition_tiles.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/localizations_delegates.dart';

void main() {
  testWidgets('diary Edit opens a portion editor and retains the Delete action', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final entry = LogItem(
      id: 'entry',
      planId: 'plan',
      ingredientId: 1,
      amount: 100,
      datetime: DateTime.utc(2026, 10, 25),
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DiaryEntryTile(
              diaryEntry: entry,
              nutritionalPlan: NutritionalPlan.empty(),
            ),
          ),
        ),
      ),
    );
    expect(find.byTooltip('Delete'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    expect(find.byType(DiaryEntryEditDialog), findsOneWidget);
    expect(
      tester.widget<DiaryEntryEditDialog>(find.byType(DiaryEntryEditDialog)).entry,
      same(entry),
    );
  });
}
