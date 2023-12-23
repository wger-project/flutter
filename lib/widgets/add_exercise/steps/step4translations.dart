import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/exercises/forms.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';
import 'package:wger/widgets/exercises/forms.dart';

class Step4Translation extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  const Step4Translation({required this.formkey});

  @override
  State<Step4Translation> createState() => _Step4TranslationState();
}

class _Step4TranslationState extends State<Step4Translation> {
  bool translate = false;

  @override
  Widget build(BuildContext context) {
    final addExerciseProvider = context.read<AddExerciseProvider>();
    final exerciseProvider = context.read<ExercisesProvider>();
    final languages = exerciseProvider.languages;

    return Form(
      key: widget.formkey,
      child: Column(
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context).translation),
            subtitle: Text(AppLocalizations.of(context).translateExercise),
            value: translate,
            onChanged: (_) {
              setState(() {
                translate = !translate;
              });
            },
          ),
          if (translate)
            Column(
              children: [
                ExerciseCategoryInputWidget<Language>(
                  key: const Key('language-dropdown'),
                  entries: languages,
                  title: '${AppLocalizations.of(context).language}*',
                  displayName: (Language l) => l.fullName,
                  callback: (Language newValue) {
                    addExerciseProvider.language = newValue;
                  },
                  validator: (Language? language) {
                    if (language == null) {
                      return AppLocalizations.of(context).selectEntry;
                    }
                  },
                ),
                AddExerciseTextArea(
                  onChange: (value) => {},
                  title: '${AppLocalizations.of(context).name}*',
                  isRequired: true,
                  validator: (name) => validateName(name, context),
                  onSaved: (String? name) => addExerciseProvider.exerciseNameTrans = name!,
                ),
                AddExerciseTextArea(
                  onChange: (value) => {},
                  title: AppLocalizations.of(context).alternativeNames,
                  isMultiline: true,
                  helperText: AppLocalizations.of(context).oneNamePerLine,
                  validator: (alternateNames) {
                    // check that each line (name) is at least MIN_CHARACTERS_NAME long
                    if (alternateNames?.isNotEmpty == true) {
                      final names = alternateNames!.split('\n');
                      for (final name in names) {
                        if (name.length < MIN_CHARS_NAME || name.length > MAX_CHARS_NAME) {
                          return AppLocalizations.of(context).enterCharacters(
                            MIN_CHARS_NAME,
                            MAX_CHARS_NAME,
                          );
                        }
                      }
                    }
                    return null;
                  },
                  onSaved: (String? alternateName) =>
                      addExerciseProvider.alternateNamesTrans = alternateName!.split('\n'),
                ),
                AddExerciseTextArea(
                  onChange: (value) => {},
                  title: '${AppLocalizations.of(context).description}*',
                  isRequired: true,
                  isMultiline: true,
                  validator: (name) => validateDescription(name, context),
                  onSaved: (String? description) =>
                      addExerciseProvider.descriptionTrans = description!,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
