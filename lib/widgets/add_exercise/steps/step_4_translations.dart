import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:provider/provider.dart';
import 'package:wger/helpers/exercises/validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/core_data.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';
import 'package:wger/widgets/exercises/forms.dart';

class Step4Translation extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formkey;

  const Step4Translation({required this.formkey});

  @override
  ConsumerState<Step4Translation> createState() => _Step4TranslationState();
}

class _Step4TranslationState extends ConsumerState<Step4Translation> {
  bool translate = false;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final addExerciseProvider = context.read<AddExerciseProvider>();

    final languagesAsync = ref.watch(languageProvider);
    final languages = languagesAsync.asData?.value ?? <Language>[];

    return Form(
      key: widget.formkey,
      child: Column(
        children: [
          SwitchListTile(
            title: Text(i18n.translation),
            subtitle: Text(i18n.translateExercise),
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
                  title: '${i18n.language}*',
                  displayName: (Language l) => l.fullName,
                  callback: (Language newValue) {
                    addExerciseProvider.languageTranslation = newValue;
                  },
                  validator: (Language? language) {
                    if (language == null) {
                      return i18n.selectEntry;
                    }
                  },
                ),
                AddExerciseTextArea(
                  title: '${i18n.name}*',
                  validator: (name) => validateName(name, context),
                  onSaved: (String? name) => addExerciseProvider.exerciseNameTrans = name!,
                ),
                AddExerciseTextArea(
                  title: i18n.alternativeNames,
                  isMultiline: true,
                  helperText: i18n.oneNamePerLine,
                  validator: (alternateNames) {
                    // check that each line (name) is at least MIN_CHARACTERS_NAME long
                    if (alternateNames?.isNotEmpty == true) {
                      final names = alternateNames!.split('\n');
                      for (final name in names) {
                        if (name.length < MIN_CHARS_NAME || name.length > MAX_CHARS_NAME) {
                          return i18n.enterCharacters(
                            MIN_CHARS_NAME.toString(),
                            MAX_CHARS_NAME.toString(),
                          );
                        }
                      }
                    }
                    return null;
                  },
                  onSaved: (String? alternateName) =>
                      addExerciseProvider.alternateNamesTrans = alternateName!.split('\n'),
                ),
                Consumer<AddExerciseProvider>(
                  builder: (ctx, provider, __) => AddExerciseTextArea(
                    onChange: (value) => {},
                    title: '${i18n.description}*',
                    helperText: i18n.enterTextInLanguage,
                    isMultiline: true,
                    validator: (name) => validateExerciseDescription(name, context),
                    onSaved: (String? description) =>
                        addExerciseProvider.descriptionTrans = description!,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
