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

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the platform can supply a dynamic color palette.
///
/// True on Android 12+, which exposes a wallpaper palette, and on macOS,
/// Windows and GTK-based Linux, which expose a system accent color. False
/// everywhere else, including iOS, the web and Android below 12, where the
/// dynamic color setting would be a silent no-op.
final dynamicColorAvailableProvider = FutureProvider<bool>((ref) async {
  try {
    if (await DynamicColorPlugin.getCorePalette() != null) {
      return true;
    }

    return await DynamicColorPlugin.getAccentColor() != null;
  } on PlatformException {
    return false;
  }
});
