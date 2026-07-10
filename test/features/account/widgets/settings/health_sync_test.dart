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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/account/widgets/settings/health_sync.dart';
import 'package:wger/features/health/providers/health_sync.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Reports the platform as available and returns a canned result from
/// [enableSync] without touching the real health/preferences stack.
class _FakeHealthSyncNotifier extends HealthSyncNotifier {
  final int? enableSyncResult;

  _FakeHealthSyncNotifier(this.enableSyncResult);

  @override
  HealthSyncState build() => const HealthSyncState();

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<int?> enableSync() async => enableSyncResult;
}

void main() {
  Widget createTile(int? enableSyncResult) {
    return ProviderScope(
      overrides: [
        healthSyncProvider.overrideWith(() => _FakeHealthSyncNotifier(enableSyncResult)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HealthSyncSettingsTile()),
      ),
    );
  }

  testWidgets('shows a snackbar when the permissions are denied', (tester) async {
    await tester.pumpWidget(createTile(null));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Access to health data was not granted'), findsOneWidget);
  });

  testWidgets('shows the import count after a successful sync', (tester) async {
    await tester.pumpWidget(createTile(5));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Imported 5 measurements from Health'), findsOneWidget);
  });

  testWidgets('shows no snackbar when nothing was imported', (tester) async {
    await tester.pumpWidget(createTile(0));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
  });
}
