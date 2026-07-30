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

import 'package:flutter/foundation.dart';
import 'package:wger/core/consts.dart';

/// [HttpOverrides] that accepts a self-signed / otherwise invalid TLS
/// certificate, but only from [trustedHost] and only while
/// [allowSelfSignedCerts] is set.
///
/// Installed as [HttpOverrides.global], so every `dart:io` `HttpClient` routes
/// through it: both the `http` package client used for API calls and the
/// `HttpClient` behind `NetworkImage` / `extended_image`. Native media players
/// (e.g. the `video_player` plugin on Android/iOS) use their own networking
/// stack and are not affected.
class WgerHttpOverrides extends HttpOverrides {
  /// Whether the user opted into trusting an invalid certificate.
  ///
  /// Both this and [trustedHost] are read when the handshake happens rather
  /// than when the client is built, so changing either also applies to clients
  /// that already exist. dart:io reads [HttpOverrides.current] once in the
  /// `HttpClient` constructor, and the auth client is built during startup, so
  /// swapping the override itself would only take effect after a restart.
  static bool allowSelfSignedCerts = ALLOW_SELF_SIGNED_CERTS_DEFAULT;

  /// Host the opt-in applies to. While null, every invalid certificate is
  /// rejected no matter what [allowSelfSignedCerts] says.
  static String? trustedHost;

  /// Narrows [trustedHost] to the host of [serverUrl]. A null, empty or
  /// hostless URL clears it.
  static void trustServer(String? serverUrl) => trustedHost = _hostOf(serverUrl);

  /// Hosts the opt-in can never apply to. The servers we run ourselves have a
  /// valid certificate, so an invalid one there is a genuine problem and not
  /// something a self-hosting setting may wave through.
  static final Set<String> _officialHosts = {
    Uri.parse(DEFAULT_SERVER_PROD).host,
    Uri.parse(DEFAULT_SERVER_TEST).host,
  };

  static String? _hostOf(String? serverUrl) {
    final host = serverUrl == null ? null : Uri.tryParse(serverUrl)?.host;
    return (host == null || host.isEmpty) ? null : host;
  }

  static bool _accepts(String host) =>
      allowSelfSignedCerts && host == trustedHost && !_officialHosts.contains(host);

  /// Whether an invalid certificate presented by [host] is accepted.
  ///
  /// Installed as the `badCertificateCallback` of every client, so it runs per
  /// handshake and sees the current [allowSelfSignedCerts] / [trustedHost]
  /// rather than the values from when the client was built.
  static bool acceptsBadCertificate(X509Certificate cert, String host, int port) => _accepts(host);

  /// The host of [serverUrl] while it is exempt from certificate validation,
  /// null otherwise.
  ///
  /// Answers the same question as [acceptsBadCertificate], so a UI built on this
  /// cannot warn about an exemption that does not exist, or stay silent about
  /// one that does.
  static String? exemptHost(String? serverUrl) {
    final host = _hostOf(serverUrl);
    return (host != null && _accepts(host)) ? host : null;
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = acceptsBadCertificate;
  }
}

/// Routes all `dart:io` HTTP traffic through [WgerHttpOverrides].
///
/// Must run before the first `HttpClient` is created, since dart:io only
/// consults [HttpOverrides.current] in the client constructor. No-op on the
/// web, where `dart:io` networking (and thus [HttpOverrides]) does not apply.
void installHttpOverrides() {
  if (kIsWeb) {
    return;
  }
  HttpOverrides.global = WgerHttpOverrides();
}
