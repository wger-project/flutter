import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:wger/helpers/connectivity.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercise_state_notifier.dart';
import 'package:wger/screens/add_exercise_screen.dart';
import 'package:wger/widgets/exercises/images.dart';

typedef ExerciseSelectedCallback = void Function(Exercise exercise);

class ExerciseAutocompleter extends ConsumerStatefulWidget {
  final ExerciseSelectedCallback onExerciseSelected;

  const ExerciseAutocompleter({required this.onExerciseSelected});

  @override
  ConsumerState<ExerciseAutocompleter> createState() => _ExerciseAutocompleterState();
}

class _ExerciseAutocompleterState extends ConsumerState<ExerciseAutocompleter> {
  bool _searchEnglish = true;
  final _exercisesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        TypeAheadField<Exercise>(
          key: const Key('field-typeahead'),
          debounceDuration: const Duration(milliseconds: 500),
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
          suggestionsCallback: (pattern) async {
            if (pattern.isEmpty) {
              return null;
            }

            return ref
                .read(exerciseStateProvider.notifier)
                .searchExercise(
                  pattern,
                  languageCode: languageCode,
                  searchEnglish: _searchEnglish,
                  useOnlineSearch: await hasNetworkConnection(),
                );
          },
          itemBuilder:
              (
                BuildContext context,
                Exercise exercise,
              ) => ListTile(
                key: Key('exercise-${exercise.id}'),
                leading: SizedBox(
                  width: 45,
                  child: ExerciseImageWidget(
                    image: exercise.getMainImage,
                  ),
                ),
                title: Text(
                  exercise.getTranslation(languageCode).name,
                ),
                subtitle: Text(
                  '${exercise.category!.name} / ${exercise.equipment.map((e) => e.name).join(', ')}',
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
        if (languageCode != LANGUAGE_SHORT_ENGLISH)
          SwitchListTile(
            title: Text(AppLocalizations.of(context).searchNamesInEnglish),
            value: _searchEnglish,
            onChanged: (_) {
              setState(() {
                _searchEnglish = !_searchEnglish;
              });
            },
            dense: true,
          ),
      ],
    );
  }
}
