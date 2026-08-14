/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wger/core/network/base_provider.dart';
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/core/network/wger_base.dart';

/// Connectivity fake that each test can drive: [current] sets what
/// `checkConnectivity()` reports, [emit] pushes a change event.
class _FakeConnectivity extends ConnectivityPlatform with MockPlatformInterfaceMixin {
  List<ConnectivityResult> current = [ConnectivityResult.wifi];
  final _controller = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  void emit(List<ConnectivityResult> results) {
    current = results;
    _controller.add(results);
  }

  void dispose() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeConnectivity connectivity;
  late Future<ProbeResult> Function(Uri?, String?, Duration) originalReachability;
  late Duration? originalProbeInterval;

  setUp(() {
    originalReachability = reachabilityCheck;
    originalProbeInterval = networkProbeInterval;
    connectivity = _FakeConnectivity();
    ConnectivityPlatform.instance = connectivity;
  });

  tearDown(() {
    reachabilityCheck = originalReachability;
    networkProbeInterval = originalProbeInterval;
    connectivity.dispose();
  });

  ProviderContainer makeContainer({String? serverUrl}) {
    return ProviderContainer.test(
      overrides: [
        wgerBaseProvider.overrideWithValue(WgerBaseProvider(serverUrl: serverUrl)),
      ],
    );
  }

  /// Drives the state to offline with a failing [reachabilityCheck] in place.
  /// Takes the hysteresis into account, which needs more than one failure.
  Future<void> goOffline(ProviderContainer container) async {
    final notifier = container.read(networkStatusProvider.notifier);
    await notifier.check();
    await notifier.check();
  }

  test('starts optimistically online before the first probe completes', () async {
    reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');

    expect(container.read(networkStatusProvider), isTrue);

    // Drain the build-time probe so it doesn't outlive the test.
    await pumpEventQueue();
  });

  test('reports offline without probing when there is no network adapter', () async {
    connectivity.current = [ConnectivityResult.none];
    var probed = false;
    reachabilityCheck = (_, _, _) async {
      probed = true;
      return (reachable: true, reason: 'test');
    };
    final container = makeContainer(serverUrl: 'https://wger.example');

    final result = await container.read(networkStatusProvider.notifier).check();

    expect(result, isFalse);
    expect(container.read(networkStatusProvider), isFalse);
    expect(probed, isFalse);
  });

  test('reports online when the backend probe succeeds', () async {
    reachabilityCheck = (_, _, _) async => (reachable: true, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');

    await container.read(networkStatusProvider.notifier).check();

    expect(container.read(networkStatusProvider), isTrue);
  });

  test('a single failed probe does not take the app offline', () async {
    // The 1s-timeout probe used to be a coin flip on mobile networks, and one
    // misfire was enough to disconnect everything for half a minute.
    reachabilityCheck = (_, _, _) async => (reachable: true, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');
    // Build first: the probe from build() would otherwise fail as well and
    // the two together are exactly what does flip the state.
    container.read(networkStatusProvider);
    await pumpEventQueue();

    reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'test');
    await container.read(networkStatusProvider.notifier).check();

    expect(container.read(networkStatusProvider), isTrue);
  });

  test('reports offline once two probes fail in a row', () async {
    reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');

    await goOffline(container);

    expect(container.read(networkStatusProvider), isFalse);
  });

  test('a successful probe in between resets the failure count', () async {
    reachabilityCheck = (_, _, _) async => (reachable: true, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');
    final notifier = container.read(networkStatusProvider.notifier);
    await pumpEventQueue();

    reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'test');
    await notifier.check();
    reachabilityCheck = (_, _, _) async => (reachable: true, reason: 'test');
    await notifier.check();
    reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'test');
    await notifier.check();

    expect(container.read(networkStatusProvider), isTrue);
  });

  test('probes the server version endpoint when a server URL is configured', () async {
    Uri? probedUri;
    reachabilityCheck = (uri, _, _) async {
      probedUri = uri;
      return (reachable: true, reason: 'test');
    };
    final base = WgerBaseProvider(serverUrl: 'https://wger.example');
    final container = ProviderContainer.test(
      overrides: [wgerBaseProvider.overrideWithValue(base)],
    );

    await container.read(networkStatusProvider.notifier).check();

    expect(probedUri, base.makeUrl('version'));
  });

