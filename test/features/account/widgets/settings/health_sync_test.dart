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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/account/widgets/settings/health_sync.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/health/providers/health_sync.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Reports the platform as available and returns canned results without
/// touching the real health/preferences stack.
class _FakeHealthSyncNotifier extends HealthSyncNotifier {
  final int? enableSyncResult;
  final HealthSyncState initialState;
  final HealthPlatformAvailability platformAvailability;
  int syncCalls = 0;
  int retryCalls = 0;
  int installCalls = 0;

  _FakeHealthSyncNotifier(
    this.enableSyncResult, {
    this.initialState = const HealthSyncState(),
    this.platformAvailability = HealthPlatformAvailability.available,
  });

  @override
  HealthSyncState build() => initialState;

  @override
  Future<HealthPlatformAvailability> availability() async => platformAvailability;

  @override
  Future<void> openHealthConnectInstall() async => installCalls++;

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

/// Throws from [retryWithPermissions], which asks the platform the same way
/// [enableSync] does.
class _ThrowingRetryHealthSyncNotifier extends _FakeHealthSyncNotifier {
  _ThrowingRetryHealthSyncNotifier()
    : super(
        null,
        initialState: const HealthSyncState(
          isEnabled: true,
          issue: HealthSyncIssue.permissionsMissing,
        ),
      );

  @override
  Future<int?> retryWithPermissions() async => throw Exception('platform refused');
}

void main() {
  Widget createTile(_FakeHealthSyncNotifier fake) {
    return ProviderScope(
      overrides: [
        healthSyncProvider.overrideWith(() => fake),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
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

  testWidgets('a throwing retry stays in the tile', (tester) async {
    await tester.pumpWidget(createTile(_ThrowingRetryHealthSyncNotifier()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.warning_amber));
    await tester.pumpAndSettle();

    // Same treatment as the toggle: a refused request is a denial, not a crash
    expect(tester.takeException(), isNull);
    expect(find.textContaining('is not sharing your data'), findsOneWidget);
  });

  testWidgets('offers installing Health Connect instead of hiding the feature', (tester) async {
    final fake = _FakeHealthSyncNotifier(
      null,
      platformAvailability: HealthPlatformAvailability.notInstalled,
    );
    await tester.pumpWidget(createTile(fake));
    await tester.pumpAndSettle();

    expect(find.text('Install Health Connect'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNothing);

    await tester.tap(find.text('Install Health Connect'));
    await tester.pumpAndSettle();

    expect(fake.installCalls, 1);
  });

  testWidgets('offers updating an outdated Health Connect', (tester) async {
    await tester.pumpWidget(
      createTile(
        _FakeHealthSyncNotifier(
          null,
          platformAvailability: HealthPlatformAvailability.updateRequired,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Update Health Connect'), findsOneWidget);
  });

  testWidgets('stays hidden where no health platform exists', (tester) async {
    await tester.pumpWidget(
      createTile(
        _FakeHealthSyncNotifier(
          null,
          platformAvailability: HealthPlatformAvailability.unsupported,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Health'), findsNothing);
    expect(find.byType(ListTile), findsNothing);
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
    // The run has not worked out yet how much there is to read
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('shows how far a running sync has come', (tester) async {
    // A first import reads years of history, which takes long enough that a
    // spinner alone leaves the user wondering whether anything happens
    await tester.pumpWidget(
      createTile(
        _FakeHealthSyncNotifier(
          null,
          initialState: const HealthSyncState(
            isEnabled: true,
            isSyncing: true,
            progress: (windowsDone: 2100, windowsTotal: 5000),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
      0.42,
    );
    expect(find.text('42%'), findsOneWidget);
  });
}
