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

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/providers/app_settings_notifier.dart' show appSettingsPrefsProvider;
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/providers/wger_base.dart';

part 'media_url_prefix_notifier.g.dart';

/// Marker from the `upload_to` field on the Django `Image` model.
/// Stable in practice, changing it would require a Django data
/// migration and break existing image references.
const _exerciseImagesMarker = 'exercise-images/';

/// REST endpoint we probe to extract the absolute media URL prefix.
const _exerciseImageEndpoint = 'exerciseimage';

/// Extracts the media URL prefix from a probe response body.
///
/// Returns the prefix or `null` for any malformed or unexpected response shape.
@visibleForTesting
String? extractMediaPrefix(dynamic responseBody) {
  if (responseBody is! Map) {
    return null;
  }

  final results = responseBody['results'] as List?;
  if (results == null || results.isEmpty) {
    return null;
  }

  final imageUrl = results.first['image'] as String?;
  if (imageUrl == null || imageUrl.isEmpty) {
    return null;
  }

  final idx = imageUrl.indexOf(_exerciseImagesMarker);
  if (idx < 0) {
    return null;
  }

  return imageUrl.substring(0, idx);
}

/// Detects and caches the absolute URL prefix for server-side media
/// files (e.g. `https://wger.de/media/`, or for CDN-fronted deployments
/// `https://cdn.example.com/bucket1/`).
///
/// On first build the value is loaded from SharedPreferences. If
/// nothing is cached and the user is logged in, a one-shot probe
/// against `/api/v2/exerciseimage/?limit=1` extracts the prefix from
/// the first result's `image` URL.
///
/// State semantics:
///   - `null`, not yet detected; consumers should fall back to the
///     default prefix
///   - non-null, full URL prefix
///
/// Cleared on logout.
@Riverpod(keepAlive: true)
class MediaUrlPrefixNotifier extends _$MediaUrlPrefixNotifier {
  static final _logger = Logger('MediaUrlPrefixNotifier');

  @override
  Future<String?> build() async {
    final prefs = ref.read(appSettingsPrefsProvider);
    final cached = await prefs.getString(PREFS_MEDIA_URL_PREFIX);

    // React to auth lifecycle: probe on login, clear on logout. Uses
    // listen rather than watch so build doesn't re-run on every auth
    // change (the prefix lives across auth-state transitions of the
    // same session).
    ref.listen(authProvider, (_, next) {
      final status = next.asData?.value.status;
      if (status == AuthStatus.loggedOut) {
        unawaited(clear());
      } else if (status == AuthStatus.loggedIn && state.asData?.value == null) {
        unawaited(probe());
      }
    });

    // App-start case: user was already logged in (auto-login) and we
    // had no cached prefix. The auth-listener above won't fire because
    // there's no transition, so kick off the probe here.
    if (cached == null) {
      final status = ref.read(authProvider).asData?.value.status;
      if (status == AuthStatus.loggedIn) {
        unawaited(probe());
      }
    }

    return cached;
  }

  /// Hits the REST API once and persists the extracted prefix on
  /// success. No-op when extraction returns null.
  @visibleForTesting
  Future<void> probe() async {
    final base = ref.read(wgerBaseProvider);
    if (base.serverUrl == null) {
      return;
    }

    String? prefix;
    try {
      final uri = base.makeUrl(_exerciseImageEndpoint, query: {'limit': '1'});
      final data = await base.fetch(uri);
      prefix = extractMediaPrefix(data);
    } catch (e, s) {
      _logger.warning('Media prefix probe failed', e, s);
      return;
    }

    if (prefix == null) {
      _logger.fine('Probe yielded no usable prefix, keeping default');
      return;
    }

    // Re-check auth: the user may have logged out during the await.
    // Otherwise we'd write the freshly probed prefix back over the
    // cleared state.
    final status = ref.read(authProvider).asData?.value.status;
    if (status != AuthStatus.loggedIn) {
      return;
    }

    _logger.info('Detected media URL prefix: $prefix');
    final prefs = ref.read(appSettingsPrefsProvider);
    await prefs.setString(PREFS_MEDIA_URL_PREFIX, prefix);
    state = AsyncData(prefix);
  }

  /// Wipes both the in-memory state and the persisted value. Public so
  /// tests can drive it directly; production triggers it via the auth
  /// listener on logout.
  @visibleForTesting
  Future<void> clear() async {
    final prefs = ref.read(appSettingsPrefsProvider);
    await prefs.remove(PREFS_MEDIA_URL_PREFIX);
    state = const AsyncData(null);
  }
}
