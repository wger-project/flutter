/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
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
import 'package:wger/providers/gym_state.dart';

class WorkoutProgression extends ConsumerWidget {
  const WorkoutProgression();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gymStateProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          ...state.pages.where((page) => page.type == PageType.set).map((page) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...page.slotPages.where((slotPage) => slotPage.type == SlotPageType.log).map((
                  slotPage,
                ) {
                  final exercise = slotPage.setConfigData!.exercise
                      .getTranslation(Localizations.localeOf(context).languageCode)
                      .name;

                  // Sets that are done are marked with a strikethrough
                  final decoration = slotPage.logDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none;

                  // Sets that are done have a lighter color
                  final color = slotPage.logDone
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : null;

                  // he row for the current page is highlighted in bold
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
                }),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.swap_horiz, size: 18),
                    ),
                    /*
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 18),
                          ),
                           */
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: () {},
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
    );
  }
}
