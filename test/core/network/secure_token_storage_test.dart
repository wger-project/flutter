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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/network/secure_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final calls = <MethodCall>[];
  PlatformException? readError;

  setUp(() {
    calls.clear();
    readError = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        calls.add(call);
        if (call.method == 'read' && readError != null) {
          throw readError!;
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  test('iOS stores the token readable after first unlock, not only while unlocked', () async {
    // A refresh while the phone is locked between sets must still read the
    // token, which the default `unlocked` class refuses (#1417).
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await const FlutterSecureTokenStorage().writeRefreshToken('refresh');

    final write = calls.singleWhere((c) => c.method == 'write');
    final options = (write.arguments as Map)['options'] as Map;
    expect(options['accessibility'], 'first_unlock_this_device');
  });

  test('a keychain refusing interaction is reported as locked', () async {
    readError = PlatformException(code: 'Unexpected security result code', details: -25308);

    await expectLater(
      const FlutterSecureTokenStorage().readRefreshToken(),
      throwsA(isA<SecureStorageLockedException>()),
    );
  });

  test('any other read failure passes through unchanged', () async {
    // An undecryptable token (Android restore onto a new device) is gone for
    // good, so it must not be mistaken for a temporarily locked storage.
    readError = PlatformException(code: 'BadPaddingException');

    await expectLater(
      const FlutterSecureTokenStorage().readRefreshToken(),
      throwsA(
        isA<PlatformException>().having((e) => e.code, 'code', 'BadPaddingException'),
      ),
    );
  });
}