  test('probes without a URL (generic fallback) when no server is configured', () async {
    Uri? probedUri;
    var probed = false;
    reachabilityCheck = (uri, _, _) async {
      probedUri = uri;
      probed = true;
      return (reachable: true, reason: 'test');
    };
    final container = makeContainer();

    await container.read(networkStatusProvider.notifier).check();

    expect(probed, isTrue);
    expect(probedUri, isNull);
  });

  test('passes the app User-Agent to the probe', () async {
    String? probedUserAgent;
    reachabilityCheck = (_, userAgent, _) async {
      probedUserAgent = userAgent;
      return (reachable: true, reason: 'test');
    };
    final base = WgerBaseProvider(serverUrl: 'https://wger.example');
    final container = ProviderContainer.test(
      overrides: [wgerBaseProvider.overrideWithValue(base)],
    );

    await container.read(networkStatusProvider.notifier).check();

    expect(probedUserAgent, base.getAppNameHeaderValue());
  });

  test('re-probes when a connectivity change event arrives', () async {
    var probes = 0;
    reachabilityCheck = (_, _, _) async {
      probes++;
      return (reachable: true, reason: 'test');
    };
    final container = makeContainer(serverUrl: 'https://wger.example');
    await container.read(networkStatusProvider.notifier).check();
    final beforeEvent = probes;

    // Adapter still reports a connection, but the backend has to prove itself.
    connectivity.emit([ConnectivityResult.wifi]);
    await pumpEventQueue();

    expect(probes, greaterThan(beforeEvent));
  });

  test('goes online immediately on a connectivity change, offline only after the probe', () async {
    reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');
    await goOffline(container);
    expect(container.read(networkStatusProvider), isFalse);

    // An adapter appears: optimistically online while the probe is pending.
    final probeCompleter = Completer<ProbeResult>();
    reachabilityCheck = (_, _, _) => probeCompleter.future;
    connectivity.emit([ConnectivityResult.wifi]);
    await pumpEventQueue();
    expect(container.read(networkStatusProvider), isTrue);

    // The failed probe downgrades the optimistic state again.
    probeCompleter.complete((reachable: false, reason: 'test'));
    await pumpEventQueue();
    expect(container.read(networkStatusProvider), isFalse);
  });

  test('goes online optimistically when the app resumes from the background', () async {
    reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');
    await goOffline(container);
    expect(container.read(networkStatusProvider), isFalse);

    final probeCompleter = Completer<ProbeResult>();
    reachabilityCheck = (_, _, _) => probeCompleter.future;
    final binding = TestWidgetsFlutterBinding.instance;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpEventQueue();
    expect(container.read(networkStatusProvider), isTrue);

    probeCompleter.complete((reachable: false, reason: 'test'));
    await pumpEventQueue();
    expect(container.read(networkStatusProvider), isFalse);
  });

  test('plain check stays pessimistic while the probe is pending', () async {
    reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');
    await goOffline(container);
    expect(container.read(networkStatusProvider), isFalse);

    // The idle re-probe must not flash "online" while the backend is down.
    final probeCompleter = Completer<ProbeResult>();
    reachabilityCheck = (_, _, _) => probeCompleter.future;
    final pending = container.read(networkStatusProvider.notifier).check();
    await pumpEventQueue();
    expect(container.read(networkStatusProvider), isFalse);

    probeCompleter.complete((reachable: true, reason: 'test'));
    expect(await pending, isTrue);
    expect(container.read(networkStatusProvider), isTrue);
  });

  test('re-probes when invalidated (e.g. after login)', () async {
    // NetworkStatus does not watch wgerBase, so auth re-probes the new server
    // by invalidating the provider; the rebuild runs the probe again.
    final probedUris = <Uri?>[];
    reachabilityCheck = (uri, _, _) async {
      probedUris.add(uri);
      return (reachable: true, reason: 'test');
    };
    final container = makeContainer(serverUrl: 'https://wger.example');
    await container.read(networkStatusProvider.notifier).check();
    final beforeLogin = probedUris.length;

    container.invalidate(networkStatusProvider);
    container.read(networkStatusProvider);
    await pumpEventQueue();

    expect(probedUris.length, greaterThan(beforeLogin));
    expect(probedUris.last, isNotNull);
  });

