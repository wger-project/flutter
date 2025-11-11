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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart' as provider;
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/gym_mode/exercise_overview.dart';
import 'package:wger/widgets/routines/gym_mode/log_page.dart';
import 'package:wger/widgets/routines/gym_mode/session_page.dart';
import 'package:wger/widgets/routines/gym_mode/start_page.dart';
import 'package:wger/widgets/routines/gym_mode/timer.dart';

class GymMode extends ConsumerStatefulWidget {
  final DayData _dayDataGym;
  final DayData _dayDataDisplay;
  final int _iteration;
  final _logger = Logger('GymMode');

  GymMode(this._dayDataGym, this._dayDataDisplay, this._iteration);

  @override
  ConsumerState<GymMode> createState() => _GymModeState();
}

class _GymModeState extends ConsumerState<GymMode> {
  late Future<int> _initData;
  bool _initialPageJumped = false;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    _initData = _loadGymState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<int> _loadGymState() async {
    await provider.Provider.of<RoutinesProvider>(context, listen: false).fetchAndSetRoutineFull(
      widget._dayDataGym.day!.routineId,
    );
    widget._logger.fine('Refreshed routine data');

    final gymProvider = ref.read(gymStateProvider.notifier);
    final initialPage = await gymProvider.initForDay(
      widget._dayDataGym,
      findExerciseById: (id) =>
          provider.Provider.of<ExercisesProvider>(context, listen: false).findExerciseById(id),
    );

    return initialPage;
  }

  List<Widget> _getContent(GymState state) {
    final exerciseProvider = provider.Provider.of<ExercisesProvider>(context, listen: false);
    final routinesProvider = provider.Provider.of<RoutinesProvider>(context, listen: false);
    var currentElement = 1;
    final List<Widget> out = [];

    final totalElements = state.totalElements;
    final totalPages = state.totalPages;
    final exercisePages = state.exercisePages;

    for (final slotData in widget._dayDataGym.slots) {
      var firstPage = true;
      for (final config in slotData.setConfigs) {
        final ratioCompleted = currentElement / totalElements;
        final exercise = exerciseProvider.findExerciseById(config.exerciseId);
        currentElement++;

        if (firstPage && state.showExercisePages) {
          out.add(
            ExerciseOverview(
              _controller,
              exercise,
              ratioCompleted,
              exercisePages,
              totalPages,
            ),
          );
        }

        out.add(
          LogPage(
            _controller,
            config,
            slotData,
            exercise,
            routinesProvider.findById(widget._dayDataGym.day!.routineId),
            ratioCompleted,
            exercisePages,
            totalPages,
            widget._iteration,
          ),
        );

        if (state.showTimerPages) {
          if (config.restTime != null) {
            out.add(
              TimerCountdownWidget(
                _controller,
                config.restTime!.toInt(),
                ratioCompleted,
                exercisePages,
                totalPages,
              ),
            );
          } else {
            out.add(TimerWidget(_controller, ratioCompleted, exercisePages, totalPages));
          }
        }

        firstPage = false;
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _initData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final initialPage = snapshot.data!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_initialPageJumped && _controller.hasClients) {
            _controller.jumpToPage(initialPage);
            setState(() => _initialPageJumped = true);
          }
        });

        final state = ref.watch(gymStateProvider);

        final List<Widget> children = [
          StartPage(_controller, widget._dayDataDisplay, state.exercisePages),
          ..._getContent(state),
          SessionPage(
            context.read<RoutinesProvider>().findById(widget._dayDataGym.day!.routineId),
            _controller,
            state.startTime,
            state.exercisePages,
            dayId: widget._dayDataGym.day!.id!,
          ),
        ];

        return PageView(
          controller: _controller,
          onPageChanged: (page) {
            ref.read(gymStateProvider.notifier).setCurrentPage(page);

            // Check if the last page is reached
            if (page == children.length - 1) {
              widget._logger.finer('Last page reached, clearing gym state');
              ref.read(gymStateProvider.notifier).clear();
            }
          },
          children: children,
        );
      },
    );
  }
}
