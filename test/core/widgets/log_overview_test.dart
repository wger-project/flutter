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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/logs.dart';
import 'package:wger/core/widgets/log_overview.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    InMemoryLogStore().clear();
  });

  Widget wrap() => const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale('en'),
    home: LogOverviewPage(),
  );

  testWidgets('shows the message together with the error', (tester) async {
    InMemoryLogStore().add(
      LogRecord(Level.WARNING, 'Sync service error', 'powersync', Exception('connection refused')),
    );

    await tester.pumpWidget(wrap());

    expect(find.textContaining('Sync service error'), findsOneWidget);
    expect(find.textContaining('connection refused'), findsOneWidget);
  });

  testWidgets('the filter matches the message and the logger name', (tester) async {
    InMemoryLogStore()
      ..add(LogRecord(Level.INFO, 'Network status: offline', 'NetworkStatus'))
      ..add(LogRecord(Level.INFO, 'Sync checkpoint received', 'powersync'));

    await tester.pumpWidget(wrap());
    expect(find.textContaining('Network status'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('logFilterField')), 'powersync');
    await tester.pumpAndSettle();

    expect(find.textContaining('Network status'), findsNothing);
    expect(find.textContaining('Sync checkpoint received'), findsOneWidget);
  });

  testWidgets('the filter also matches the error text', (tester) async {
    InMemoryLogStore()
      ..add(LogRecord(Level.INFO, 'Network status: offline', 'NetworkStatus'))
      ..add(
        LogRecord(Level.WARNING, 'Sync service error', 'powersync', Exception('nothing to see')),
      );

    await tester.pumpWidget(wrap());
    await tester.enterText(find.byKey(const ValueKey('logFilterField')), 'nothing to see');
    await tester.pumpAndSettle();

    expect(find.textContaining('Sync service error'), findsOneWidget);
    expect(find.textContaining('Network status'), findsNothing);
  });

  testWidgets('copies only the entries the filter lets through', (tester) async {
    InMemoryLogStore()
      ..add(LogRecord(Level.INFO, 'Network status: offline', 'NetworkStatus'))
      ..add(LogRecord(Level.INFO, 'Sync checkpoint received', 'powersync'));

    await tester.pumpWidget(wrap());
    await tester.enterText(find.byKey(const ValueKey('logFilterField')), 'checkpoint');
    await tester.pumpAndSettle();

    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
      call,
    ) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    // The button in the app bar copies everything that is currently listed
    await tester.tap(find.byIcon(Icons.copy_all_outlined).first);
    await tester.pumpAndSettle();

    expect(copied, contains('Sync checkpoint received'));
    expect(copied, isNot(contains('Network status')));
  });
}
