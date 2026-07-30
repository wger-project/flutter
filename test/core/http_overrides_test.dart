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
import 'package:wger/core/consts.dart';
import 'package:wger/core/http_overrides.dart';

class _FakeCertificate extends Fake implements X509Certificate {}

void main() {
  final cert = _FakeCertificate();

  // Restore the default networking and the opt-in so nothing leaks into other
  // tests sharing the same isolate. The test binding installs its own overrides
  // to keep tests off the network, so put back what was there rather than null.
  final HttpOverrides? originalOverrides = HttpOverrides.current;
  tearDown(() {
    HttpOverrides.global = originalOverrides;
    WgerHttpOverrides.allowSelfSignedCerts = false;
    WgerHttpOverrides.trustedHost = null;
  });

  /// The decision the TLS handshake would make for [host].
  bool accepts(String host) => WgerHttpOverrides.acceptsBadCertificate(cert, host, 443);

  test('installHttpOverrides routes traffic through WgerHttpOverrides', () {
    installHttpOverrides();
    expect(HttpOverrides.current, isA<WgerHttpOverrides>());
  });

  test('rejects a bad certificate by default', () {
    expect(accepts('gym.example.com'), isFalse);
  });

  test('accepts the trusted host once opted in', () {
    WgerHttpOverrides.allowSelfSignedCerts = true;
    WgerHttpOverrides.trustServer('https://gym.example.com:8000');

    expect(accepts('gym.example.com'), isTrue);
  });

  test('rejects any other host while opted in', () {
    WgerHttpOverrides.allowSelfSignedCerts = true;
    WgerHttpOverrides.trustServer('https://gym.example.com');

    expect(accepts('other.example.com'), isFalse);
  });

  test('never trusts the official servers, even when they are the trusted host', () {
    // Reachable by typing wger.de into the self-hosted field with the opt-in on.
    WgerHttpOverrides.allowSelfSignedCerts = true;

    for (final url in [DEFAULT_SERVER_PROD, DEFAULT_SERVER_TEST]) {
      WgerHttpOverrides.trustServer(url);
      expect(accepts(Uri.parse(url).host), isFalse, reason: 'for $url');
    }
  });

  test('rejects the trusted host again once opted out', () {
    WgerHttpOverrides.trustServer('https://gym.example.com');
    WgerHttpOverrides.allowSelfSignedCerts = true;
    WgerHttpOverrides.allowSelfSignedCerts = false;

    expect(accepts('gym.example.com'), isFalse);
  });

  test('the decision is re-read per call, not baked in when it is handed out', () {
    // The regression that matters: dart:io reads HttpOverrides.current in the
    // HttpClient constructor only, and the auth client is built during startup.
    // A client therefore holds this callback from before the user can opt in,
    // exactly like the reference grabbed here.
    const held = WgerHttpOverrides.acceptsBadCertificate;
    expect(held(cert, 'gym.example.com', 443), isFalse);

    WgerHttpOverrides.allowSelfSignedCerts = true;
    WgerHttpOverrides.trustServer('https://gym.example.com');

    expect(held(cert, 'gym.example.com', 443), isTrue);
  });

  test('trustServer clears the host for a null, empty or hostless URL', () {
    for (final url in [null, '', 'not a url']) {
      WgerHttpOverrides.trustServer(url);
      expect(WgerHttpOverrides.trustedHost, isNull, reason: 'for ${url ?? 'null'}');
    }
  });
}
