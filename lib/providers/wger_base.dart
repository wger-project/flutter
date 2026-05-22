/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2025 - 2026 wger Team
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/providers/auth_http_client.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/helpers.dart';
import 'package:wger/providers/media_url_prefix_notifier.dart';

/// Central provider that builds a [WgerBaseProvider] from the current
/// [AuthNotifier] state. Consumers read this to make authenticated HTTP
/// requests. Rebuilds whenever the auth state changes.
///
/// Deliberately does *not* depend on [mediaUrlPrefixProvider], that
/// would create a cycle, since the prefix notifier reads
/// [wgerBaseProvider] when probing. Consumers that need the resolved
/// media URL go through [mediaUrlBuilderProvider] instead.
final wgerBaseProvider = Provider<WgerBaseProvider>((ref) {
  final auth = ref.watch(authProvider).value;
  return WgerBaseProvider(
    serverUrl: auth?.serverUrl,
    applicationVersion: auth?.applicationVersion,
    client: ref.watch(authenticatedHttpClientProvider),
  );
});

/// Returns a function that builds the absolute URL for a server-side
/// media file given its relative DB path (e.g. `ingredients/42/foo.jpg`).
/// Combines the current [authProvider]'s server URL with the probed
/// [mediaUrlPrefixProvider] value, falling back to `<serverUrl>/media/`
/// when no prefix has been detected yet.
///
/// Returns `null` when the user is not logged in (no server URL) or
/// when [path] is null/empty.
final mediaUrlBuilderProvider = Provider<Uri? Function(String? path)>((ref) {
  final serverUrl = ref.watch(authProvider).asData?.value.serverUrl;
  final prefix = ref.watch(mediaUrlPrefixProvider).asData?.value;
  return (path) {
    if (serverUrl == null) {
      return null;
    }
    return mediaUri(serverUrl, path, absolutePrefix: prefix);
  };
});
