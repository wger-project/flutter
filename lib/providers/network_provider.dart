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
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/providers/wger_base.dart';

part 'network_provider.g.dart';

/// Returns whether the wger backend is actually reachable.
///
/// Given [probeUri] any HTTP response counts as reachable, only a
/// network-level error or timeout counts as offline. The request carries
/// [userAgent] so the probe is identifiable in server logs. When [probeUri] is
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

  @override
  bool build() {
    _logger.finer('Building NetworkStatus provider');
    _init();
    // Assume we're online until the first connectivity probe says otherwise,
    // this avoids e.g. flashing an "offline" state on app start
    return true;
  }

  void _init() {
    check();

    _sub = Connectivity().onConnectivityChanged.listen((conn) async {
      state = await _hasConnectionAndInternet(conn);
    });

    // Re-probe when the configured server changes (login / logout) so the
    // status reflects the new backend instead of a stale pre-login value.
    ref.listen(wgerBaseProvider, (previous, next) {
      if (previous?.serverUrl != next.serverUrl) {
        check();
      }
    });

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
    });
  }

  Future<bool> check({Duration timeout = const Duration(seconds: 1)}) async {
    final conn = await Connectivity().checkConnectivity();
    final ok = await _hasConnectionAndInternet(conn, timeout: timeout);
    state = ok;
    return ok;
  }

  Future<bool> _hasConnectionAndInternet(
    List<ConnectivityResult> conn, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    // Only short-circuit when there's clearly no network adapter at all. Any
    // other connectivity type (wifi, ethernet, mobile, vpn, other, ...) still
    // has to prove real reachability via the probe below. An empty list
    // counts as "no connection" too.
    if (conn.every((c) => c == ConnectivityResult.none)) {
      return false;
    }

    final base = ref.read(wgerBaseProvider);
    final probeUri = base.serverUrl != null ? base.makeUrl('version') : null;
    return reachabilityCheck(probeUri, base.getAppNameHeaderValue(), timeout);
  }
}
