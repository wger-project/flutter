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
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/providers/exercise_state_notifier.dart';
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
  var _totalElements = 1;
  var _totalPages = 1;
  late Future<int> _initData;
  bool _initialPageJumped = false;

  /// Map with the first (navigation) page for each exercise
  final Map<Exercise, int> _exercisePages = {};
  late final PageController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initData = _loadGymState();
    _controller = PageController(initialPage: 0);
    _calculatePages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gymStateProvider.notifier).setExercisePages(_exercisePages);
    });
  }

  Future<int> _loadGymState() async {
    // Re-fetch the current routine data to ensure we have the latest session
    // data since it is possible that the user created or deleted it from the
    // web interface.
    await context.read<RoutinesProvider>().fetchAndSetRoutineFull(
      widget._dayDataGym.day!.routineId,
    );
    widget._logger.fine('Refreshed routine data');

    final validUntil = ref.read(gymStateProvider).validUntil;
    final currentPage = ref.read(gymStateProvider).currentPage;
    final savedDayId = ref.read(gymStateProvider).dayId;
    final newDayId = widget._dayDataGym.day!.id!;

    final shouldReset = newDayId != savedDayId || validUntil.isBefore(DateTime.now());
    if (shouldReset) {
      widget._logger.fine('Day ID mismatch or expired validUntil date. Resetting to page 0.');
    }
    final initialPage = shouldReset ? 0 : currentPage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gymStateProvider.notifier)
        ..setDayId(newDayId)
        ..setCurrentPage(initialPage);
    });

    return initialPage;
  }

  void _calculatePages() {
    for (final slot in widget._dayDataGym.slots) {
      _totalElements += slot.setConfigs.length;
      // add 1 for each exercise
      _totalPages += 1;
      for (final config in slot.setConfigs) {
        // add nrOfSets * 2, 1 for log page and 1 for timer
        _totalPages += (config.nrOfSets! * 2).toInt();
      }
    }
    _exercisePages.clear();
    var currentPage = 1;

    for (final slot in widget._dayDataGym.slots) {
      var firstPage = true;
      for (final config in slot.setConfigs) {
        final exercise = ref.read(exerciseStateProvider.notifier).getById(config.exerciseId);

        if (firstPage) {
          _exercisePages[exercise] = currentPage;
          currentPage++;
        }
        currentPage += 2;
        firstPage = false;
      }
    }
  }

  List<Widget> getContent() {
    final state = ref.watch(gymStateProvider);
    final exercisesAsync = ref.read(exerciseStateProvider.notifier);
    final routinesProvider = context.read<RoutinesProvider>();
    var currentElement = 1;
    final List<Widget> out = [];

    for (final slotData in widget._dayDataGym.slots) {
      var firstPage = true;
      for (final config in slotData.setConfigs) {
        final ratioCompleted = currentElement / _totalElements;
        final exercise = exercisesAsync.getById(config.exerciseId);
        currentElement++;

        if (firstPage && state.showExercisePages) {
          out.add(
            ExerciseOverview(
              _controller,
              exercise,
              ratioCompleted,
              state.exercisePages,
              _totalPages,
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
            state.exercisePages,
            _totalPages,
            widget._iteration,
          ),
        );

        // If there is a rest time, add a countdown timer
        if (config.restTime != null) {
          out.add(
            TimerCountdownWidget(
              _controller,
              config.restTime!.toInt(),
              ratioCompleted,
              state.exercisePages,
              _totalPages,
            ),
          );
        } else {
          out.add(TimerWidget(_controller, ratioCompleted, state.exercisePages, _totalPages));
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

        final List<Widget> children = [
          StartPage(_controller, widget._dayDataDisplay, _exercisePages),
          ...getContent(),
          SessionPage(
            context.read<RoutinesProvider>().findById(widget._dayDataGym.day!.routineId),
            _controller,
            ref.read(gymStateProvider).startTime,
            _exercisePages,
            dayId: widget._dayDataGym.day!.id!,
          ),
        ];

        return PageView(
          controller: _controller,
          onPageChanged: (page) {
            ref.read(gymStateProvider.notifier).setCurrentPage(page);

            // Check if the last page is reached
            if (page == children.length - 1) {
              ref.read(gymStateProvider.notifier).clear();
            }
          },
          children: children,
        );
      },
    );
  }
}
