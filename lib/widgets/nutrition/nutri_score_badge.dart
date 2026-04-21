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
import 'package:wger/models/nutrition/ingredient.dart';

const _nutriScoreColors = {
  NutriScore.a: Color(0xFF0d8949),
  NutriScore.b: Color(0xFF72c72b),
  NutriScore.c: Color(0xFFfbc606),
  NutriScore.d: Color(0xFFf37115),
  NutriScore.e: Color(0xFFee301f),
};

enum NutriScoreSize { small, medium, large }

class NutriScoreBadge extends StatelessWidget {
  final NutriScore score;
  final NutriScoreSize size;

  const NutriScoreBadge({
    super.key,
    required this.score,
    this.size = NutriScoreSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final dim = switch (size) {
      NutriScoreSize.small => (
        height: 18.0,
        activeHeight: 22.0,
        fontSize: 10.0,
        activeFontSize: 13.0,
        px: 3.0,
        activePx: 2.0,
      ),
      NutriScoreSize.medium => (
        height: 22.0,
        activeHeight: 28.0,
        fontSize: 12.0,
        activeFontSize: 16.0,
        px: 3.0,
        activePx: 3.0,
      ),
      NutriScoreSize.large => (
        height: 28.0,
        activeHeight: 36.0,
        fontSize: 15.0,
        activeFontSize: 20.0,
        px: 4.0,
        activePx: 4.0,
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: NutriScore.values.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        final isActive = s == score;
        final isFirst = i == 0;
        final isLast = i == NutriScore.values.length - 1;
        final h = isActive ? dim.activeHeight : dim.height;

        return Container(
          height: h,
          padding: EdgeInsets.symmetric(horizontal: isActive ? dim.activePx : dim.px),
          margin: EdgeInsets.symmetric(horizontal: isActive ? dim.activePx : 0),
          decoration: BoxDecoration(
            color: (_nutriScoreColors[s] ?? Colors.grey).withOpacity(isActive ? 1.0 : 0.4),
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? Radius.circular(h / 2) : Radius.zero,
              right: isLast ? Radius.circular(h / 2) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            s.name.toUpperCase(),
            style: TextStyle(
              color: s == NutriScore.c && !isActive ? Colors.black : Colors.white,
              fontSize: isActive ? dim.activeFontSize : dim.fontSize,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        );
      }).toList(),
    );
  }
}
