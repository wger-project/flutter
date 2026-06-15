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

// SyncStatus constructor is marked as @internal
// ignore_for_file: invalid_use_of_internal_member

import 'dart:io' show SocketException;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart'
    show
        CredentialsException,
        PowerSyncProtocolException,
        SyncResponseException,
        SyncStatus,
        UpdateType;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/generated/app_localizations_en.dart';
import 'package:wger/powersync/connector.dart' show RetryableUploadException;
import 'package:wger/widgets/core/sync_status_dialog.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

/// Renders [SyncStatusDialog] inside a minimal MaterialApp + Scaffold.
Future<void> _pumpDialog(WidgetTester tester, SyncStatus status) async {
  await tester.pumpWidget(_wrap(SyncStatusDialog(status)));
  await tester.pumpAndSettle();
}

void main() {
  final i18n = AppLocalizationsEn();

  group('syncStatusIconAndLabel', () {
    test('idle, online → Connected + cloud_done', () {
      final r = syncStatusIconAndLabel(const SyncStatus(connected: true), i18n);
      expect(r.icon, Icons.cloud_done_outlined);
      expect(r.label, i18n.syncStatusConnected);
    });

    test('connecting → Connecting + cloud_queue', () {
      final r = syncStatusIconAndLabel(const SyncStatus(connecting: true), i18n);
      expect(r.icon, Icons.cloud_queue);
      expect(r.label, i18n.syncStatusConnecting);
    });

    test('disconnected → Disconnected + cloud_off', () {
      final r = syncStatusIconAndLabel(const SyncStatus(), i18n);
      expect(r.icon, Icons.cloud_off);
      expect(r.label, i18n.syncStatusDisconnected);
    });

    test('uploading only → Uploading + cloud_upload', () {
      final r = syncStatusIconAndLabel(
        const SyncStatus(connected: true, uploading: true),
        i18n,
      );
      expect(r.icon, Icons.cloud_upload_outlined);
      expect(r.label, i18n.syncStatusUploading);
    });

    test('downloading only → Downloading + cloud_download', () {
      final r = syncStatusIconAndLabel(
        const SyncStatus(connected: true, downloading: true),
        i18n,
      );
      expect(r.icon, Icons.cloud_download_outlined);
      expect(r.label, i18n.syncStatusDownloading);
    });

    test('uploading + downloading → Synchronizing + cloud_sync', () {
      final r = syncStatusIconAndLabel(
        const SyncStatus(connected: true, uploading: true, downloading: true),
        i18n,
      );
      expect(r.icon, Icons.cloud_sync_outlined);
      expect(r.label, i18n.syncStatusSyncing);
    });

    test('error while connected → Sync error + sync_problem', () {
      final r = syncStatusIconAndLabel(
        SyncStatus(connected: true, downloadError: Exception('boom')),
        i18n,
      );
      expect(r.icon, Icons.sync_problem);
      expect(r.label, i18n.syncStatusError);
    });

    test('error while disconnected → Sync error + cloud_off', () {
      final r = syncStatusIconAndLabel(
        SyncStatus(downloadError: Exception('boom')),
        i18n,
      );
      expect(r.icon, Icons.cloud_off);
      expect(r.label, i18n.syncStatusError);
    });
  });

  group('SyncStatusDialog rendering', () {
    testWidgets('renders title, status label, and "never synced" placeholder', (tester) async {
      await _pumpDialog(tester, const SyncStatus(connected: true));

      expect(find.text(i18n.syncStatusDialogTitle), findsOneWidget);
      expect(find.text(i18n.syncStatusConnected), findsOneWidget);
      expect(find.text(i18n.syncStatusLastSynced), findsOneWidget);
      expect(find.text('-/-'), findsOneWidget);
    });

    testWidgets('formats the last-sync timestamp when set', (tester) async {
      final lastSync = DateTime.utc(2025, 1, 15, 9, 30, 45);
      await _pumpDialog(tester, SyncStatus(connected: true, lastSyncedAt: lastSync));

      expect(find.text('-/-'), findsNothing);
      expect(find.textContaining('2025'), findsOneWidget);
    });

    testWidgets('omits the error expander when there is no error', (tester) async {
      await _pumpDialog(tester, const SyncStatus(connected: true));

      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.text(i18n.syncStatusErrorDetails), findsNothing);
    });

    testWidgets('renders the expander with the raw error message when present', (tester) async {
      await _pumpDialog(
        tester,
        SyncStatus(connected: true, downloadError: Exception('disk-on-fire')),
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
      await _pumpDialog(tester, SyncStatus(connected: true, downloadError: error));
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
