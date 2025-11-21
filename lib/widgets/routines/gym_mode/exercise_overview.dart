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
import 'package:logging/logging.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/widgets/exercises/exercises.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';

class ExerciseOverview extends ConsumerWidget {
  final _logger = Logger('ExerciseOverview');
  final PageController _controller;

  ExerciseOverview(this._controller);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(gymStateProvider).getSlotEntryPageByIndex();

    if (page == null) {
      _logger.info(
        'getPageByIndex returned null, showing empty container.',
      );
      return Container();
    }
    final exercise = page.setConfigData!.exercise;

    return Column(
      children: [
        NavigationHeader(
          exercise.getTranslation(Localizations.localeOf(context).languageCode).name,
          _controller,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ExerciseDetail(exercise),
            ),
          ),
        ),
        NavigationFooter(_controller),
      ],
    );
  }
}
