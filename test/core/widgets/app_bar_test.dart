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
import 'package:wger/core/network/base_provider.dart';
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/core/network/wger_base.dart';
import 'package:wger/core/widgets/app_bar.dart';
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

  @override
  Future<bool> check({
    Duration timeout = const Duration(seconds: 1),
    bool optimistic = false,
  }) async {
    checks.add(optimistic);
    return _online;
  }
}

void main() {
  final i18n = AppLocalizationsEn();

  late _FakeNetworkStatus networkStatus;

  setUp(() => networkStatus = _FakeNetworkStatus(false));

  Future<void> pumpAppBar(WidgetTester tester) async {
    final watchdog = SyncStreamWatchdog();
    addTearDown(watchdog.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkStatusProvider.overrideWith(() => networkStatus),
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

    await tester.tap(find.byIcon(Icons.cloud_off));
    await tester.pumpAndSettle();
  }

  testWidgets('offers the reconnect action while the status says offline', (tester) async {
    // The status is exactly what the user is trying to override here, so
    // gating the button on it would lock them out.
    await pumpAppBar(tester);

    expect(find.text(i18n.syncStatusReconnect), findsOneWidget);
  });

  testWidgets('re-probes the network when reconnect is tapped', (tester) async {
    await pumpAppBar(tester);

    await tester.tap(find.text(i18n.syncStatusReconnect));
    await tester.pumpAndSettle();

    expect(networkStatus.checks, [true]);
  });
}
