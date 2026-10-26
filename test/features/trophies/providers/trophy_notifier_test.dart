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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/trophies/providers/trophy_notifier.dart';

import '../../../helpers/fake_connectivity.dart';

void main() {
  // The notifier listens to networkStatusProvider, which reaches the
  // connectivity platform when it builds.
  installFakeConnectivity();

  test('the deferred reachability read survives an invalidation', () async {
    // The reachability read is deferred into a microtask so it cannot flush
    // a dirty provider chain mid-build. The post-login flow invalidates this
    // provider, so that microtask can fire on a dead ref and must not touch
    // it then.
    final container = ProviderContainer.test();
    container.read(trophyStateProvider);
    container.dispose();

    // The old notifier's microtask runs here; an unguarded ref.read would
    // surface as an uncaught UnmountedRefException and fail the test.
    await pumpEventQueue();
  });
}
