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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iOS health release prep', () {
    test('Info.plist describes the imported Health data scope', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(plist, contains('<key>NSHealthShareUsageDescription</key>'));
      expect(plist, contains('Apple Health'));
      expect(plist, contains('sleep, steps, distance, and active energy'));
      expect(plist, contains('wger account'));
    });

    test('PowerSync DB setup excludes the iOS database directory from backups', () {
      final databaseSetup = File('lib/database/powersync/powersync.dart').readAsStringSync();

      expect(databaseSetup, contains("const _iosDbDirectoryName = 'de.wger.flutter.community';"));
      expect(databaseSetup, contains("MethodChannel('de.wger.flutter/storage')"));
      expect(databaseSetup, contains("await _excludeFromBackup(dbDir.path);"));
      expect(
        databaseSetup,
        contains("await _migrateLegacyIosDatabaseFiles(fromDirectory: dir, toDirectory: dbDir);"),
      );
    });

    test('AppDelegate exposes the backup-exclusion channel', () {
      final appDelegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();

      expect(appDelegate, contains('de.wger.flutter/storage'));
      expect(appDelegate, contains('excludeFromBackup'));
      expect(appDelegate, contains('values.isExcludedFromBackup = true'));
    });
  });
}
