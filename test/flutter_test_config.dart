/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:drift/drift.dart';
import 'package:wger/providers/network_provider.dart';

/// Global setup wrapped around every test file under `test/`.
///
/// - Disables [NetworkStatus]'s periodic backend re-probe: a `Timer.periodic`
///   left running past a test fails the test runner with a pending-timer error.
///   Production keeps the default interval.
/// - Silences drift's multiple-instances warning. Drift counts [GeneratedDatabase]
///   instantiations per process and warns from the second one, but never
///   decrements on `close()`. Repository tests open a fresh in-memory
///   `DriftPowersyncDatabase` in every `setUp`, so the counter trips by design
///   and spams the log without flagging an actual bug.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  networkProbeInterval = null;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}
