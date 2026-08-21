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

/// Outcome of a reachability probe: whether the backend answered plus a short
/// reason, which ends up in the log line for the state change.
typedef ProbeResult = ({bool reachable, String reason});

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
Future<ProbeResult> Function(Uri? probeUri, String? userAgent, Duration timeout) reachabilityCheck =
    _defaultReachabilityCheck;

Future<ProbeResult> _defaultReachabilityCheck(
  Uri? probeUri,
  String? userAgent,
  Duration timeout,
) async {
  // No server configured yet: fall back to a generic internet check.
  if (probeUri == null) {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(timeout);
      final found = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      return (
        reachable: found,
        reason: found ? 'DNS lookup succeeded' : 'DNS lookup returned no address',
      );
    } catch (e) {
      return (reachable: false, reason: 'DNS lookup failed: $e');
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
    return (reachable: true, reason: 'probe answered');
  } on TimeoutException {
    // Caught before the generic branch below, isNetworkError() covers
    // timeouts as well and the distinction matters for the log.
    return (reachable: false, reason: 'probe timed out after ${timeout.inMilliseconds}ms');
  } catch (e) {
    if (isNetworkError(e)) {
      return (reachable: false, reason: 'probe failed: $e');
    }
    rethrow;
  } finally {
    client.close();
  }
}

/// Idle cadence of the active backend re-probe (see [NetworkStatus]). Tests
/// set this to `null` to disable the timer; a pending timer would otherwise
/// fail the test runner.
@visibleForTesting
Duration? networkProbeInterval = const Duration(seconds: 30);

/// Delays for the re-probes after a failed one, before settling back on
/// [networkProbeInterval]. A backend that comes back should be noticed within
/// seconds; the idle cadence is far too slow to recover from a misfire.
const _probeRetryDelays = [Duration(seconds: 2), Duration(seconds: 5), Duration(seconds: 10)];

/// How many probes have to fail in a row before the state flips to offline.
/// A single failure is normal on a mobile network (radio wakeup, TLS cold
/// start) and says nothing about being offline.
const _failuresBeforeOffline = 2;

/// Timeout for a single reachability probe. Generous on purpose: a HEAD that
/// takes two seconds means slow, not offline.
const _probeTimeout = Duration(seconds: 3);

/// Whether the device has a network adapter at all (wifi, mobile, ethernet...)
///
/// This is a platform fact and may therefore gate a connection attempt, unlike
/// the reachability probe behind [NetworkStatus], which is only an indication.
/// Starts out true so nothing waits for the first answer of the platform
/// channel; an adapterless device corrects it a moment later.
@Riverpod(keepAlive: true)
class NetworkAdapterAvailable extends _$NetworkAdapterAvailable {
  final _logger = Logger('NetworkAdapterAvailable');

  @override
  bool build() {
    final sub = Connectivity().onConnectivityChanged.listen(_update);
    ref.onDispose(sub.cancel);
    unawaited(_seed());
    return true;
  }

  Future<void> _seed() async {
    final conn = await Connectivity().checkConnectivity();
    if (ref.mounted) {
      _update(conn);
    }
  }

  /// An empty list means no connection either, hence [Iterable.any] rather
  /// than a check for [ConnectivityResult.none].
  void _update(List<ConnectivityResult> conn) {
    final available = conn.any((c) => c != ConnectivityResult.none);
    if (available != state) {
      _logger.info('Network adapter ${available ? 'available' : 'gone'}');
    }
    state = available;
  }
}

@Riverpod(keepAlive: true)
class NetworkStatus extends _$NetworkStatus {
  final _logger = Logger('NetworkStatus');

  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _probeTimer;
  AppLifecycleListener? _lifecycleListener;

  /// Mirrors [state] for the change detection in [_setState]. Reading [state]
  /// itself is not an option, it is not available while the notifier builds.
  bool _lastState = true;

  /// Probes that failed in a row, driving both the offline hysteresis and the
  /// re-probe backoff.
  int _failures = 0;

  /// The probe pass in flight, if any. Late callers join it instead of racing
  /// it: overlapping passes would each count the same failed moment into
  /// [_failures] and defeat the offline hysteresis.
  Future<bool>? _inFlight;

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

    _sub = Connectivity().onConnectivityChanged.listen((conn) {
      unawaited(_probeRun(() => _update(conn, optimistic: true)));
    });

    // A stale offline state from the background shouldn't stick until the
    // next timer tick, so re-check optimistically on resume.
    _lifecycleListener = AppLifecycleListener(onResume: () => check(optimistic: true));

