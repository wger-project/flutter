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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/network/base_provider.dart';
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/core/network/wger_base.dart';
import 'package:wger/core/widgets/app_bar.dart';
import 'package:wger/core/widgets/sync_status_dialog.dart';
import 'package:wger/database/powersync/powersync.dart'
    show pendingUploadCountProvider, syncStatus, syncWatchdogProvider;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/generated/app_localizations_en.dart';
import 'package:wger/powersync/sync_watchdog.dart';

import '../../helpers/sync_status.dart';

/// A [NetworkStatus] resolving to a fixed value, recording the re-probes the
/// reconnect action asks for.
class _FakeNetworkStatus extends NetworkStatus {
  _FakeNetworkStatus(this._online);

  final bool _online;
  final checks = <bool>[];

  @override
  bool build() => _online;

  // The fake makes no request, so the timeout has nothing to apply to.
  @override
  Future<bool> check({
    Duration timeout = Duration.zero,
    bool optimistic = false,
  }) async {
    checks.add(optimistic);
    return _online;
  }
}

void main() {
  final i18n = AppLocalizationsEn();

  late _FakeNetworkStatus networkStatus;
  late SyncStreamWatchdog watchdog;

  setUp(() => networkStatus = _FakeNetworkStatus(false));

  /// Renders the app bar with the current [networkStatus] fake, and opens the
  /// sync dialog through the [icon] the bar is expected to show.
  Future<void> pumpAppBar(
    WidgetTester tester, {
    IconData icon = Icons.cloud_off,
    bool adapterAvailable = true,
  }) async {
    watchdog = SyncStreamWatchdog();
    addTearDown(watchdog.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkStatusProvider.overrideWith(() => networkStatus),
          networkAdapterAvailableProvider.overrideWithValue(adapterAvailable),
          wgerBaseProvider.overrideWithValue(WgerBaseProvider(serverUrl: 'https://wger.example')),
          syncStatus.overrideWithValue(buildSyncStatus()),
          syncWatchdogProvider.overrideWithValue(watchdog),
          pendingUploadCountProvider.overrideWith((ref) => const Stream<int>.empty()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(appBar: MainAppBar('Test')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(icon));
    await tester.pumpAndSettle();
  }

  testWidgets('offers the reconnect action while the status says offline', (tester) async {
    // The status is exactly what the user is trying to override here, so
    // gating the button on it would lock them out.
    await pumpAppBar(tester);

    expect(find.text(i18n.syncStatusReconnect), findsOneWidget);
  });

  testWidgets('a disconnected sync engine on a working network reads as connecting', (
    tester,
  ) async {
    // cloud_off here would say "broken" for what is just the retry loop
    // working, which is how a three second reconnect looked like an outage.
    networkStatus = _FakeNetworkStatus(true);

    await pumpAppBar(tester, icon: Icons.cloud_queue);

    expect(find.text(i18n.syncStatusConnecting), findsOneWidget);
  });

  testWidgets('re-probes the network when reconnect is tapped', (tester) async {
    await pumpAppBar(tester);

    await tester.tap(find.text(i18n.syncStatusReconnect));
    await tester.pumpAndSettle();

    expect(networkStatus.checks, [true]);
  });

  testWidgets('hides the reconnect action while there is no adapter', (tester) async {
    // The reachability status may be wrong, the adapter is a platform fact:
    // without one there is no transport a reconnect could possibly use.
    await pumpAppBar(tester, adapterAvailable: false);

    expect(find.text(i18n.syncStatusReconnect), findsNothing);
  });

  testWidgets('sync icon snapshots its providers at tap time and opens the dialog', (tester) async {
    // Companion to a production crash: reading a dirty provider from the
    // route builder forced a mid-build refresh. The exact race needs a
    // dependency flip in the same frame and is not deterministically
    // reproducible here; this pins the tap-time wiring of the fixed path.
    watchdog = SyncStreamWatchdog();
    addTearDown(watchdog.dispose);
    final container = ProviderContainer.test(
      overrides: [
        networkStatusProvider.overrideWithValue(true),
        networkAdapterAvailableProvider.overrideWithValue(true),
        wgerBaseProvider.overrideWithValue(WgerBaseProvider(serverUrl: 'https://wger.example')),
        syncStatus.overrideWithValue(buildSyncStatus(connected: true)),
        syncWatchdogProvider.overrideWithValue(watchdog),
        pendingUploadCountProvider.overrideWith((ref) => Stream.value(0)),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(appBar: MainAppBar('Test')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Dirty the provider the dialog reads, without pumping a frame, so the
    // flush happens on the tap itself.
    container.invalidate(wgerBaseProvider);

    await tester.tap(find.byIcon(Icons.cloud_done_outlined));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SyncStatusDialog), findsOneWidget);
  });
}
