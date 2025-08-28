import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/plate_weights.dart';
import 'package:wger/widgets/routines/plate_calculator.dart';

Future<void> pumpWidget(
  WidgetTester tester, {
  PlateCalculatorNotifier? notifier,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (notifier != null) plateCalculatorProvider.overrideWith((ref) => notifier),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ConfigureAvailablePlates()),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Smoke test for ConfigureAvailablePlates', (WidgetTester tester) async {
    await pumpWidget(tester);

    debugDumpApp();
    expect(find.text('Unit'), findsWidgets);
    expect(find.text('Bar weight'), findsWidgets);
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(PlateWeight), findsWidgets);
  });

  testWidgets(
    'ConfigureAvailablePlates correctly updates state',
    (WidgetTester tester) async {
      // Arrange
      final notifier = PlateCalculatorNotifier();
      notifier.state = PlateCalculatorState(
        isMetric: true,
        barWeight: 20,
        useColors: false,
        selectedPlates: [1.25, 2.5],
      );

      await pumpWidget(tester, notifier: notifier);

      // Correctly changes the unit
      expect(notifier.state.isMetric, isTrue);
      await tester.tap(find.byKey(const ValueKey('weightUnitDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('lb').last);
      await tester.pumpAndSettle();
      expect(notifier.state.isMetric, isFalse);

      // Correctly changes the bar weight
      expect(notifier.state.barWeight, 45);
      await tester.tap(find.byKey(const ValueKey('barWeightDropdown')));
      await tester.pumpAndSettle();
      final menuItem = find.ancestor(
        of: find.text('25'),
        matching: find.byType(InkWell),
      );
      expect(menuItem, findsOneWidget);
      await tester.tap(menuItem);
      await tester.pumpAndSettle();
      expect(notifier.state.barWeight, 25);

      // Correctly toggles the useColors switch
      expect(notifier.state.useColors, isFalse);
      await tester.tap(find.byKey(const ValueKey('useColorsSwitch')));
      await tester.pumpAndSettle();
      expect(notifier.state.useColors, isTrue);

      // Correctly adds and removes plates
      expect(notifier.state.selectedPlates.contains(5.0), isTrue);
      await tester.tap(find.byKey(const ValueKey('plateWeight-5')));
      await tester.pumpAndSettle();
      expect(notifier.state.selectedPlates.contains(5.0), isFalse);
    },
  );
}
