import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/exercises/providers/exercise_filters_notifier.dart';
import 'package:wger/features/exercises/widgets/filter_row.dart';
import 'package:wger/features/exercises/widgets/list_tile.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  static const routeName = '/exercises';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseState = ref.watch(exerciseListFiltersProvider);

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
