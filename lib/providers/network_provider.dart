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
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_provider.g.dart';

@Riverpod(keepAlive: true)
class NetworkStatus extends _$NetworkStatus {
  final _logger = Logger('NetworkStatus');

  static const allowed = {
    ConnectivityResult.mobile,
    ConnectivityResult.wifi,
    ConnectivityResult.ethernet,
  };

  StreamSubscription<List<ConnectivityResult>>? _sub;

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

    ref.onDispose(() {
      _sub?.cancel();
    });
  }

  Future<bool> check({Duration timeout = const Duration(seconds: 1)}) async {
    final conn = await Connectivity().checkConnectivity();
    final ok = await _hasConnectionAndInternet(conn, timeout: timeout);

    // _hasConnectionAndInternet does a real DNS lookup that can take up to
    // [timeout]. Tests routinely tear down the container before that returns,
    // so guard against writing to a disposed notifier.
    if (!ref.mounted) {
      return ok;
    }

    state = ok;
    return ok;
  }

  Future<bool> _hasConnectionAndInternet(
    List<ConnectivityResult> conn, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    if (!conn.any((c) => allowed.contains(c))) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com').timeout(timeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
