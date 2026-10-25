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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

/// Awaits the first value of `provider` by explicitly subscribing via
/// [Ref.listen]. Use this in notifier methods (outside of `build()`)
/// instead of `ref.read(streamProvider.future)`, which can hang
/// indefinitely if no other consumer is `ref.watch`-ing the provider:
/// Riverpod's internal subscription for `.future` doesn't always trigger
/// the underlying stream's first emission in that scenario.
///
/// Completes with the first non-loading value, or rejects with the first
/// error. Closes the subscription as soon as the future resolves.
extension AwaitFirstValue on Ref {
  Future<T> awaitFirstValue<T>(ProviderListenable<AsyncValue<T>> provider) {
    final completer = Completer<T>();

    // Nullable (not `late`) on purpose: with `fireImmediately: true` the
    // listener can fire synchronously during the `listen(...)` call
    // itself, before the assignment to `sub` runs.
    ProviderSubscription<AsyncValue<T>>? sub;
    sub = listen<AsyncValue<T>>(provider, (_, next) {
      if (completer.isCompleted) {
        return;
      }
      if (next.hasValue) {
        completer.complete(next.value as T);
        sub?.close();
      } else if (next.hasError) {
        completer.completeError(next.error!, next.stackTrace);
        sub?.close();
      }
    }, fireImmediately: true);
    if (completer.isCompleted) {
      // Listener fired synchronously; close now that we have the handle.
      sub.close();
    }
    return completer.future;
  }
}

/// Helper function to make a URL.
Uri makeUri(
  String serverUrl,
  String path, {
  int? id,
  String? objectMethod,
  Map<String, dynamic>? query,
  bool trailingSlash = true,
}) {
  final Uri uriServer = Uri.parse(serverUrl);

  final pathList = [uriServer.path, 'api', 'v2', path];
  if (id != null) {
    pathList.add(id.toString());
  }
  if (objectMethod != null) {
    pathList.add(objectMethod);
  }

  final uri = Uri(
    scheme: uriServer.scheme,
    host: uriServer.host,
    port: uriServer.port,
    path: '${pathList.join('/')}${trailingSlash ? '/' : ''}',
    queryParameters: query,
  );

  return uri;
}

/// Builds the URL of a page the server renders itself, e.g. its terms of
/// service. Unlike [makeUri] the path is used as given, without the API prefix
/// and without a trailing slash.
Uri makePageUri(String serverUrl, String path) {
  final server = Uri.parse(serverUrl);
  final basePath = server.path.endsWith('/')
      ? server.path.substring(0, server.path.length - 1)
      : server.path;

  return Uri(
    scheme: server.scheme,
    host: server.host,
    port: server.port,
    path: '$basePath/$path',
  );
}

/// Builds a URL for the `allauth.headless` `app` client API at
/// `/allauth/app/v1/<path>`. Used by the auth notifier for login,
/// signup, MFA, refresh, etc. The headless API does not use a trailing
/// slash and lives on a separate URL prefix from the DRF data API.
Uri makeHeadlessUri(String serverUrl, String path) {
  final Uri uriServer = Uri.parse(serverUrl);
  return Uri(
    scheme: uriServer.scheme,
    host: uriServer.host,
    port: uriServer.port,
    path: [uriServer.path, 'allauth', 'app', 'v1', path].join('/'),
  );
}

final _probeLogger = Logger('powersync-probe');

/// Builds `<serverUrl>/ps/`, the default path under which wger's reverse
/// proxy exposes the PowerSync service.
String _defaultPowerSyncUrl(String serverUrl) {
  final server = Uri.parse(serverUrl);
  final basePath = server.path.endsWith('/')
      ? server.path.substring(0, server.path.length - 1)
      : server.path;
  return Uri(
    scheme: server.scheme,
    host: server.host,
    port: server.port,
    path: '$basePath/ps/',
  ).toString();
}

/// Returns the first PowerSync endpoint that answers its liveness probe with
/// a 200, or null when none does.
///
/// The `powersync_url` [provided] by the server's token endpoint is tried
/// first, then `<serverUrl>/ps/` as a fallback. Probing instead of trusting
/// [provided] rescues servers whose `SITE_URL` doesn't match the URL the app
/// reaches them under (e.g. left at its `http://localhost` default): that
/// value is unreachable from the device, while the reverse proxy usually
/// still exposes the service under the default path.
Future<String?> findLivePowerSyncUrl({
  required http.Client client,
  required String serverUrl,
  required String? provided,
  Duration probeTimeout = const Duration(seconds: 5),
}) async {
  final parsed = provided == null ? null : Uri.tryParse(provided);
  final candidates = {
    if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) provided!,
    _defaultPowerSyncUrl(serverUrl),
  };

  for (final candidate in candidates) {
    final probeUri = Uri.parse(
      '$candidate${candidate.endsWith('/') ? '' : '/'}probes/liveness',
    );

    // Log failed probes
    try {
      final response = await client.get(probeUri).timeout(probeTimeout);
      if (response.statusCode == 200) {
        return candidate;
      }
      _probeLogger.info('PowerSync probe: $probeUri returned ${response.statusCode}');
    } on Exception catch (e) {
      // Unreachable or timed out: try the next candidate.
      _probeLogger.info('PowerSync probe: $probeUri failed: $e');
    }
  }
  return null;
}

/// Builds the absolute URL for a server-side media file given its
/// [relativePath] (the raw value of a Django `ImageField` / `FileField`
/// as stored in the DB, e.g. `ingredients/42/foo.jpg`).
///
/// Returns `null` if [relativePath] is null or empty. If [relativePath]
/// already contains a scheme it is returned as-is, so values that the
/// REST API has already absolutised (or that point at an external CDN)
/// pass through unchanged.
///
/// When [absolutePrefix] is provided it is used as-is (e.g. the prefix
/// detected once via the REST API), so deployments with a non-default
/// `MEDIA_URL` or a CDN in front of the media files work transparently.
/// When omitted, the function falls back to the assumption that media
/// is served from `<serverUrl>/media/`, Django's default.
Uri? mediaUri(String serverUrl, String? relativePath, {String? absolutePrefix}) {
  if (relativePath == null || relativePath.isEmpty) {
    return null;
  }

  final parsed = Uri.tryParse(relativePath);
  if (parsed != null && parsed.hasScheme) {
    return parsed;
  }

  final cleanRelative = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;

  // Prefer the probed prefix (full URL ending in `/`) when available.
  if (absolutePrefix != null && absolutePrefix.isNotEmpty) {
    final cleanPrefix = absolutePrefix.endsWith('/') ? absolutePrefix : '$absolutePrefix/';
    return Uri.parse('$cleanPrefix$cleanRelative');
  }

  // Fallback: assume Django's default MEDIA_URL of `/media/` on the same host.
  final server = Uri.parse(serverUrl);
  final basePath = server.path.endsWith('/')
      ? server.path.substring(0, server.path.length - 1)
      : server.path;

  return Uri(
    scheme: server.scheme,
    host: server.host,
    port: server.port,
    path: '$basePath/media/$cleanRelative',
  );
}
