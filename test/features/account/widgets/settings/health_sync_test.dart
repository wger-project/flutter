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

/// Reports the platform as available and returns canned results without
/// touching the real health/preferences stack.
class _FakeHealthSyncNotifier extends HealthSyncNotifier {
  final int? enableSyncResult;
  final HealthSyncState initialState;
  int syncCalls = 0;
  int retryCalls = 0;

  _FakeHealthSyncNotifier(this.enableSyncResult, {this.initialState = const HealthSyncState()});

  @override
  HealthSyncState build() => initialState;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<int?> enableSync() async {
    if (enableSyncResult != null) {
      state = state.copyWith(isEnabled: true);
    }
    return enableSyncResult;
  }

  @override
  Future<int> sync() async {
    syncCalls++;
    return 0;
  }

  @override
  Future<int?> retryWithPermissions() async {
    retryCalls++;
    return 0;
  }
}

/// Throws from [enableSync], the way a platform that refuses the request does.
class _ThrowingHealthSyncNotifier extends _FakeHealthSyncNotifier {
  _ThrowingHealthSyncNotifier() : super(null);

  @override
  Future<int?> enableSync() async => throw Exception('platform refused');
}

void main() {
  Widget createTile(_FakeHealthSyncNotifier fake) {
    return ProviderScope(
      overrides: [
        healthSyncProvider.overrideWith(() => fake),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HealthSyncSettingsTile()),
      ),
    );
  }

  testWidgets('shows a snackbar when the permissions are denied', (tester) async {
    await tester.pumpWidget(createTile(_FakeHealthSyncNotifier(null)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Access to health data was not granted'), findsOneWidget);
  });

  testWidgets('shows the import count after a successful sync', (tester) async {
    await tester.pumpWidget(createTile(_FakeHealthSyncNotifier(5)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Imported 5 measurements from Health'), findsOneWidget);
  });

  testWidgets('points at the platform settings when nothing was imported', (tester) async {
    // An empty first import is what a declined read permission looks like,
    // iOS never reports the denial itself
    await tester.pumpWidget(createTile(_FakeHealthSyncNotifier(0)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No health data was found. Check in Health Connect that wger is allowed to read your data.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('status line shows the last sync and starts a manual one', (tester) async {
    final fake = _FakeHealthSyncNotifier(
      null,
      initialState: HealthSyncState(
        isEnabled: true,
        lastSyncCount: 3,
        lastSyncTime: DateTime(2026, 7, 31, 14, 32),
      ),
    );
    await tester.pumpWidget(createTile(fake));
    await tester.pumpAndSettle();

    expect(find.textContaining('3 new entries'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.sync));
    await tester.pumpAndSettle();

    expect(fake.syncCalls, 1);
  });

  testWidgets('missing permissions are shown and retried interactively', (tester) async {
    final fake = _FakeHealthSyncNotifier(
      null,
      initialState: const HealthSyncState(
        isEnabled: true,
        issue: HealthSyncIssue.permissionsMissing,
      ),
    );
    await tester.pumpWidget(createTile(fake));
    await tester.pumpAndSettle();

    expect(find.textContaining('is not sharing your data'), findsOneWidget);
    expect(find.text('Tap to grant access again'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.warning_amber));
    await tester.pumpAndSettle();

    // Re-requesting prompts, a plain sync would not
    expect(fake.retryCalls, 1);
    expect(fake.syncCalls, 0);
  });

  testWidgets('a failed sync is shown as such', (tester) async {
    await tester.pumpWidget(
      createTile(
        _FakeHealthSyncNotifier(
          null,
          initialState: const HealthSyncState(isEnabled: true, issue: HealthSyncIssue.failed),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('The last sync could not be completed'), findsOneWidget);
  });

  testWidgets('a throwing enableSync stays in the tile', (tester) async {
    await tester.pumpWidget(createTile(_ThrowingHealthSyncNotifier()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    // Treated like a denial instead of bubbling into the global error dialog
    expect(tester.takeException(), isNull);
    expect(find.text('Access to health data was not granted'), findsOneWidget);
  });

  testWidgets('shows a spinner and blocks interaction while syncing', (tester) async {
    await tester.pumpWidget(
      createTile(
        _FakeHealthSyncNotifier(
          null,
          initialState: const HealthSyncState(isEnabled: true, isSyncing: true),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Syncing health data…'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged, isNull);
  });
}
