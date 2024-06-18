import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/exercises/filter_row.dart';
import 'package:wger/widgets/exercises/list_tile.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});
  static const routeName = '/exercises';

  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late final TextEditingController _exerciseNameController;

  @override
  void initState() {
    _exerciseNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    final exercisesList = Provider.of<ExercisesProvider>(context).filteredExercises;

    return Scaffold(
      appBar: EmptyAppBar(AppLocalizations.of(context).exercises),
      body: Column(
        children: [
          const FilterRow(),
          Expanded(
            child: exercisesList.isEmpty
                ? const Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _ExercisesList(exerciseBaseList: exercisesList),
          ),
        ],
      ),
    );
  }
}

class _ExercisesList extends StatelessWidget {
  const _ExercisesList({required this.exerciseBaseList});

  final List<Exercise> exerciseBaseList;

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const Divider(thickness: 1);
      },
      itemCount: exerciseBaseList.length,
      itemBuilder: (context, index) {
        return ExerciseListTile(exerciseBase: exerciseBaseList[index]);

        /*
        return Container(
          height: size.height * 0.175,
          child: ExerciseListTile(exercise: exercise),
        );
        */
      },
    );
  }
}