    _scheduleProbe();

    ref.onDispose(() {
      _sub?.cancel();
      _probeTimer?.cancel();
      _lifecycleListener?.dispose();
    });
  }

  /// Reports that a real request reached the backend, whatever it answered.
  ///
  /// Every request the app makes is a better probe than the artificial one,
  /// so the status follows the real traffic and the timer degrades to an
  /// idle-time fallback.
  void reportRequestSuccess() {
    _failures = 0;
    _setState(true, 'request answered');
    _scheduleProbe();
  }

  /// Reports that a real request failed with a network error, which triggers
  /// a probe right away instead of waiting for the scheduled one. A failing
  /// burst joins the probe pass the first failure started.
  void reportRequestFailure() {
    unawaited(check());
  }

  /// Re-checks connectivity and backend reachability, updates the state and
  /// returns it.
  ///
  /// With [optimistic] the state flips to online as soon as a network adapter
  /// is available and a failed probe only downgrades it afterwards; without it
  /// the state changes only once the probe has answered. The scheduled
  /// re-probe stays pessimistic so a dead backend doesn't flash "online".
  Future<bool> check({
    Duration timeout = _probeTimeout,
    bool optimistic = false,
  }) => _probeRun(() async {
    final conn = await Connectivity().checkConnectivity();
    return _update(conn, timeout: timeout, optimistic: optimistic);
  });

  /// Runs one probe pass, or joins the one already in flight. Coalescing is
  /// safe against reentrancy: the synchronous prefix of [run] executes before
  /// any other caller can observe [_inFlight].
  Future<bool> _probeRun(Future<bool> Function() run) {
    return _inFlight ??= run().whenComplete(() => _inFlight = null);
  }

  /// Schedules the next probe: the idle cadence while things work, one of the
  /// shorter [_probeRetryDelays] while they don't. Connectivity events only
  /// fire on adapter changes, so a dead backend needs an active probe.
  void _scheduleProbe() {
    _probeTimer?.cancel();
    final idle = networkProbeInterval;
    if (idle == null || !ref.mounted) {
      return;
    }
    final delay = _failures > 0 && _failures <= _probeRetryDelays.length
        ? _probeRetryDelays[_failures - 1]
        : idle;
    _probeTimer = Timer(delay, () => check());
  }

  Future<bool> _update(
    List<ConnectivityResult> conn, {
    Duration timeout = _probeTimeout,
    bool optimistic = false,
  }) async {
    // Only short-circuit when there's clearly no network adapter at all. Any
    // other connectivity type (wifi, ethernet, mobile, vpn, other, ...) still
    // has to prove real reachability via the probe below. An empty list
    // counts as "no connection" too.
    if (conn.every((c) => c == ConnectivityResult.none)) {
      // A known offline state, not a failed probe: the ladder starts fresh
      // when the adapter comes back.
      _failures = 0;
      _setState(false, 'no network adapter');
      _scheduleProbe();
      return false;
    }

    if (optimistic) {
      _setState(true, 'network adapter available, probe pending');
    }

    // The pass may resume here after the notifier was invalidated (login
    // does that); the dead ref must not be touched.
    if (!ref.mounted) {
      return _lastState;
    }
    final base = ref.read(wgerBaseProvider);
    final probeUri = base.serverUrl != null ? base.makeUrl('version') : null;
    final probe = await reachabilityCheck(probeUri, base.getAppNameHeaderValue(), timeout);

    if (probe.reachable) {
      _failures = 0;
      _setState(true, probe.reason);
    } else {
      _failures++;
      // One failure only buys a faster retry: on a mobile network it is as
      // likely to be a radio wakeup as a real outage.
      if (_failures >= _failuresBeforeOffline) {
        _setState(false, probe.reason);
      }
    }
    _scheduleProbe();
    return _lastState;
  }

  /// Updates the state and logs genuine changes, so a connection that drops
  /// and comes back every few seconds is visible in the logs. Repetitions of
  /// the same value stay silent.
  ///
  /// A probe outlives the notifier whenever the provider is invalidated (the
  /// auth flow does that on login) while a request is still in flight, and
  /// writing the state afterwards throws.
  void _setState(bool isOnline, String reason) {
    if (!ref.mounted) {
      return;
    }
    if (isOnline != _lastState) {
      _logger.info('Network status: ${isOnline ? 'online' : 'offline'} ($reason)');
    }
    _lastState = isOnline;
    state = isOnline;
  }
}
