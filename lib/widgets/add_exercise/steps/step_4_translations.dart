/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/helpers/exercises/validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/core/language.dart';
import 'package:wger/providers/add_exercise_notifier.dart';
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
    final notifier = ref.read(addExerciseProvider.notifier);
    final state = ref.read(addExerciseProvider);

    final languagesAsync = ref.watch(languagesProvider);
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
                    notifier.setLanguageTranslation(newValue);
                  },
                  validator: (Language? language) {
                    if (language == null) {
                      return i18n.selectEntry;
                    }
                  },
                ),
                AddExerciseTextArea(
                  initialValue: state.exerciseNameTrans ?? '',
                  title: '${i18n.name}*',
                  validator: (name) => validateName(name, context),
                  onChange: (v) => notifier.setExerciseNameTrans(v),
                  onSaved: (String? name) => notifier.setExerciseNameTrans(name!),
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
                      notifier.setAlternateNamesTrans(alternateName!.split('\n')),
                ),
                Consumer(
                  builder: (ctx, ref, __) {
                    final descriptionTrans = ref.watch(
                      addExerciseProvider.select((s) => s.descriptionTrans),
                    );
                    return AddExerciseTextArea(
                      useMarkdownEditor: true,
                      initialValue: descriptionTrans ?? '',
                      onChange: (value) => notifier.setDescriptionTrans(value),
                      title: '${i18n.description}*',
                      helperText: i18n.enterTextInLanguage,
                      isMultiline: true,
                      validator: (name) => validateExerciseDescription(name, context),
                      onSaved: (String? description) => notifier.setDescriptionTrans(description!),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
