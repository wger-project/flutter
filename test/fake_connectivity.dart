/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wger/providers/network_provider.dart';

/// Swaps [ConnectivityPlatform.instance] with a fake that always reports
/// Wi-Fi and emits no change events, *and* replaces the DNS reachability
/// check in [NetworkStatus] with a deterministic stub.
///
/// Without this, `NetworkStatus.check()` would do a real `InternetAddress.lookup`
/// against `google.com` from every test that touches a provider depending on
/// the network state — slow, non-deterministic (CI vs no CI internet), and
/// hits an external host from the test runner.
///
/// The [ConnectivityPlatform.instance] swap follows the officially recommended
/// pattern from connectivity_plus' own tests:
/// https://github.com/fluttercommunity/plus_plugins/blob/main/packages/connectivity_plus/connectivity_plus/test/connectivity_test.dart
///
/// Call once per test file (top of `main()` is fine — the static swaps stick
/// for the entire file).
void installFakeConnectivity() {
  ConnectivityPlatform.instance = _FakeConnectivityPlatform();
  reachabilityCheck = (_) async => true;
}

class _FakeConnectivityPlatform extends ConnectivityPlatform with MockPlatformInterfaceMixin {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => const [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream<List<ConnectivityResult>>.empty();
}
