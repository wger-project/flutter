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

import 'package:clock/clock.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/workouts/log.dart';

part 'gym_log_state.g.dart';

@Riverpod(keepAlive: true)
class GymLogNotifier extends _$GymLogNotifier {
  final _logger = Logger('GymLogNotifier');

  @override
  Log? build() {
    _logger.finer('Initializing GymLogNotifier');
    return null;
  }

  void setLog(Log log) {
    final newLog = log.copyWith(id: null, date: clock.now());
    state = newLog;
  }

  void setWeight(num weight) {
    state = state?.copyWith(weight: weight);
  }

  void setRepetitions(num repetitions) {
    state = state?.copyWith(repetitions: repetitions);
  }
}
