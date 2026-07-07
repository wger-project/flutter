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
import 'package:wger/widgets/routines/gym_mode/timer.dart';

class NavigationHeader extends StatelessWidget {
  final String _title;
  final bool showEndWorkoutButton;
  final int? restSecondsRemaining;

  const NavigationHeader(
    this._title, {
    this.showEndWorkoutButton = true,
    this.restSecondsRemaining,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final restSecs = restSecondsRemaining;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        const CompactElapsedTimer(),
        if (restSecs != null && restSecs > 0) ...[
          const SizedBox(width: 6),
          Icon(Icons.timer_outlined, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 2),
          Text(
            '${restSecs}s',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              _title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}
