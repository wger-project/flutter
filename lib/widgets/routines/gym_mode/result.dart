import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/date.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session_api.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';

class ResultsWidget extends ConsumerStatefulWidget {
  final _logger = Logger('ResultsWidget');

  final PageController _controller;

  ResultsWidget(this._controller);

  @override
  ConsumerState<ResultsWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends ConsumerState<ResultsWidget> {
  late Future<void> _initData;
  late Routine _routine;

  @override
  void initState() {
    super.initState();
    _initData = _reloadRoutineData();
  }

  Future<void> _reloadRoutineData() async {
    widget._logger.fine('Loading routine data');
    final gymState = ref.read(gymStateProvider);

    _routine = await context.read<RoutinesProvider>().fetchAndSetRoutineFull(
      gymState.routine.id!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).workoutCompleted,
          widget._controller,
          showEndWorkoutButton: false,
        ),
        Expanded(
          child: FutureBuilder<void>(
            future: _initData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const BoxedProgressIndicator();
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}: ${snapshot.stackTrace}'));
              } else if (snapshot.connectionState == ConnectionState.done) {
                return WorkoutStats(
                  _routine.sessions.firstWhereOrNull(
                    (s) => s.session.date.isSameDayAs(DateTime.now()),
                  ),
                );
              }

              return const Center(child: Text('Unexpected state!'));
            },
          ),
        ),
        NavigationFooter(widget._controller),
      ],
    );
  }
}

class WorkoutStats extends ConsumerWidget {
  final _logger = Logger('WorkoutStats');
  final WorkoutSessionApi? _sessionApi;

  WorkoutStats(this._sessionApi, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);

    if (_sessionApi == null) {
      return Center(
        child: Text(
          'Nothing logged yet.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    final session = _sessionApi.session;
    final sessionDuration = session.duration;
    final totalVolume = _sessionApi.logs.fold<double>(0, (sum, log) => sum + log.volume());

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
                value: totalVolume.toStringAsFixed(0),
              ),
            ),
          ],
        ),
        // const SizedBox(height: 16),
        // InfoCard(
        //   title: 'Personal Records',
        //   value: prCount.toString(),
        //   color: theme.colorScheme.tertiaryContainer,
        // ),
        const SizedBox(height: 10),
        MuscleGroupsCard(_sessionApi.logs),
        const SizedBox(height: 10),
        ExercisesCard(_sessionApi),
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

class ExercisesCard extends StatelessWidget {
  final WorkoutSessionApi session;

  const ExercisesCard(this.session, {super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = session.exercises;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).exercises,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...exercises.map((exercise) {
              final logs = session.logs.where((log) => log.exerciseId == exercise.id).toList();
              return _ExerciseExpansionTile(exercise: exercise, logs: logs);
            }),
          ],
        ),
      ),
    );
  }
}

class _ExerciseExpansionTile extends StatelessWidget {
  const _ExerciseExpansionTile({
    required this.exercise,
    required this.logs,
  });

  final Exercise exercise;
  final List<Log> logs;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    final topSet = logs.isEmpty
        ? null
        : logs.reduce((a, b) => (a.weight ?? 0) > (b.weight ?? 0) ? a : b);
    final topSetWeight = topSet?.weight?.toStringAsFixed(0) ?? 'N/A';
    final topSetWeightUnit = topSet?.weightUnitObj != null
        ? getServerStringTranslation(topSet!.weightUnitObj!.name, context)
        : '';
    return ExpansionTile(
      // leading: const Icon(Icons.fitness_center),
      title: Text(exercise.getTranslation(languageCode).name, style: theme.textTheme.titleMedium),
      subtitle: Text('Top set: $topSetWeight $topSetWeightUnit'),
      children: logs.map((log) => _SetDataRow(log: log)).toList(),
    );
  }
}

class MuscleGroup {
  final String name;
  final double percentage;
  final Color color;

  MuscleGroup(this.name, this.percentage, this.color);
}

class _SetDataRow extends StatelessWidget {
  const _SetDataRow({required this.log});

  final Log log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 5,
        children: [
          Text(
            log.repTextNoNl(context),
            style: theme.textTheme.bodyMedium,
          ),
          // if (log.volume() > 0)
          //   Text(
          //     '${log.volume().toStringAsFixed(0)} ${getServerStringTranslation(log.weightUnitObj!.name, context)}',
          //     style: theme.textTheme.bodyMedium,
          //   ),
        ],
      ),
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

class MuscleGroupsCard extends StatelessWidget {
  final List<Log> logs;

  const MuscleGroupsCard(this.logs, {super.key});

  List<MuscleGroup> _getMuscleGroups(BuildContext context) {
    final allMuscles = logs
        .expand((log) => [...log.exercise.muscles, ...log.exercise.musclesSecondary])
        .toList();
    if (allMuscles.isEmpty) {
      return [];
    }
    final muscleCounts = allMuscles.groupListsBy((muscle) => muscle.nameTranslated(context));
    final total = allMuscles.length;

    int colorIndex = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.deepOrange,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
      Colors.lime,
      Colors.amber,
      Colors.lightGreen,
      Colors.deepPurple,
    ];

    return muscleCounts.entries.map((entry) {
      final percentage = (entry.value.length / total) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return MuscleGroup(entry.key, percentage, color);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final muscles = _getMuscleGroups(context);
    final theme = Theme.of(context);
    final i18n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              i18n.muscles,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: muscles.map((muscle) {
                    return PieChartSectionData(
                      color: muscle.color,
                      value: muscle.percentage,
                      title: i18n.percentValue(muscle.percentage.toStringAsFixed(0)),
                      radius: 50,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: muscles.map((muscle) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: muscle.color,
                    ),
                    const SizedBox(width: 8),
                    Text(muscle.name),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
