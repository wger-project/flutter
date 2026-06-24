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

/// [HttpOverrides] that accepts self-signed / otherwise invalid TLS
/// certificates.
///
/// Installing this as [HttpOverrides.global] makes *every* `dart:io`
/// `HttpClient` skip certificate validation, which transparently covers both
/// the `http` package client used for API calls and the `HttpClient` that
/// `NetworkImage` / `extended_image` use to load images. Native media players
/// (e.g. the `video_player` plugin on Android/iOS) use their own networking
/// stack and are not affected by this override.
class WgerHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

/// Installs or removes [WgerHttpOverrides] based on [allow].
///
/// No-op on the web, where `dart:io` networking (and thus [HttpOverrides]) does
/// not apply. Passing `false` restores the default certificate validation.
void applySelfSignedCertOverride(bool allow) {
  if (kIsWeb) {
    return;
  }
  HttpOverrides.global = allow ? WgerHttpOverrides() : null;
}
