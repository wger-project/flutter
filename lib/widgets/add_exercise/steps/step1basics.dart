import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/exercises/forms.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/add_exercise/add_exercise_multiselect_button.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';
import 'package:wger/widgets/exercises/exercises.dart';
import 'package:wger/widgets/exercises/forms.dart';

class Step1Basics extends StatelessWidget {
  final GlobalKey<FormState> formkey;
  const Step1Basics({required this.formkey});

  @override
  Widget build(BuildContext context) {
    final addExerciseProvider = context.read<AddExerciseProvider>();
    final exerciseProvider = context.read<ExercisesProvider>();
    final categories = exerciseProvider.categories;
    final muscles = exerciseProvider.muscles;
    final equipment = exerciseProvider.equipment;

    return Form(
      key: formkey,
      child: Column(
        children: [
          AddExerciseTextArea(
            onChange: (value) => {},
            title: '${AppLocalizations.of(context).name}*',
            helperText: AppLocalizations.of(context).baseNameEnglish,
            isRequired: true,
            validator: (name) => validateName(name, context),
            onSaved: (String? name) => addExerciseProvider.exerciseNameEn = name!,
          ),
          AddExerciseTextArea(
            onChange: (value) => {},
            title: AppLocalizations.of(context).alternativeNames,
            isMultiline: true,
            helperText: AppLocalizations.of(context).oneNamePerLine,
            onSaved: (String? alternateName) =>
                addExerciseProvider.alternateNamesEn = alternateName!.split('\n'),
          ),
          ExerciseCategoryInputWidget<ExerciseCategory>(
            key: const Key('category-dropdown'),
            entries: categories,
            title: '${AppLocalizations.of(context).category}*',
            callback: (ExerciseCategory newValue) {
              addExerciseProvider.category = newValue;
            },
            validator: (ExerciseCategory? category) {
              if (category == null) {
                return AppLocalizations.of(context).selectEntry;
              }
            },
            displayName: (ExerciseCategory c) => getTranslation(c.name, context),
          ),
          AddExerciseMultiselectButton<Equipment>(
            key: const Key('equipment-multiselect'),
            title: AppLocalizations.of(context).equipment,
            items: equipment,
            initialItems: addExerciseProvider.equipment,
            onChange: (dynamic entries) {
              addExerciseProvider.equipment = entries.cast<Equipment>();
            },
            onSaved: (dynamic entries) {
              addExerciseProvider.equipment = entries.cast<Equipment>();
            },
            displayName: (Equipment e) => getTranslation(e.name, context),
          ),
          AddExerciseMultiselectButton<Muscle>(
            key: const Key('primary-muscles-multiselect'),
            title: AppLocalizations.of(context).muscles,
            items: muscles,
            initialItems: addExerciseProvider.primaryMuscles,
            onChange: (dynamic muscles) {
              addExerciseProvider.primaryMuscles = muscles.cast<Muscle>();
            },
            onSaved: (dynamic muscles) {
              addExerciseProvider.primaryMuscles = muscles.cast<Muscle>();
            },
            displayName: (Muscle e) =>
                e.name + (e.nameEn.isNotEmpty ? '\n(${getTranslation(e.nameEn, context)})' : ''),
          ),
          AddExerciseMultiselectButton<Muscle>(
            key: const Key('secondary-muscles-multiselect'),
            title: AppLocalizations.of(context).musclesSecondary,
            items: muscles,
            initialItems: addExerciseProvider.secondaryMuscles,
            onChange: (dynamic muscles) {
              addExerciseProvider.secondaryMuscles = muscles.cast<Muscle>();
            },
            onSaved: (dynamic muscles) {
              addExerciseProvider.secondaryMuscles = muscles.cast<Muscle>();
            },
            displayName: (Muscle e) =>
                e.name + (e.nameEn.isNotEmpty ? '\n(${getTranslation(e.nameEn, context)})' : ''),
          ),
          Consumer<AddExerciseProvider>(
            builder: (context, value, child) => MuscleRowWidget(
              muscles: value.primaryMuscles,
              musclesSecondary: value.secondaryMuscles,
            ),
          ),
          const MuscleColorHelper(main: true),
          const SizedBox(height: 5),
          const MuscleColorHelper(main: false),
        ],
      ),
    );
  }
}
