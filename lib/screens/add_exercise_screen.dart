import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/add_exercise_provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/add_exercise/add_exercise_multiselect_button.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';
import 'package:wger/widgets/add_exercise/mixins/image_picker_mixin.dart';
import 'package:wger/widgets/add_exercise/preview_images.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/exercises/exercises.dart';
import 'package:wger/widgets/exercises/forms.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({Key? key}) : super(key: key);

  static const routeName = '/exercises/add';
  static const STEPS_IN_FORM = 5;

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

abstract class ValidateStep {
  abstract VoidCallback _submit;
}

/// The amount of characters an exercise description needs to have
const MIN_CHARS_DESCRIPTION = 40;

/// The amount of characters an exercise name needs to have
const MIN_CHARS_NAME = 5;
const MAX_CHARS_NAME = 40;

String? validateName(String? name, BuildContext context) {
  if (name!.isEmpty) {
    return AppLocalizations.of(context).enterValue;
  }

  if (name.length < MIN_CHARS_NAME || name.length > MAX_CHARS_NAME) {
    return AppLocalizations.of(context).enterCharacters(MIN_CHARS_NAME, MAX_CHARS_NAME);
  }

  return null;
}

String? validateDescription(String? name, BuildContext context) {
  if (name!.isEmpty) {
    return AppLocalizations.of(context).enterValue;
  }

  if (name.length < MIN_CHARS_DESCRIPTION) {
    return AppLocalizations.of(context).enterMinCharacters(MIN_CHARS_DESCRIPTION);
  }

  return null;
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  int _currentStep = 0;
  int lastStepIndex = AddExerciseScreen.STEPS_IN_FORM - 1;
  final List<GlobalKey<FormState>> _keys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  Widget _controlsBuilder(BuildContext context, ControlsDetails details) {
    return Row(
      children: [
        if (_currentStep == lastStepIndex)
          ElevatedButton(
            onPressed: details.onStepContinue,
            child: Text(AppLocalizations.of(context).save),
          )
        else
          TextButton(
            onPressed: details.onStepContinue,
            child: Text(AppLocalizations.of(context).next),
          ),
        TextButton(
          onPressed: details.onStepCancel,
          child: Text(AppLocalizations.of(context).previous),
        ),
      ],
    );
  }

  void _addExercise() {
    log('Adding exercise...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WgerAppBar(
        AppLocalizations.of(context).addExercise,
      ),
      body: Stepper(
        controlsBuilder: _controlsBuilder,
        steps: [
          Step(
            title: Text(AppLocalizations.of(context).baseData),
            content: _BasicStepContent(formkey: _keys[0]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).variations),
            content: _DuplicatesAndVariationsStepContent(formkey: _keys[1]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).description),
            content: _DescriptionStepContent(formkey: _keys[2]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).translation),
            content: _DescriptionTranslationStepContent(formkey: _keys[3]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).images),
            content: _ImagesStepContent(formkey: _keys[4]),
          ),
        ],
        currentStep: _currentStep,
        onStepContinue: () {
          log('Validation for step $_currentStep: ${_keys[_currentStep].currentState?.validate()}');

          if (_keys[_currentStep].currentState?.validate() ?? false) {
            _keys[_currentStep].currentState?.save();
            context.read<AddExerciseProvider>().addExercise();

            if (_currentStep != lastStepIndex) {
              setState(() {
                _currentStep += 1;
              });
            }
          }

          if (_currentStep == lastStepIndex) {
            _addExercise();
          }
        },
        onStepCancel: () => setState(() {
          if (_currentStep != 0) {
            _currentStep -= 1;
          }
        }),
        onStepTapped: (int index) {
          //setState(() {
          //  _currentStep = index;
          //});
        },
      ),
    );
  }
}

class _BasicStepContent extends StatelessWidget {
  final GlobalKey<FormState> formkey;
  const _BasicStepContent({required this.formkey});

