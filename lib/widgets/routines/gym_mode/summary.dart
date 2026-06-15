/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/helpers/date.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/trophies/user_trophy.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/gym_state_notifier.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/providers/trophy_notifier.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';

import '../logs/exercises_expansion_card.dart';
import '../logs/muscle_groups.dart';

class WorkoutSummary extends ConsumerStatefulWidget {
  final _logger = Logger('WorkoutSummary');
  final PageController _controller;

  WorkoutSummary(this._controller);

  @override
  ConsumerState<WorkoutSummary> createState() => _WorkoutSummaryState();
}

class _WorkoutSummaryState extends ConsumerState<WorkoutSummary> {
  late Future<void> _trophyFuture;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      final languageCode = Localizations.localeOf(context).languageCode;
      _trophyFuture = ref
          .read(trophyStateProvider.notifier)
          .fetchUserTrophies(language: languageCode);
      _didInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final routineId = ref.read(gymStateProvider).routine.id!;
    final routinesState = ref.watch(routinesRiverpodProvider).value;
    final routine = routinesState?.routines.firstWhereOrNull((r) => r.id == routineId);
    final trophyState = ref.watch(trophyStateProvider);

    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).workoutCompleted,
          widget._controller,
          showEndWorkoutButton: false,
        ),
        Expanded(
          child: FutureBuilder<void>(
            future: _trophyFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                widget._logger.warning(snapshot.error);
                widget._logger.warning(snapshot.stackTrace);
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting || routine == null) {
                return const BoxedProgressIndicator();
              }

              final session = routine.sessions.firstWhereOrNull(
                (s) => s.date.isSameDayAs(clock.now()),
              );
              final userTrophies = trophyState.prTrophies
                  .where((t) => t.contextData?.sessionId == session?.id)
                  .toList();

              return WorkoutSessionStats(session, userTrophies);
            },
          ),
        ),
        NavigationFooter(widget._controller, showNext: false),
      ],
    );
  }
}

class WorkoutSessionStats extends ConsumerWidget {
  final WorkoutSession? _session;
  final List<UserTrophy> _userPrTrophies;

  const WorkoutSessionStats(this._session, this._userPrTrophies, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_session == null) {
      return Center(
        child: Text('Nothing logged yet.', style: Theme.of(context).textTheme.titleMedium),
      );
    }

    final sessionDuration = _session.duration;
    final totalVolume = _session.volume;

    /// We assume that users will do exercises (mostly) either in metric or imperial
    /// units so we just display the higher one.
    String volumeUnit;
    num volumeValue;
    if (totalVolume['metric']! > totalVolume['imperial']!) {
      volumeValue = totalVolume['metric']!;
      volumeUnit = i18n.kg;
    } else {
      volumeValue = totalVolume['imperial']!;
      volumeUnit = i18n.lb;
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: i18n.duration,
                value: sessionDuration != null
                    ? i18n.durationHoursMinutes(
                        sessionDuration.inHours,
                        sessionDuration.inMinutes.remainder(60),
                      )
                    : '-/-',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InfoCard(
                title: i18n.volume,
                value: '${volumeValue.toStringAsFixed(0)} $volumeUnit',
              ),
            ),
          ],
        ),
        if (_userPrTrophies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InfoCard(
              title: i18n.personalRecords,
              value: _userPrTrophies.length.toString(),
              color: theme.colorScheme.tertiaryContainer,
            ),
          ),
        const SizedBox(height: 10),
        MuscleGroupsCard(_session.logs),
        const SizedBox(height: 10),
        ExercisesCard(_session, _userPrTrophies),
        FilledButton(
          onPressed: () {
            ref.read(gymStateProvider.notifier).clear();
            Navigator.of(context).pop();
          },
          child: Text(i18n.endWorkout),
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;

  const InfoCard({required this.title, required this.value, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
