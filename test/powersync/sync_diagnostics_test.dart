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

import 'dart:io' show SocketException;

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/powersync/sync_diagnostics.dart';

import '../helpers/sync_status.dart';

void main() {
  group('serverCategory', () {
    test('maps the known servers and hides self-hosted URLs', () {
      expect(serverCategory(null), isNull);
      expect(serverCategory(DEFAULT_SERVER_PROD), 'wger.de');
      expect(serverCategory(DEFAULT_SERVER_TEST), 'dev.wger.de');
      expect(serverCategory('https://wger.my-private-nas.example'), 'self-hosted');
    });
  });

  group('formatSyncDiagnostics', () {
    test('renders the healthy state', () {
      final text = formatSyncDiagnostics(
        buildSyncStatus(connected: true, lastSyncedAt: DateTime.utc(2026, 7, 29, 10, 30)),
        pendingUploads: 0,
        server: 'wger.de',
      );

      expect(text, contains('server: wger.de'));
      expect(text, contains('connected: true, connecting: false'));
      expect(text, contains('last successful sync: 2026-07-29T10:30:00.000Z'));
      expect(text, contains('pending uploads: 0'));
      expect(text, isNot(contains('error')));
    });

    test('reports a never-completed sync and the pending queue', () {
      final text = formatSyncDiagnostics(buildSyncStatus(connecting: true), pendingUploads: 3);

      expect(text, contains('last successful sync: never'));
      expect(text, contains('pending uploads: 3'));
      expect(text, isNot(contains('server:')));
    });

    test('includes the categorised error', () {
      final text = formatSyncDiagnostics(
        buildSyncStatus(downloadError: const SocketException('no route to host')),
        pendingUploads: 0,
      );

      expect(text, contains('error (Connection error): SocketException'));
    });

    test('clamps oversized error messages', () {
      final text = formatSyncDiagnostics(
        buildSyncStatus(downloadError: Exception('x' * 5000)),
        pendingUploads: 0,
      );

      final errorLine = text.split('\n').firstWhere((line) => line.startsWith('error'));
      expect(errorLine.length, lessThan(350));
      expect(errorLine, endsWith('…'));
    });
  });

  group('collectSyncDiagnostics', () {
    test('returns null while the PowerSync database is not initialised', () async {
      expect(await collectSyncDiagnostics(), isNull);
    });
  });
}
