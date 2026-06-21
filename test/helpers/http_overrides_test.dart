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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/http_overrides.dart';

void main() {
  // Restore the default networking after each test so we don't leak the
  // certificate override into other tests sharing the same isolate.
  final HttpOverrides? original = HttpOverrides.current;
  tearDown(() => HttpOverrides.global = original);

  test('applySelfSignedCertOverride(true) installs WgerHttpOverrides', () {
    applySelfSignedCertOverride(true);
    expect(HttpOverrides.current, isA<WgerHttpOverrides>());
  });

  test('applySelfSignedCertOverride(false) removes the override', () {
    applySelfSignedCertOverride(true);
    applySelfSignedCertOverride(false);
    expect(HttpOverrides.current, isNull);
  });

  test('WgerHttpOverrides creates a usable HttpClient', () {
    final client = WgerHttpOverrides().createHttpClient(null);
    expect(client, isA<HttpClient>());
  });
}
