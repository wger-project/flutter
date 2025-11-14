/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/theme/theme.dart';

class NavigationFooter extends ConsumerWidget {
  final PageController _controller;
  final bool showPrevious;
  final bool showNext;

  const NavigationFooter(
    this._controller, {
    this.showPrevious = true,
    this.showNext = true,
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
        Expanded(
          child: LinearProgressIndicator(
            minHeight: 3,
            value: gymState.ratioCompleted,
            valueColor: const AlwaysStoppedAnimation<Color>(wgerPrimaryColor),
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

class NavigationHeader extends ConsumerWidget {
  final PageController _controller;
  final String _title;
  final bool showEndWorkoutButton;

  const NavigationHeader(this._title, this._controller, {this.showEndWorkoutButton = true});

  Widget getDialog(BuildContext context, int totalPages, List<PageEntry> pages) {
    final exercisesProvider = context.read<ExercisesProvider>();

    final endWorkoutButton = showEndWorkoutButton
        ? TextButton(
            child: Text(AppLocalizations.of(context).endWorkout),
            onPressed: () {
              _controller.animateToPage(
                totalPages,
                duration: DEFAULT_ANIMATION_DURATION,
                curve: DEFAULT_ANIMATION_CURVE,
              );

              Navigator.of(context).pop();
            },
          )
        : null;

    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).jumpTo,
        textAlign: TextAlign.center,
      ),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          children: [
            ...pages.where((page) => page.type == PageType.set).map((page) {
              return ListTile(
                leading: page.allLogsDone ? const Icon(Icons.check) : null,
                title: Text(
                  page.exerciseIds
                      .map(
                        (id) => exercisesProvider
                            .findExerciseById(id)
                            .getTranslation(Localizations.localeOf(context).languageCode)
                            .name,
                      )
                      .toList()
                      .join('\n'),
                  style: TextStyle(
                    decoration: page.allLogsDone ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _controller.animateToPage(
                    page.pageIndex,
                    duration: DEFAULT_ANIMATION_DURATION,
                    curve: DEFAULT_ANIMATION_CURVE,
                  );
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      ),
      actions: [
        ?endWorkoutButton,
        TextButton(
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymState = ref.watch(gymStateProvider);

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
          icon: const Icon(Icons.toc),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => getDialog(ctx, gymState.totalPages, gymState.pages),
            );
          },
        ),
      ],
    );
  }
}
