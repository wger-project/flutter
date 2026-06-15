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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/wger_base.dart';

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
  late Future<bool> Function(Uri?, String?, Duration) originalReachability;
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

  test('starts optimistically online before the first probe completes', () async {
    reachabilityCheck = (_, _, _) async => false;
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
      return true;
    };
    final container = makeContainer(serverUrl: 'https://wger.example');

    final result = await container.read(networkStatusProvider.notifier).check();

    expect(result, isFalse);
    expect(container.read(networkStatusProvider), isFalse);
    expect(probed, isFalse);
  });

  test('reports online when the backend probe succeeds', () async {
    reachabilityCheck = (_, _, _) async => true;
    final container = makeContainer(serverUrl: 'https://wger.example');

    await container.read(networkStatusProvider.notifier).check();

    expect(container.read(networkStatusProvider), isTrue);
  });

  test('reports offline when the backend probe fails', () async {
    reachabilityCheck = (_, _, _) async => false;
    final container = makeContainer(serverUrl: 'https://wger.example');

    await container.read(networkStatusProvider.notifier).check();

    expect(container.read(networkStatusProvider), isFalse);
  });

  test('probes the server version endpoint when a server URL is configured', () async {
    Uri? probedUri;
    reachabilityCheck = (uri, _, _) async {
      probedUri = uri;
      return true;
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
      return true;
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
      return true;
    };
    final base = WgerBaseProvider(serverUrl: 'https://wger.example');
    final container = ProviderContainer.test(
      overrides: [wgerBaseProvider.overrideWithValue(base)],
    );

    await container.read(networkStatusProvider.notifier).check();

    expect(probedUserAgent, base.getAppNameHeaderValue());
  });

  test('re-probes when a connectivity change event arrives', () async {
    reachabilityCheck = (_, _, _) async => true;
    final container = makeContainer(serverUrl: 'https://wger.example');
    await container.read(networkStatusProvider.notifier).check();
    expect(container.read(networkStatusProvider), isTrue);

    // Adapter still reports a connection, but the backend probe now fails.
    reachabilityCheck = (_, _, _) async => false;
    connectivity.emit([ConnectivityResult.wifi]);
    await pumpEventQueue();

    expect(container.read(networkStatusProvider), isFalse);
  });

  test('re-probes when invalidated (e.g. after login)', () async {
    // NetworkStatus does not watch wgerBase, so auth re-probes the new server
    // by invalidating the provider; the rebuild runs the probe again.
    final probedUris = <Uri?>[];
    reachabilityCheck = (uri, _, _) async {
      probedUris.add(uri);
      return true;
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

  test('periodically re-probes on the configured interval', () async {
    networkProbeInterval = const Duration(milliseconds: 50);
    var probeCount = 0;
    reachabilityCheck = (_, _, _) async {
      probeCount++;
      return true;
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
