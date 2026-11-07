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

import 'package:flutter/widgets.dart';

/// Runs [action] on the next frame: UI side effects (dialogs, snackbars,
/// navigation) are illegal during build, but error handlers and provider
/// listeners can fire there. Schedules a frame so idle-time requests run too.
void runAfterFrame(VoidCallback action) {
  WidgetsBinding.instance.addPostFrameCallback((_) => action());
  WidgetsBinding.instance.scheduleFrame();
}

/// Yields past the synchronous phase of a provider create or widget
/// life-cycle callback: reading a dirty provider there flushes it mid-build
/// and crashes. A microtask, not a timer, since widget tests assert
/// !timersPending at teardown.
Future<void> yieldPastBuild() => Future<void>.microtask(() {});
