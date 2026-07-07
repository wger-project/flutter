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

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/gym_state_notifier.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/widgets/core/error.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

import 'log_page.dart';
import 'session_page.dart';
import 'start_page.dart';
import 'summary.dart';

class GymMode extends ConsumerStatefulWidget {
  final GymModeArguments _args;
  final _logger = Logger('GymMode');

  GymMode(this._args);

  @override
  ConsumerState<GymMode> createState() => _GymModeState();
}

class _GymModeState extends ConsumerState<GymMode> {
  late Future<int> _initData;
  bool _initialPageJumped = false;
  late final PageController _controller;

  /// Index of the currently shown page within the [PageView]. Used to decide
  /// whether the persistent set-logging chrome should be shown.
  int _currentPage = 0;

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
    widget._logger.fine('Loading gym state');
    // This runs from initState. Yield once so the body never executes
    // synchronously inside the widget life-cycle: the offline branch reaches
    // gym-state mutations with no await in between, and modifying a provider
    // during a life-cycle is not allowed.
    await Future<void>.delayed(Duration.zero);

    final notifier = ref.read(routinesRiverpodProvider.notifier);
    final routineId = widget._args.routineId;

    final Routine routine;
    if (ref.read(networkStatusProvider)) {
      routine = await notifier.fetchAndSetRoutineFull(routineId);
    } else {
      // Offline: use the local routine data. Reaching the gym mode requires an
      // already-downloaded routine, so the routine is normally present
      final cached = ref
          .read(routinesRiverpodProvider)
          .value
          ?.routines
          .firstWhereOrNull((r) => r.id == routineId);
      if (cached == null || !cached.isHydrated) {
        throw StateError('Routine $routineId is not available offline');
      }
      routine = cached;
    }

    final gymViewModel = ref.read(gymStateProvider.notifier);
    final initialPage = gymViewModel.initData(
      routine,
      widget._args.dayId,
      widget._args.iteration,
    );
    await gymViewModel.loadPrefs();
    gymViewModel.calculatePages();

    return initialPage;
  }

  List<Widget> _getContent(GymModeState state) {
    final List<Widget> out = [];

    // Workout overview
    out.add(StartPage(_controller));

    // Sets — one page per exercise (set PageEntry). The LogPage renders all of
    // that exercise's sets at once, so we no longer create a page per set.
    for (final page in state.pages.where((p) => p.type == PageType.set)) {
      out.add(LogPage(_controller, pageEntry: page));
    }

    // End
    out.add(SessionPage(_controller));
    out.add(WorkoutSummary());

    return out;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _initData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BoxedProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(
            child: StreamErrorIndicator(snapshot.error!, stacktrace: snapshot.stackTrace),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          final initialPage = snapshot.data!;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_initialPageJumped && _controller.hasClients) {
              _controller.jumpToPage(initialPage);
              setState(() {
                _initialPageJumped = true;
                _currentPage = initialPage;
              });
            }
          });

          final state = ref.watch(gymStateProvider);
          final children = [
            ..._getContent(state),
          ];

          // The header + exercise queue live above the PageView so they stay
          // fixed while only the content below slides between exercises. They
          // are shown only on the set-logging pages (not start/session/summary).
          final currentSetPage = state.setPageForRenderIndex(_currentPage);

          return Column(
            children: [
              if (currentSetPage != null)
                GymModeChrome(
                  controller: _controller,
                  currentPageUUID: currentSetPage.uuid,
                ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (page) {
                    final isLastPage = page == children.length - 1;
                    // Defer state changes out of the page-settle callback: calling
                    // setState or mutating providers here can land mid build /
                    // transition and trip "setState during build" and
                    // navigator-locked assertions.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) {
                        return;
                      }
                      setState(() => _currentPage = page);
                      final notifier = ref.read(gymStateProvider.notifier);
                      notifier.setCurrentPage(page);

                      // Check if the last page is reached
                      if (isLastPage) {
                        widget._logger.finer('Last page reached, clearing gym state');
                        notifier.clear();
                      }
                    });
                  },
                  children: children,
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('Unexpected state'));
      },
    );
  }
}
