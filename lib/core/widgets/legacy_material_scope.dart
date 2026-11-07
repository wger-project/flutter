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

import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';

/// Makes widgets from packages still built on the SDK's Material library work
/// under material_ui: they get a mapped theme and localizations, and with
/// [ink] also the Material ancestor their InkWells and buttons require.
class LegacyMaterialScope extends StatelessWidget {
  const LegacyMaterialScope({super.key, required this.child, this.ink = true});

  final Widget child;
  final bool ink;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use -- no replacement until table_calendar, multi_select_flutter, flutter_zxing etc. migrate
    return MaterialUiCompatibilityBridge(
      child: ink ? legacy.Material(type: legacy.MaterialType.transparency, child: child) : child,
    );
  }
}