  @override
  Widget build(BuildContext context) {
    final addExerciseProvider = context.read<AddExerciseProvider>();
    final exerciseProvider = context.read<ExercisesProvider>();
    final categories = exerciseProvider.categories;
    final muscles = exerciseProvider.muscles;
    final equipment = exerciseProvider.equipment;
    final languages = exerciseProvider.languages;

    // Initialize some values
    addExerciseProvider.category = categories.first;
    addExerciseProvider.language = languages.first;

    return Form(
      key: formkey,
      child: Column(
        children: [
          const Text('All exercises need a base name in English'),
          AddExerciseTextArea(
            onChange: (value) => {},
            title: '${AppLocalizations.of(context).name}*',
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
            categories: categories,
            title: AppLocalizations.of(context).category,
            callback: (ExerciseCategory newValue) {
              addExerciseProvider.category = newValue;
            },
            displayName: (ExerciseCategory c) => c.name,
          ),
          AddExerciseMultiselectButton<Equipment>(
            title: AppLocalizations.of(context).equipment,
            items: equipment,
            initialItems: addExerciseProvider.equipment,
            onChange: (dynamic entries) {
              addExerciseProvider.equipment = entries.cast<Equipment>();
            },
            onSaved: (dynamic entries) {
              addExerciseProvider.equipment = entries.cast<Equipment>();
            },
          ),
          AddExerciseMultiselectButton<Muscle>(
            title: AppLocalizations.of(context).muscles,
            items: muscles,
            initialItems: addExerciseProvider.primaryMuscles,
            onChange: (dynamic muscles) {
              addExerciseProvider.primaryMuscles = muscles.cast<Muscle>();
            },
            onSaved: (dynamic muscles) {
              addExerciseProvider.primaryMuscles = muscles.cast<Muscle>();
            },
          ),
          AddExerciseMultiselectButton<Muscle>(
            title: AppLocalizations.of(context).musclesSecondary,
            items: muscles,
            initialItems: addExerciseProvider.secondaryMuscles,
            onChange: (dynamic muscles) {
              addExerciseProvider.secondaryMuscles = muscles.cast<Muscle>();
            },
            onSaved: (dynamic muscles) {
              addExerciseProvider.secondaryMuscles = muscles.cast<Muscle>();
            },
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

class _DuplicatesAndVariationsStepContent extends StatelessWidget {
  final GlobalKey<FormState> formkey;

  const _DuplicatesAndVariationsStepContent({required this.formkey});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      child: Column(
        children: [
          Text(AppLocalizations.of(context).whatVariationsExist),
          const Placeholder(fallbackHeight: 200),
        ],
      ),
    );
  }
}

class _ImagesStepContent extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  const _ImagesStepContent({required this.formkey});

  @override
  State<_ImagesStepContent> createState() => _ImagesStepContentState();
}

class _ImagesStepContentState extends State<_ImagesStepContent> with ExerciseImagePickerMixin {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formkey,
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).add_exercise_image_license,
            style: Theme.of(context).textTheme.caption,
          ),
          Consumer<AddExerciseProvider>(
            builder: (ctx, provider, __) => provider.exerciseImages.isNotEmpty
                ? PreviewExerciseImages(
                    selectedImages: provider.exerciseImages,
                  )
                : ElevatedButton(
                    onPressed: () => pickImages(context),
                    child: const Text('BROWSE FOR FILES'),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith((states) => Colors.black)),
                  ),
          ),
          Text(
            'Only JPEG, PNG and WEBP files below 20 MB are supported',
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }
}

class _DescriptionStepContent extends StatelessWidget {
  final GlobalKey<FormState> formkey;
  const _DescriptionStepContent({required this.formkey});

  @override
  Widget build(BuildContext context) {
    final addExerciseProvider = context.read<AddExerciseProvider>();

    return Form(
      key: formkey,
      child: Column(
        children: [
          AddExerciseTextArea(
            onChange: (value) => {},
            title: '${AppLocalizations.of(context).description}*',
            isRequired: true,
            isMultiline: true,
            validator: (name) => validateDescription(name, context),
            onSaved: (String? description) => addExerciseProvider.descriptionEn = description!,
          ),
        ],
      ),
    );
  }
}

class _DescriptionTranslationStepContent extends StatelessWidget {
  final GlobalKey<FormState> formkey;
  const _DescriptionTranslationStepContent({required this.formkey});

  @override
  Widget build(BuildContext context) {
    final addExerciseProvider = context.read<AddExerciseProvider>();
    final exerciseProvider = context.read<ExercisesProvider>();

    final languages = exerciseProvider.languages;

    return Form(
      key: formkey,
      child: Column(
        children: [
          ExerciseCategoryInputWidget<Language>(
            categories: languages,
            title: AppLocalizations.of(context).language,
            displayName: (Language l) => l.fullName,
            callback: (Language newValue) {
              addExerciseProvider.language = newValue;
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
            onSaved: (String? description) => addExerciseProvider.descriptionTrans = description!,
          ),
        ],
      ),
    );
  }
}
