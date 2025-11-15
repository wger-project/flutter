// /*
//  * This file is part of wger Workout Manager <https://github.com/wger-project>.
//  * Copyright (C) 2020, 2025 wger Team
//  *
//  * wger Workout Manager is free software: you can redistribute it and/or modify
//  * it under the terms of the GNU Affero General Public License as published by
//  * the Free Software Foundation, either version 3 of the License, or
//  * (at your option) any later version.
//  *
//  * wger Workout Manager is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU Affero General Public License for more details.
//  *
//  * You should have received a copy of the GNU Affero General Public License
//  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
//  */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/widgets/exercises/autocompleter.dart';

class WorkoutMenu extends StatelessWidget {
  final PageController _controller;

  const WorkoutMenu(this._controller);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.menu_open)),
              Tab(icon: Icon(Icons.stacked_bar_chart)),
            ],
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TabBarView(
                children: [
                  NavigationTab(_controller),
                  ProgressionTab(_controller),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Swapping an exercise only affects the current workout, no changes are saved.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationTab extends ConsumerWidget {
  final PageController _controller;

  const NavigationTab(this._controller);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gymStateProvider);

    return Column(
      children: [
        ...state.pages.where((pageEntry) => pageEntry.type == PageType.set).map((page) {
          return ListTile(
            leading: page.allLogsDone ? const Icon(Icons.check) : null,
            title: Text(
              page.exercises
                  .map(
                    (exercise) =>
                        exercise.getTranslation(Localizations.localeOf(context).languageCode).name,
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
    );
  }
}

class ProgressionTab extends ConsumerStatefulWidget {
  final _logger = Logger('ProgressionTab');
  final PageController _controller;

  ProgressionTab(this._controller, {super.key});

  @override
  ConsumerState<ProgressionTab> createState() => _ProgressionTabState();
}

class _ProgressionTabState extends ConsumerState<ProgressionTab> {
  String? showDetailsForPageId;
  _ProgressionTabState();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gymStateProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            ...state.pages.where((page) => page.type == PageType.set).map((page) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...page.slotPages.where((slotPage) => slotPage.type == SlotPageType.log).map(
                    (
                      slotPage,
                    ) {
                      final exercise = slotPage.setConfigData!.exercise
                          .getTranslation(
                            Localizations.localeOf(context).languageCode,
                          )
                          .name;

                      // Sets that are done are marked with a strikethrough
                      final decoration = slotPage.logDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none;

                      // Sets that are done have a lighter color
                      final color = slotPage.logDone
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                          : null;

                      // The row for the current page is highlighted in bold
                      final fontWeight = state.currentPage == slotPage.pageIndex
                          ? FontWeight.bold
                          : null;

                      return Text.rich(
                        TextSpan(
                          children: [
                            if (slotPage.logDone) const TextSpan(text: '✅ '),
                            TextSpan(
                              text: '$exercise -  ${slotPage.setConfigData!.textReprWithType}',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                decoration: decoration,
                                fontWeight: fontWeight,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    },
                  ),

                  if (showDetailsForPageId == page.uuid) ExerciseSwapWidget(page.uuid),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (showDetailsForPageId == page.uuid) {
                            setState(() {
                              widget._logger.fine('Hiding details');
                              showDetailsForPageId = null;
                            });
                          } else {
                            setState(() {
                              widget._logger.fine('Showing details for page ${page.uuid}');
                              showDetailsForPageId = page.uuid;
                            });
                          }
                        },
                        icon: Icon(
                          showDetailsForPageId == page.uuid
                              ? Icons.change_circle
                              : Icons.change_circle_outlined,
                        ),
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: const Icon(Icons.add),
                      // ),
                      Expanded(child: Container()),
                      IconButton(
                        onPressed: () {
                          widget._controller.animateToPage(
                            page.pageIndex,
                            duration: DEFAULT_ANIMATION_DURATION,
                            curve: DEFAULT_ANIMATION_CURVE,
                          );
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ExerciseSwapWidget extends ConsumerWidget {
  final _logger = Logger('ExerciseSwapWidget');

  final String pageUUID;

  ExerciseSwapWidget(this.pageUUID, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gymStateProvider);
    final gymProvider = ref.read(gymStateProvider.notifier);
    final page = state.pages.firstWhere((p) => p.uuid == pageUUID);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              ...page.exercises.map((e) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      e.getTranslation('en').name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Icon(Icons.swap_vert),
                    ExerciseAutocompleter(
                      onExerciseSelected: (exercise) {
                        gymProvider.replaceExercises(
                          page.uuid,
                          originalExerciseId: e.id!,
                          newExercise: exercise,
                        );
                        _logger.fine('Replaced exercise ${e.id} with ${exercise.id}');
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
