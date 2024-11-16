import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/screens/add_exercise_screen.dart';
import 'package:wger/widgets/exercises/images.dart';

typedef ExerciseSelectedCallback = void Function(Exercise exercise);

class ExerciseAutocompleter extends StatefulWidget {
  final ExerciseSelectedCallback onExerciseSelected;

  const ExerciseAutocompleter({required this.onExerciseSelected});

  @override
  State<ExerciseAutocompleter> createState() => _ExerciseAutocompleterState();
}

class _ExerciseAutocompleterState extends State<ExerciseAutocompleter> {
  bool _searchEnglish = true;
  final _exercisesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        TypeAheadField<Exercise>(
          key: const Key('field-typeahead'),
          decorationBuilder: (context, child) {
            return Material(
              type: MaterialType.card,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: child,
            );
          },
          controller: _exercisesController,
          builder: (context, controller, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).searchExercise,
                prefixIcon: const Icon(Icons.search),
                // suffixIcon: IconButton(
                //   icon: const Icon(Icons.help),
                //   onPressed: () {
                //     showDialog(
                //       context: context,
                //       builder: (context) => AlertDialog(
                //         content: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Text(AppLocalizations.of(context).selectExercises),
                //             const SizedBox(height: 10),
                //             Text(AppLocalizations.of(context).sameRepetitions),
                //           ],
                //         ),
                //         actions: [
                //           TextButton(
                //             child: Text(
                //               MaterialLocalizations.of(context).closeButtonLabel,
                //             ),
                //             onPressed: () {
                //               Navigator.of(context).pop();
                //             },
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                // ),
                errorMaxLines: 2,
                border: InputBorder.none,
              ),
            );
          },
          suggestionsCallback: (pattern) {
            if (pattern == '') {
              return null;
            }
            return context.read<ExercisesProvider>().searchExercise(
                  pattern,
                  languageCode: Localizations.localeOf(context).languageCode,
                  searchEnglish: _searchEnglish,
                );
          },
          itemBuilder: (
            BuildContext context,
            Exercise exerciseSuggestion,
          ) =>
              ListTile(
            key: Key('exercise-${exerciseSuggestion.id}'),
            leading: SizedBox(
              width: 45,
              child: ExerciseImageWidget(
                image: exerciseSuggestion.getMainImage,
              ),
            ),
            title: Text(
              exerciseSuggestion.getExercise(Localizations.localeOf(context).languageCode).name,
            ),
            subtitle: Text(
              '${exerciseSuggestion.category!.name} / ${exerciseSuggestion.equipment.map((e) => e.name).join(', ')}',
            ),
          ),
          emptyBuilder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context).noMatchingExerciseFound),
                ),
                ListTile(
                  title: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AddExerciseScreen.routeName);
                    },
                    child: Text(AppLocalizations.of(context).contributeExercise),
                  ),
                ),
              ],
            );
          },
          transitionBuilder: (context, animation, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
            child: child,
          ),
          onSelected: (Exercise exerciseSuggestion) {
            widget.onExerciseSelected(exerciseSuggestion);
            _exercisesController.text = '';
          },
        ),
        if (Localizations.localeOf(context).languageCode != LANGUAGE_SHORT_ENGLISH)
          SwitchListTile(
            title: Text(AppLocalizations.of(context).searchNamesInEnglish),
            value: _searchEnglish,
            onChanged: (_) {
              setState(() {
                _searchEnglish = !_searchEnglish;
              });
            },
            dense: true,
          )
      ],
    );
  }
}
