import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercise_state_notifier.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/exercises/filter_row.dart';
import 'package:wger/widgets/exercises/list_tile.dart';

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  static const routeName = '/exercises';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseState = ref.watch(exerciseStateProvider);

    return Scaffold(
      appBar: EmptyAppBar(AppLocalizations.of(context).exercises),
      body: WidescreenWrapper(
        child: Column(
          children: [
            const FilterRow(),
            Expanded(
              child: exerciseState.isLoading
                  ? const BoxedProgressIndicator()
                  : _ExercisesList(
                      exerciseList: exerciseState.filteredExercises,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExercisesList extends StatelessWidget {
  const _ExercisesList({required this.exerciseList});

  final List<Exercise> exerciseList;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const Divider(thickness: 1);
      },
      itemCount: exerciseList.length,
      itemBuilder: (context, index) => ExerciseListTile(exercise: exerciseList[index]),
    );
  }
}
