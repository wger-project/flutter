import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/exercises/filter_row.dart';
import 'package:wger/widgets/exercises/list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({Key? key}) : super(key: key);
  static const routeName = '/exercises';

  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late final TextEditingController _exerciseNameController;

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    final exercisesList = Provider.of<ExercisesProvider>(context).filteredExercises;

    return Scaffold(
      appBar: WgerAppBar(AppLocalizations.of(context).exercises),
      body: Column(
        children: [
          FilterRow(),
          Expanded(
            child: exercisesList == null
                ? Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _ExercisesList(exercisesList: exercisesList),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }
}

class _ExercisesList extends StatelessWidget {
  const _ExercisesList({
    Key? key,
    required this.exercisesList,
  }) : super(key: key);

  final List<Exercise> exercisesList;

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const Divider(
          thickness: 1,
        );
      },
      itemCount: exercisesList.length,
      itemBuilder: (context, index) {
        final exercise = exercisesList[index];
        return ExerciseListTile(exercise: exercise);
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
