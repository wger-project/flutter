/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'dart:async';
import 'dart:io' show SocketException;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart'
    show
        CredentialsException,
        PowerSyncProtocolException,
        SyncResponseException,
        SyncStatus,
        UpdateType;
import 'package:wger/core/error_dialogs.dart' show CopyToClipboardButton;
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/core/widgets/sync_status_dialog.dart';
import 'package:wger/database/powersync/powersync.dart'
    show pendingUploadCountProvider, syncStatus, syncWatchdogProvider;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/generated/app_localizations_en.dart';
import 'package:wger/powersync/connector.dart'
    show NoPowerSyncEndpointException, RetryableUploadException;
import 'package:wger/powersync/sync_watchdog.dart';

import '../../helpers/sync_status.dart';

/// Wraps [child] in a MaterialApp with the providers the dialog watches
/// overridden to fixed test values.
Widget _wrap(
  Widget child, {
  required SyncStatus status,
  bool stalled = false,
  bool deviceOnline = true,
  Stream<int>? pendingUploads,
}) {
  final watchdog = SyncStreamWatchdog();
  watchdog.stalled.value = stalled;
  return ProviderScope(
    overrides: [
      syncStatus.overrideWithValue(status),
      networkStatusProvider.overrideWithValue(deviceOnline),
      syncWatchdogProvider.overrideWithValue(watchdog),
      pendingUploadCountProvider.overrideWith((ref) => pendingUploads ?? const Stream.empty()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    ),
  );
}

/// Renders a plain [SyncStatusDialog] for the given status.
Future<void> _pumpDialog(WidgetTester tester, SyncStatus status) async {
  await tester.pumpWidget(_wrap(const SyncStatusDialog(), status: status));
  await tester.pumpAndSettle();
}

void main() {
  final i18n = AppLocalizationsEn();

  group('syncStatusIconAndLabel', () {
    test('idle, online → Connected + cloud_done', () {
      final r = syncStatusIconAndLabel(buildSyncStatus(connected: true), i18n, deviceOnline: true);
      expect(r.icon, Icons.cloud_done_outlined);
      expect(r.label, i18n.syncStatusConnected);
    });

    test('connecting → Connecting + cloud_queue', () {
      final r = syncStatusIconAndLabel(buildSyncStatus(connecting: true), i18n, deviceOnline: true);
      expect(r.icon, Icons.cloud_queue);
      expect(r.label, i18n.syncStatusConnecting);
    });

    test('disconnected while the device is offline → Disconnected + cloud_off', () {
      final r = syncStatusIconAndLabel(buildSyncStatus(), i18n, deviceOnline: false);
      expect(r.icon, Icons.cloud_off);
      expect(r.label, i18n.syncStatusDisconnected);
    });

    test('disconnected while the network is up → Connecting, not cloud_off', () {
      // The retry loop is working on it. cloud_off here reads as "broken",
      // which is what made a three second reconnect look like an outage.
      final r = syncStatusIconAndLabel(buildSyncStatus(), i18n, deviceOnline: true);
      expect(r.icon, Icons.cloud_queue);
      expect(r.label, i18n.syncStatusConnecting);
    });

    test('the uninitialized state on app start reads as Connecting', () {
      final r = syncStatusIconAndLabel(buildUninitializedSyncStatus(), i18n, deviceOnline: true);
      expect(r.icon, Icons.cloud_queue);
      expect(r.label, i18n.syncStatusConnecting);
    });

    test('uploading only → Uploading + cloud_upload', () {
      final r = syncStatusIconAndLabel(
        buildSyncStatus(connected: true, uploading: true),
        i18n,
        deviceOnline: true,
      );
      expect(r.icon, Icons.cloud_upload_outlined);
      expect(r.label, i18n.syncStatusUploading);
    });

    test('downloading only → Downloading + cloud_download', () {
      final r = syncStatusIconAndLabel(
        buildSyncStatus(connected: true, downloading: true),
        i18n,
        deviceOnline: true,
      );
      expect(r.icon, Icons.cloud_download_outlined);
      expect(r.label, i18n.syncStatusDownloading);
    });

    test('uploading + downloading → Synchronizing + cloud_sync', () {
      final r = syncStatusIconAndLabel(
        buildSyncStatus(connected: true, uploading: true, downloading: true),
        i18n,
        deviceOnline: true,
      );
      expect(r.icon, Icons.cloud_sync_outlined);
      expect(r.label, i18n.syncStatusSyncing);
    });

    test('error while connected → Sync error + sync_problem', () {
      final r = syncStatusIconAndLabel(
        buildSyncStatus(connected: true, downloadError: Exception('boom')),
        i18n,
        deviceOnline: true,
      );
      expect(r.icon, Icons.sync_problem);
      expect(r.label, i18n.syncStatusError);
    });

    test('error while disconnected → Sync error + cloud_off', () {
      final r = syncStatusIconAndLabel(
        buildSyncStatus(downloadError: Exception('boom')),
        i18n,
        deviceOnline: true,
      );
      expect(r.icon, Icons.cloud_off);
      expect(r.label, i18n.syncStatusError);
    });

    test('error while the device is offline → Disconnected, not Sync error', () {
      // Errors piled up during an outage are a consequence of the outage; a
      // device that is offline reads as calmly disconnected, not broken.
      final r = syncStatusIconAndLabel(
        buildSyncStatus(downloadError: Exception('boom')),
        i18n,
        deviceOnline: false,
      );
      expect(r.icon, Icons.cloud_off);
      expect(r.label, i18n.syncStatusDisconnected);
    });
  });

  group('SyncStatusDialog rendering', () {
    testWidgets('renders title, status label, and the never-synced text', (tester) async {
      // Without a lastSyncedAt the status derives hasSynced == false
      await _pumpDialog(tester, buildSyncStatus(connected: true));

      expect(find.text(i18n.syncStatusDialogTitle), findsOneWidget);
      expect(find.text(i18n.syncStatusConnected), findsOneWidget);
      expect(find.text(i18n.syncStatusLastSynced), findsOneWidget);
      expect(find.text(i18n.syncStatusNeverSynced), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('offers the snapshot for copying even when nothing looks wrong', (tester) async {
      // The state we keep getting reports about: no error, not stalled, so
      // the report button stays hidden and copying is the only way out.
      await _pumpDialog(tester, buildSyncStatus());

      expect(find.text('Report issue'), findsNothing);
      final button = tester.widget<CopyToClipboardButton>(find.byType(CopyToClipboardButton));
      expect(button.text, contains('last successful sync: never'));
      expect(button.text, contains('pending uploads: 0'));
    });

    testWidgets('renders the placeholder while the sync state is still unknown', (tester) async {
      await _pumpDialog(tester, buildUninitializedSyncStatus());

      expect(find.text('-/-'), findsOneWidget);
      expect(find.text(i18n.syncStatusNeverSynced), findsNothing);
    });

    testWidgets('shows the pending-upload count when changes are waiting', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SyncStatusDialog(),
          status: buildSyncStatus(connected: true),
          pendingUploads: Stream.value(3),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(i18n.syncStatusPendingUploads(3)), findsOneWidget);
    });

    testWidgets('omits the pending-upload line when the queue is empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SyncStatusDialog(),
          status: buildSyncStatus(connected: true),
          pendingUploads: Stream.value(0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('upload'), findsNothing);
    });

    testWidgets('updates the pending-upload count while the dialog is open', (tester) async {
      final queue = StreamController<int>();
      addTearDown(queue.close);
      await tester.pumpWidget(
        _wrap(
          const SyncStatusDialog(),
          status: buildSyncStatus(connected: true),
          pendingUploads: queue.stream,
        ),
      );
      await tester.pumpAndSettle();

      queue.add(2);
      await tester.pumpAndSettle();
      expect(find.text(i18n.syncStatusPendingUploads(2)), findsOneWidget);

      // The queue drained: the line disappears without reopening the dialog
      queue.add(0);
      await tester.pumpAndSettle();
      expect(find.textContaining('upload'), findsNothing);
    });

    testWidgets('shows the server URL when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SyncStatusDialog(serverUrl: 'https://wger.example'),
          status: buildSyncStatus(connected: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(i18n.serverSectionLabel), findsOneWidget);
      expect(find.text('https://wger.example'), findsOneWidget);
    });

    testWidgets('formats the last-sync timestamp when set', (tester) async {
      final lastSync = DateTime.utc(2025, 1, 15, 9, 30, 45);
      await _pumpDialog(tester, buildSyncStatus(connected: true, lastSyncedAt: lastSync));

      expect(find.text('-/-'), findsNothing);
      expect(find.textContaining('2025'), findsOneWidget);
    });

    testWidgets('omits the error expander when there is no error', (tester) async {
      await _pumpDialog(tester, buildSyncStatus(connected: true));

      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.text(i18n.syncStatusErrorDetails), findsNothing);
    });

    testWidgets('shows the blocked-connection hint when stalled without an error', (tester) async {
      await tester.pumpWidget(
        _wrap(const SyncStatusDialog(), status: buildSyncStatus(connecting: true), stalled: true),
      );
      await tester.pumpAndSettle();

      expect(find.text(i18n.syncStatusStalledHint), findsOneWidget);
      expect(find.text(i18n.applicationLogs), findsOneWidget);
    });

    testWidgets('omits the stalled hint when not stalled', (tester) async {
      await _pumpDialog(tester, buildSyncStatus(connecting: true));

      expect(find.text(i18n.syncStatusStalledHint), findsNothing);
      expect(find.text(i18n.applicationLogs), findsNothing);
    });

    testWidgets('prefers the real error over the stalled hint', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SyncStatusDialog(),
          status: buildSyncStatus(connecting: true, downloadError: Exception('boom')),
          stalled: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(i18n.syncStatusStalledHint), findsNothing);
      expect(find.text(i18n.syncStatusError), findsOneWidget);
    });

    testWidgets('shows the reconnect action on error and fires the callback', (tester) async {
      var reconnected = false;
      await tester.pumpWidget(
        _wrap(
          SyncStatusDialog(onReconnect: () => reconnected = true),
          status: buildSyncStatus(connected: true, downloadError: Exception('boom')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(i18n.syncStatusReconnect));
      await tester.pumpAndSettle();
      expect(reconnected, isTrue);
    });

    testWidgets('shows the reconnect action even while the sync looks healthy', (tester) async {
      await tester.pumpWidget(
        _wrap(SyncStatusDialog(onReconnect: () {}), status: buildSyncStatus(connected: true)),
      );
      await tester.pumpAndSettle();

      expect(find.text(i18n.syncStatusReconnect), findsOneWidget);
    });

    testWidgets('offers the report action on error and when stalled, not while healthy', (
      tester,
    ) async {
      await _pumpDialog(tester, buildSyncStatus(connected: true));
      expect(find.text('Report issue'), findsNothing);

      await _pumpDialog(tester, buildSyncStatus(connected: true, downloadError: Exception('boom')));
      expect(find.text('Report issue'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(const SyncStatusDialog(), status: buildSyncStatus(connecting: true), stalled: true),
      );
      await tester.pumpAndSettle();
      expect(find.text('Report issue'), findsOneWidget);
    });

    testWidgets('omits the reconnect action without a callback', (tester) async {
      await _pumpDialog(tester, buildSyncStatus(connected: true, downloadError: Exception('boom')));

      expect(find.text(i18n.syncStatusReconnect), findsNothing);
    });

    testWidgets('renders the expander with the raw error message when present', (tester) async {
      await _pumpDialog(
        tester,
        buildSyncStatus(connected: true, downloadError: Exception('disk-on-fire')),
      );

      expect(find.byType(ExpansionTile), findsOneWidget);
      expect(find.text(i18n.syncStatusErrorDetails), findsOneWidget);

      // Expand and check the raw error is reachable.
      await tester.tap(find.text(i18n.syncStatusErrorDetails));
      await tester.pumpAndSettle();
      expect(find.textContaining('disk-on-fire'), findsOneWidget);
    });
  });

  group('SyncStatusDialog error categorisation', () {
    Future<void> expectCategory(WidgetTester tester, Object error, String? category) async {
      await _pumpDialog(tester, buildSyncStatus(connected: true, downloadError: error));
      if (category == null) {
        for (final candidate in const [
          'Authentication error',
          'Connection error',
          'Server error',
          'Protocol error',
        ]) {
          expect(find.text(candidate), findsNothing, reason: 'unexpected category "$candidate"');
        }
      } else {
        expect(find.text(category), findsOneWidget);
      }
    }

    testWidgets('CredentialsException → "Authentication error"', (tester) async {
      await expectCategory(tester, CredentialsException('Not logged in'), 'Authentication error');
    });

    testWidgets('NoPowerSyncEndpointException → "Sync service unavailable"', (tester) async {
      // A dead or misconfigured sync service behind a working backend must
      // not read as an authentication problem.
      await expectCategory(tester, NoPowerSyncEndpointException(), 'Sync service unavailable');
    });

    testWidgets('SyncResponseException(401) → "Authentication error"', (tester) async {
      await expectCategory(tester, SyncResponseException(401, 'no token'), 'Authentication error');
    });

    testWidgets('SyncResponseException(403) → "Authentication error"', (tester) async {
      await expectCategory(tester, SyncResponseException(403, 'forbidden'), 'Authentication error');
    });

    testWidgets('SyncResponseException(503) → "Server error"', (tester) async {
      await expectCategory(tester, SyncResponseException(503, 'unavailable'), 'Server error');
    });

    testWidgets('SyncResponseException(429) → "HTTP 429"', (tester) async {
      await expectCategory(tester, SyncResponseException(429, 'rate limited'), 'HTTP 429');
    });

    testWidgets('PowerSyncProtocolException → "Protocol error"', (tester) async {
      await expectCategory(tester, PowerSyncProtocolException('bad frame'), 'Protocol error');
    });

    testWidgets('RetryableUploadException(503) → "Server error"', (tester) async {
      await expectCategory(
        tester,
        RetryableUploadException(table: 'manager_routine', op: UpdateType.put, statusCode: 503),
        'Server error',
      );
    });

    testWidgets('RetryableUploadException(401) → "Authentication error"', (tester) async {
      await expectCategory(
        tester,
        RetryableUploadException(table: 'manager_routine', op: UpdateType.put, statusCode: 401),
        'Authentication error',
      );
    });

    testWidgets('RetryableUploadException(429) → "HTTP 429"', (tester) async {
      await expectCategory(
        tester,
        RetryableUploadException(table: 'manager_routine', op: UpdateType.put, statusCode: 429),
        'HTTP 429',
      );
    });

    testWidgets('SocketException → "Connection error"', (tester) async {
      await expectCategory(
        tester,
        const SocketException('Connection refused'),
        'Connection error',
      );
    });

    testWidgets('unknown exception type → no sub-label rendered', (tester) async {
      await expectCategory(tester, Exception('something obscure'), null);
    });
  });
}
