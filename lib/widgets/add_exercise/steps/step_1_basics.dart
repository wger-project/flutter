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
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/exercises/validators.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/core/language.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/add_exercise_notifier.dart';
import 'package:wger/providers/core_data.dart';
import 'package:wger/providers/exercise_data.dart';
import 'package:wger/widgets/add_exercise/add_exercise_multiselect_button.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';
import 'package:wger/widgets/exercises/exercises.dart';
import 'package:wger/widgets/exercises/forms.dart';

class Step1Basics extends ConsumerWidget {
  final GlobalKey<FormState> formkey;

  const Step1Basics({required this.formkey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addExerciseProvider.notifier);

    final languagesAsync = ref.watch(languagesProvider);
    final categoriesAsync = ref.watch(exerciseCategoriesProvider);
    final musclesAsync = ref.watch(exerciseMusclesProvider);
    final equipmentAsync = ref.watch(exerciseEquipmentProvider);

    final categories = categoriesAsync.asData?.value ?? <ExerciseCategory>[];
    final muscles = musclesAsync.asData?.value ?? <Muscle>[];
    final equipment = equipmentAsync.asData?.value ?? <Equipment>[];
    final languages = languagesAsync.asData?.value ?? <Language>[];

    // Doing it like this because the languages list is empty before the stream loads
    final matched = languages.where((l) => l.shortName == LANGUAGE_SHORT_ENGLISH);
    final newLanguageEn = matched.isNotEmpty ? matched.first : null;
    if (ref.read(addExerciseProvider).languageEn != newLanguageEn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.setLanguageEn(newLanguageEn);
      });
    }

    return Form(
      key: formkey,
      child: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(addExerciseProvider);
          return Column(
            children: [
              AddExerciseTextArea(
                initialValue: state.exerciseNameEn ?? '',
                title: '${AppLocalizations.of(context).name}*',
                helperText: AppLocalizations.of(context).baseNameEnglish,
                validator: (name) => validateName(name, context),
                onChange: (value) => notifier.setExerciseNameEn(value),
                onSaved: (String? name) => notifier.setExerciseNameEn(name),
              ),
              AddExerciseTextArea(
                title: AppLocalizations.of(context).alternativeNames,
                isMultiline: true,
                initialValue: state.alternateNamesEn.join('\n'),
                helperText: AppLocalizations.of(context).oneNamePerLine,
                onChange: (value) => notifier.setAlternateNamesEn(value.split('\n')),
                onSaved: (String? alternateName) =>
                    notifier.setAlternateNamesEn(alternateName!.split('\n')),
              ),
              AddExerciseTextArea(
                title: '${AppLocalizations.of(context).author}*',
                isMultiline: false,
                validator: (name) => validateAuthorName(name, context),
                initialValue: state.author,
                onChange: (v) => notifier.setAuthor(v),
                onSaved: (String? author) => notifier.setAuthor(author!),
              ),
              ExerciseCategoryInputWidget<ExerciseCategory>(
                key: const Key('category-dropdown'),
                entries: categories,
                title: '${AppLocalizations.of(context).category}*',
                callback: (ExerciseCategory newValue) {
                  notifier.setCategory(newValue);
                },
                validator: (ExerciseCategory? category) {
                  if (category == null) {
                    return AppLocalizations.of(context).selectEntry;
                  }
                },
                displayName: (ExerciseCategory c) => getServerStringTranslation(c.name, context),
              ),
              AddExerciseMultiselectButton<Equipment>(
                key: const Key('equipment-multiselect'),
                title: AppLocalizations.of(context).equipment,
                items: equipment,
                initialItems: state.equipment,
                onChange: (dynamic entries) {
                  notifier.setEquipment(entries.cast<Equipment>());
                },
                onSaved: (dynamic entries) {
                  notifier.setEquipment(entries.cast<Equipment>());
                },
                displayName: (Equipment e) => getServerStringTranslation(e.name, context),
              ),
              AddExerciseMultiselectButton<Muscle>(
                key: const Key('primary-muscles-multiselect'),
                title: AppLocalizations.of(context).muscles,
                items: muscles,
                initialItems: state.primaryMuscles,
                onChange: (dynamic muscles) {
                  notifier.setPrimaryMuscles(muscles.cast<Muscle>());
                },
                onSaved: (dynamic muscles) {
                  notifier.setPrimaryMuscles(muscles.cast<Muscle>());
                },
                displayName: (Muscle e) =>
                    e.name +
                    (e.nameEn.isNotEmpty
                        ? '\n(${getServerStringTranslation(e.nameEn, context)})'
                        : ''),
              ),
              AddExerciseMultiselectButton<Muscle>(
                key: const Key('secondary-muscles-multiselect'),
                title: AppLocalizations.of(context).musclesSecondary,
                items: muscles,
                initialItems: state.secondaryMuscles,
                onChange: (dynamic muscles) {
                  notifier.setSecondaryMuscles(muscles.cast<Muscle>());
                },
                onSaved: (dynamic muscles) {
                  notifier.setSecondaryMuscles(muscles.cast<Muscle>());
                },
                displayName: (Muscle e) =>
                    e.name +
                    (e.nameEn.isNotEmpty
                        ? '\n(${getServerStringTranslation(e.nameEn, context)})'
                        : ''),
              ),
              MuscleRowWidget(
                muscles: state.primaryMuscles,
                musclesSecondary: state.secondaryMuscles,
              ),
              const MuscleColorHelper(main: true),
              const SizedBox(height: 5),
              const MuscleColorHelper(main: false),
            ],
          );
        },
      ),
    );
  }
}