  test('logs genuine state changes with a reason, repetitions stay silent', () async {
    final records = <LogRecord>[];
    final sub = Logger.root.onRecord.listen(records.add);
    addTearDown(sub.cancel);
    Iterable<LogRecord> lines(String needle) =>
        records.where((r) => r.loggerName == 'NetworkStatus' && r.message.contains(needle));

    reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'probe timed out');
    final container = makeContainer(serverUrl: 'https://wger.example');
    await goOffline(container);
    await pumpEventQueue();

    expect(lines('offline'), hasLength(1));
    expect(lines('offline').first.message, contains('probe timed out'));

    // Same result again: nothing new to report
    await container.read(networkStatusProvider.notifier).check();
    expect(lines('offline'), hasLength(1));

    reachabilityCheck = (_, _, _) async => (reachable: true, reason: 'probe answered');
    await container.read(networkStatusProvider.notifier).check();
    expect(lines('online'), hasLength(1));
    expect(lines('online').first.message, contains('probe answered'));
  });

  test('logs going offline when there is no network adapter', () async {
    final records = <LogRecord>[];
    final sub = Logger.root.onRecord.listen(records.add);
    addTearDown(sub.cancel);

    reachabilityCheck = (_, _, _) async => (reachable: true, reason: 'probe answered');
    final container = makeContainer(serverUrl: 'https://wger.example');
    await container.read(networkStatusProvider.notifier).check();

    connectivity.current = [ConnectivityResult.none];
    await container.read(networkStatusProvider.notifier).check();

    final offline = records.where(
      (r) => r.loggerName == 'NetworkStatus' && r.message.contains('offline'),
    );
    expect(offline, hasLength(1));
    expect(offline.first.message, contains('no network adapter'));
  });

  test('retries a failed probe on the backoff ladder and settles back after a success', () {
    fakeAsync((async) {
      networkProbeInterval = const Duration(seconds: 30);
      var probes = 0;
      var reachable = false;
      reachabilityCheck = (_, _, _) async {
        probes++;
        return (reachable: reachable, reason: 'test');
      };
      final container = makeContainer(serverUrl: 'https://wger.example');
      container.read(networkStatusProvider);
      async.flushMicrotasks();
      expect(probes, 1, reason: 'the probe from build()');

      // Each failure schedules the next probe sooner than the idle cadence.
      for (final delay in const [Duration(seconds: 2), Duration(seconds: 5)]) {
        async.elapse(delay);
        async.flushMicrotasks();
      }
      expect(probes, 3);

      // Recovered on the third retry: back to the idle cadence.
      reachable = true;
      async.elapse(const Duration(seconds: 10));
      async.flushMicrotasks();
      expect(probes, 4);
      async.elapse(const Duration(seconds: 29));
      async.flushMicrotasks();
      expect(probes, 4, reason: 'a working backend is not probed every few seconds');

      // And the ladder starts from the top again on the next failure.
      reachable = false;
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(probes, 5);
      async.elapse(const Duration(seconds: 2));
      async.flushMicrotasks();
      expect(probes, 6);
    });
  });

  test('a reported request success flips the state online', () async {
    reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');
    await goOffline(container);
    expect(container.read(networkStatusProvider), isFalse);

    container.read(networkStatusProvider.notifier).reportRequestSuccess();

    expect(container.read(networkStatusProvider), isTrue);
  });

  test('reported request successes push the next probe out', () {
    fakeAsync((async) {
      networkProbeInterval = const Duration(seconds: 30);
      var probes = 0;
      reachabilityCheck = (_, _, _) async {
        probes++;
        return (reachable: true, reason: 'test');
      };
      final container = makeContainer(serverUrl: 'https://wger.example');
      final notifier = container.read(networkStatusProvider.notifier);
      async.flushMicrotasks();
      expect(probes, 1);

      // Traffic keeps arriving just before every scheduled probe.
      for (var i = 0; i < 3; i++) {
        async.elapse(const Duration(seconds: 29));
        notifier.reportRequestSuccess();
      }
      async.elapse(const Duration(seconds: 29));

      expect(probes, 1, reason: 'real requests already answered the question');
    });
  });

  test('a reported request failure probes immediately, but only one at a time', () async {
    reachabilityCheck = (_, _, _) async => (reachable: true, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');
    final notifier = container.read(networkStatusProvider.notifier);
    await pumpEventQueue();

    var probes = 0;
    final pendingProbe = Completer<ProbeResult>();
    reachabilityCheck = (_, _, _) {
      probes++;
      return pendingProbe.future;
    };
    notifier.reportRequestFailure();
    await pumpEventQueue();
    expect(probes, 1);

    // The rest of a failing burst waits for the answer instead of piling up.
    notifier.reportRequestFailure();
    notifier.reportRequestFailure();
    await pumpEventQueue();
    expect(probes, 1);

    // Once it answered, the next failure is worth probing again.
    pendingProbe.complete((reachable: false, reason: 'test'));
    await pumpEventQueue();
    notifier.reportRequestFailure();
    await pumpEventQueue();
    expect(probes, 2);
  });

  test('a burst of failures reported in one turn triggers a single probe', () async {
    // A screen firing its requests through Future.wait fails them all in the
    // same event-loop turn. Every extra probe would sample the same moment
    // and count as another consecutive failure, which is exactly what the
    // hysteresis is there to prevent.
    reachabilityCheck = (_, _, _) async => (reachable: true, reason: 'test');
    final container = makeContainer(serverUrl: 'https://wger.example');
    final notifier = container.read(networkStatusProvider.notifier);
    await pumpEventQueue();

    var probes = 0;
    final pendingProbe = Completer<ProbeResult>();
    reachabilityCheck = (_, _, _) {
      probes++;
      return pendingProbe.future;
    };
    notifier.reportRequestFailure();
    notifier.reportRequestFailure();
    notifier.reportRequestFailure();
    await pumpEventQueue();

    expect(probes, 1);

    pendingProbe.complete((reachable: false, reason: 'test'));
    await pumpEventQueue();
    expect(container.read(networkStatusProvider), isTrue, reason: 'one failure is not offline');
  });

  group('networkAdapterAvailableProvider', () {
    test('starts available and stays there once the platform confirms an adapter', () async {
      final container = makeContainer();

      // Nothing waits for the platform channel to answer.
      expect(container.read(networkAdapterAvailableProvider), isTrue);

      await pumpEventQueue();
      expect(container.read(networkAdapterAvailableProvider), isTrue);
    });

    test('turns false once the platform reports no adapter', () async {
      connectivity.current = [ConnectivityResult.none];
      final container = makeContainer();
      container.read(networkAdapterAvailableProvider);

      await pumpEventQueue();

      expect(container.read(networkAdapterAvailableProvider), isFalse);
    });

    test('an empty result list counts as no adapter', () async {
      connectivity.current = [];
      final container = makeContainer();
      container.read(networkAdapterAvailableProvider);

      await pumpEventQueue();

      expect(container.read(networkAdapterAvailableProvider), isFalse);
    });

    test('follows the adapter change events in both directions', () async {
      final container = makeContainer();
      container.read(networkAdapterAvailableProvider);
      await pumpEventQueue();

      connectivity.emit([ConnectivityResult.none]);
      await pumpEventQueue();
      expect(container.read(networkAdapterAvailableProvider), isFalse);

      connectivity.emit([ConnectivityResult.mobile]);
      await pumpEventQueue();
      expect(container.read(networkAdapterAvailableProvider), isTrue);
    });

    test('a failed reachability probe leaves the adapter state alone', () async {
      // The whole point of the split: the probe may be wrong, the adapter is
      // a platform fact and gates the PowerSync connection.
      reachabilityCheck = (_, _, _) async => (reachable: false, reason: 'test');
      final container = makeContainer(serverUrl: 'https://wger.example');
      container.read(networkAdapterAvailableProvider);

      await goOffline(container);
      await pumpEventQueue();

      expect(container.read(networkStatusProvider), isFalse);
      expect(container.read(networkAdapterAvailableProvider), isTrue);
    });
  });

  test('periodically re-probes on the configured interval', () async {
    networkProbeInterval = const Duration(milliseconds: 50);
    var probeCount = 0;
    reachabilityCheck = (_, _, _) async {
      probeCount++;
      return (reachable: true, reason: 'test');
    };
    final container = makeContainer(serverUrl: 'https://wger.example');
    container.read(networkStatusProvider);
    await pumpEventQueue();
    final afterInit = probeCount;

    await Future<void>.delayed(const Duration(milliseconds: 160));
    await pumpEventQueue();

    expect(probeCount, greaterThan(afterInit));
  });
}
