/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'dart:convert';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/providers/auth_notifier.dart';

/// Custom URL scheme + host the wger web-handoff view redirects to.
/// Must match the registration in iOS Info.plist, AndroidManifest.xml, etc.
const APP_AUTH_SCHEME = 'wger';
const APP_AUTH_HOST = 'app-auth';

/// Maximum age of an outstanding handoff state nonce. After that a returning
/// deep link is treated as stale and rejected, the user needs to tap "Log in
/// via web" again
const APP_AUTH_STATE_TTL = Duration(minutes: 10);

/// Generates a 256-bit nonce, persists it (with [serverUrl]) as the pending
/// handoff state and returns it for inclusion in the launch URL. Each call
/// rotates the value, so a previously-issued (but unused) state is invalidated.
Future<String> issueAppAuthState(String serverUrl) async {
  final rng = Random.secure();
  final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
  final state = base64UrlEncode(bytes).replaceAll('=', '');
  final prefs = PreferenceHelper.asyncPref;
  await prefs.setString(PREFS_APP_AUTH_STATE, state);
  await prefs.setString(PREFS_APP_AUTH_SERVER, serverUrl);
  await prefs.setInt(PREFS_APP_AUTH_STATE_AT, clock.now().millisecondsSinceEpoch);
  return state;
}

/// Consumes any outstanding handoff state and verifies that [received]
/// matches it within [APP_AUTH_STATE_TTL]. Always clears the stored value
/// (single use), regardless of outcome. Returns the server URL the handoff was
/// issued for on a valid match, or null on any rejection.
Future<String?> consumeAppAuthState(String? received) async {
  final prefs = PreferenceHelper.asyncPref;
  final stored = await prefs.getString(PREFS_APP_AUTH_STATE);
  final issuedAt = await prefs.getInt(PREFS_APP_AUTH_STATE_AT) ?? 0;
  final serverUrl = await prefs.getString(PREFS_APP_AUTH_SERVER);
  await prefs.remove(PREFS_APP_AUTH_STATE);
  await prefs.remove(PREFS_APP_AUTH_STATE_AT);
  await prefs.remove(PREFS_APP_AUTH_SERVER);
  if (stored == null || received == null || received.isEmpty) {
    return null;
  }
  final ageMs = clock.now().millisecondsSinceEpoch - issuedAt;
  if (ageMs > APP_AUTH_STATE_TTL.inMilliseconds) {
    return null;
  }
  return stored == received ? serverUrl : null;
}

/// Routes incoming `wger://app-auth#token=<jwt>` deep links into the auth
/// notifier, completing the server-side web-handoff login flow.
///
/// Must be instantiated once at app bootstrap (not bound to widget lifetime),
/// so cold-start links delivered before any screen is built are still picked
/// up via [AppLinks.getInitialLink].
class AppLinkRouter {
  AppLinkRouter(this._ref, {AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final Ref _ref;
  final AppLinks _appLinks;
  final _logger = Logger('AppLinkRouter');
  StreamSubscription<Uri>? _sub;

  Future<void> start() async {
    // Cold-start: the OS may have launched us with the URI as an argument.
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        unawaited(_handle(initial));
      }
    } catch (e, st) {
      _logger.warning('getInitialLink failed', e, st);
    }
    // Warm-start: the user is already in the app; the browser hands a URI off.
    _sub = _appLinks.uriLinkStream.listen(
      (uri) => unawaited(_handle(uri)),
      onError: (Object e, StackTrace st) => _logger.warning('uriLinkStream error', e, st),
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _handle(Uri uri) async {
    final token = tokenFromUri(uri);
    if (token == null) {
      // Never log the fragment: it carries the refresh token on our links.
      _logger.fine('Ignoring unrelated or malformed deep link: ${uri.removeFragment()}');
      return;
    }
    final state = fragmentParam(uri, 'state');
    // Returns the server URL the handoff was started for, so a self-hosted
    // token is redeemed against its own server, not the default.
    final serverUrl = await consumeAppAuthState(state);
    if (serverUrl == null) {
      // Unsolicited link (no outstanding state), stale (past TTL), or state
      // mismatch, all three look the same from here and are all rejected by
      // design. Login-CSRF defence: only accept handoffs the app started itself.
      // Strip the fragment before logging: it carries the refresh token
      _logger.warning(
        'Rejecting handoff deep link with bad/missing state: ${uri.removeFragment()}',
      );
      return;
    }
    try {
      await _ref.read(authProvider.notifier).login('', '', serverUrl, token);
    } catch (e, st) {
      _logger.warning('Handoff login failed', e, st);
    }
  }

  /// Returns the refresh token carried by a `wger://app-auth#token=<jwt>`
  /// deep link, or null when the URI does not match (wrong scheme, wrong
  /// host, or missing/empty `token` fragment parameter).
  static String? tokenFromUri(Uri uri) => fragmentParam(uri, 'token');
}

/// Pulls a single `key=value` pair out of the fragment of an app-auth deep
/// link. Returns null when the URI is not one of ours (wrong scheme or host),
/// when there is no fragment, when [name] is missing, or when its value is empty.
String? fragmentParam(Uri uri, String name) {
  if (uri.scheme != APP_AUTH_SCHEME || uri.host != APP_AUTH_HOST) {
    return null;
  }
  final fragment = uri.fragment;
  if (fragment.isEmpty) {
    return null;
  }
  for (final pair in fragment.split('&')) {
    final eq = pair.indexOf('=');
    if (eq <= 0) {
      continue;
    }
    if (pair.substring(0, eq) == name) {
      final value = Uri.decodeComponent(pair.substring(eq + 1));
      return value.isEmpty ? null : value;
    }
  }
  return null;
}

/// Holds the singleton router. Reading this provider once at app bootstrap
/// is enough to start the subscription
final appLinkRouterProvider = Provider<AppLinkRouter>((ref) {
  final router = AppLinkRouter(ref);
  unawaited(router.start());
  ref.onDispose(router.stop);
  return router;
});
