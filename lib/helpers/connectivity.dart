/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2025 wger Team
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

import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> hasNetworkConnection({Duration timeout = const Duration(seconds: 1)}) async {
  final connectivityResult = await Connectivity().checkConnectivity();

  final allowed = [
    ConnectivityResult.mobile,
    ConnectivityResult.wifi,
    ConnectivityResult.ethernet,
  ];

  if (!connectivityResult.any((c) => allowed.contains(c))) {
    return false;
  }

  return true;

  // try {
  //   final result = await InternetAddress.lookup('example.com').timeout(timeout);
  //   return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  // } catch (_) {
  //   return false;
  // }
}
