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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/widgets/gym_mode/elapsed_time.dart';
import 'package:wger/features/routines/widgets/gym_mode/workout_menu.dart';
import 'package:wger/theme/theme.dart';

class NavigationHeader extends StatelessWidget {
  final PageController _controller;
  final String _title;
  final bool showEndWorkoutButton;

  const NavigationHeader(
    this._title,
    this._controller, {
    this.showEndWorkoutButton = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              _title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => WorkoutMenuDialog(_controller),
            );
          },
        ),
      ],
    );
  }
}

class NavigationFooter extends ConsumerWidget {
  final PageController _controller;
  final bool showPrevious;
  final bool showNext;
  final bool showElapsedTime;

  const NavigationFooter(
    this._controller, {
    this.showPrevious = true,
    this.showNext = true,
    this.showElapsedTime = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymState = ref.watch(gymStateProvider);

    return Row(
      children: [
        if (showPrevious)
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _controller.previousPage(
                duration: DEFAULT_ANIMATION_DURATION,
                curve: DEFAULT_ANIMATION_CURVE,
              );
            },
          )
        else
          const SizedBox(width: 48),
        if (showElapsedTime && gymState.showWorkoutDuration) ...[
          const ElapsedWorkoutTimer(),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => WorkoutMenuDialog(_controller, initialIndex: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: LinearProgressIndicator(
                minHeight: 3,
                value: gymState.ratioCompleted,
                valueColor: const AlwaysStoppedAnimation<Color>(wgerPrimaryColor),
              ),
            ),
          ),
        ),
        if (showNext)
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _controller.nextPage(
                duration: DEFAULT_ANIMATION_DURATION,
                curve: DEFAULT_ANIMATION_CURVE,
              );
            },
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}
