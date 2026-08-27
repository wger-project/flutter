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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// An SVG asset drawn like a Material icon.
///
/// Falls back to the surrounding [IconTheme] for size and color, so it lines up
/// with the regular icons next to it inside an IconButton or a ListTile.
class SvgIcon extends StatelessWidget {
  final String asset;
  final Color? color;

  const SvgIcon(this.asset, {this.color, super.key});

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final color = this.color ?? iconTheme.color;

    return SvgPicture.asset(
      asset,
      width: iconTheme.size,
      height: iconTheme.size,
      colorFilter: color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
