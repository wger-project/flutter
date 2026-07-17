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
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/core/errors.dart';
import 'package:wger/core/network/wger_base.dart';

part 'network_provider.g.dart';

/// Returns whether the wger backend is actually reachable.
///
/// Given `probeUri` any HTTP response counts as reachable, only a
/// network-level error or timeout counts as offline. The request carries
/// `userAgent` so the probe is identifiable in server logs. When `probeUri` is
/// null (no server configured yet, e.g. on the login screen) it falls back to
/// a DNS lookup so there is still a sane online/offline signal.
///
/// Tests can swap this for a deterministic stub via `installFakeConnectivity()`
/// so the test runner doesn't make real network calls.
@visibleForTesting
Future<bool> Function(Uri? probeUri, String? userAgent, Duration timeout) reachabilityCheck =
    _defaultReachabilityCheck;

Future<bool> _defaultReachabilityCheck(
  Uri? probeUri,
  String? userAgent,
  Duration timeout,
) async {
  // No server configured yet: fall back to a generic internet check.
  if (probeUri == null) {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(timeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  final client = http.Client();
  try {
    // Any response (even 401/403) proves the server answered. HEAD keeps it
    // cheap and the version endpoint does not hit the database.
    await client
        .head(
          probeUri,
          headers: userAgent != null ? {HttpHeaders.userAgentHeader: userAgent} : null,
        )
        .timeout(timeout);
    return true;
  } catch (e) {
    if (isNetworkError(e)) {
      return false;
    }
    rethrow;
  } finally {
    client.close();
  }
}

/// Interval for the active backend re-probe (see [NetworkStatus]). Tests set
/// this to `null` to disable the periodic timer; a pending timer would
/// otherwise fail the test runner.
@visibleForTesting
Duration? networkProbeInterval = const Duration(seconds: 30);

@Riverpod(keepAlive: true)
class NetworkStatus extends _$NetworkStatus {
  final _logger = Logger('NetworkStatus');

  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _probeTimer;
  AppLifecycleListener? _lifecycleListener;

  @override
  bool build() {
    _logger.finer('Building NetworkStatus provider');
    _init();
    // Assume we're online until the first connectivity probe says otherwise,
    // this avoids e.g. flashing an "offline" state on app start
    return true;
  }

  void _init() {
    check(optimistic: true);

    _sub = Connectivity().onConnectivityChanged.listen((conn) async {
      await _update(conn, optimistic: true);
    });

    // A stale offline state from the background shouldn't stick until the
    // next timer tick, so re-check optimistically on resume.
    _lifecycleListener = AppLifecycleListener(onResume: () => check(optimistic: true));

    // Connectivity events only fire on adapter changes, so an active re-probe
    // is needed to notice a backend that goes down (or comes back) while the
    // network stays up.
    final probeInterval = networkProbeInterval;
    if (probeInterval != null) {
      _probeTimer = Timer.periodic(probeInterval, (_) => check());
    }

    ref.onDispose(() {
      _sub?.cancel();
      _probeTimer?.cancel();
      _lifecycleListener?.dispose();
    });
  }

  /// Re-checks connectivity and backend reachability, updates the state and
  /// returns it.
  ///
  /// With [optimistic] the state flips to online as soon as a network adapter
  /// is available and a failed probe only downgrades it afterwards; without it
  /// the state changes only once the probe has answered. The periodic re-probe
  /// stays pessimistic so a dead backend doesn't flash "online" every tick.
  Future<bool> check({
    Duration timeout = const Duration(seconds: 1),
    bool optimistic = false,
  }) async {
    final conn = await Connectivity().checkConnectivity();
    return _update(conn, timeout: timeout, optimistic: optimistic);
  }

  Future<bool> _update(
    List<ConnectivityResult> conn, {
    Duration timeout = const Duration(seconds: 1),
    bool optimistic = false,
  }) async {
    // Only short-circuit when there's clearly no network adapter at all. Any
    // other connectivity type (wifi, ethernet, mobile, vpn, other, ...) still
    // has to prove real reachability via the probe below. An empty list
    // counts as "no connection" too.
    if (conn.every((c) => c == ConnectivityResult.none)) {
      state = false;
      return false;
    }

    if (optimistic) {
      state = true;
    }

    final base = ref.read(wgerBaseProvider);
    final probeUri = base.serverUrl != null ? base.makeUrl('version') : null;
    final ok = await reachabilityCheck(probeUri, base.getAppNameHeaderValue(), timeout);
    state = ok;
    return ok;
  }
}
