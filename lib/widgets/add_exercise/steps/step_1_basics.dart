import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer;
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/exercises/validators.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/core_data.dart';
import 'package:wger/providers/exercise_data.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/widgets/add_exercise/add_exercise_multiselect_button.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';
import 'package:wger/widgets/exercises/exercises.dart';
import 'package:wger/widgets/exercises/forms.dart';

class Step1Basics extends ConsumerWidget {
  final GlobalKey<FormState> formkey;

  const Step1Basics({required this.formkey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProvider = context.read<UserProvider>();
    final addExerciseProvider = context.read<AddExerciseProvider>();

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
    addExerciseProvider.languageEn = matched.isNotEmpty ? matched.first : null;

    return Form(
      key: formkey,
      child: Consumer<AddExerciseProvider>(
        builder: (context, provider, child) => Column(
          children: [
            AddExerciseTextArea(
              title: '${AppLocalizations.of(context).name}*',
              helperText: AppLocalizations.of(context).baseNameEnglish,
              validator: (name) => validateName(name, context),
              onSaved: (String? name) => addExerciseProvider.exerciseNameEn = name,
            ),
            AddExerciseTextArea(
              title: AppLocalizations.of(context).alternativeNames,
              isMultiline: true,
              helperText: AppLocalizations.of(context).oneNamePerLine,
              onSaved: (String? alternateName) =>
                  addExerciseProvider.alternateNamesEn = alternateName!.split('\n'),
            ),
            AddExerciseTextArea(
              title: '${AppLocalizations.of(context).author}*',
              isMultiline: false,
              validator: (name) => validateAuthorName(name, context),
              initialValue: userProvider.profile!.username,
              onSaved: (String? author) => addExerciseProvider.author = author!,
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
              displayName: (ExerciseCategory c) => getServerStringTranslation(c.name, context),
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
              displayName: (Equipment e) => getServerStringTranslation(e.name, context),
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
                  e.name +
                  (e.nameEn.isNotEmpty
                      ? '\n(${getServerStringTranslation(e.nameEn, context)})'
                      : ''),
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
                  e.name +
                  (e.nameEn.isNotEmpty
                      ? '\n(${getServerStringTranslation(e.nameEn, context)})'
                      : ''),
            ),
            MuscleRowWidget(
              muscles: provider.primaryMuscles,
              musclesSecondary: provider.secondaryMuscles,
            ),
            const MuscleColorHelper(main: true),
            const SizedBox(height: 5),
            const MuscleColorHelper(main: false),
          ],
        ),
      ),
    );
  }
}
