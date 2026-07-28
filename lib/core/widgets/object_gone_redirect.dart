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

import 'package:flutter/material.dart';

/// Leaves a detail screen whose object was deleted and dropped from the live
/// stream while it was open. Returns a blank placeholder and pops on the next
/// microtask (navigation isn't allowed mid-build), but only when this is the
/// current route, so an open child route (form, dialog) is left alone. Pops
/// every screen beneath it about the same object too, matched by equal route
/// argument (e.g. a routine's logs view on its detail), landing on the list.
Widget objectGoneRedirect(BuildContext context) {
  Future.microtask(() {
    if (!context.mounted) {
      return;
    }
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) {
      return;
    }
    final navigator = Navigator.of(context);
    final goneArg = route.settings.arguments;
    if (goneArg == null) {
      navigator.pop();
      return;
    }
    navigator.popUntil((r) => r.settings.arguments != goneArg);
  });
  return const SizedBox.shrink();
}
