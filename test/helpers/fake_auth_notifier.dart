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

import 'package:wger/core/network/auth_notifier.dart';
import 'package:wger/core/network/auth_state.dart';

/// An [AuthNotifier] that resolves to a fixed state.
///
/// Use it via `authProvider.overrideWith(() => FakeAuthNotifier(state))` in
/// widget tests instead of seeding preferences and stubbing every request the
/// real notifier makes on its eager build.
class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(this._state);

  final AuthState _state;

  @override
  Future<AuthState> build() async => _state;
}
