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

/// Awaits the first value of [provider] by explicitly subscribing via
/// [Ref.listen]. Use this in notifier methods (outside of `build()`)
/// instead of `ref.read(streamProvider.future)`, which can hang
/// indefinitely if no other consumer is `ref.watch`-ing the provider —
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
