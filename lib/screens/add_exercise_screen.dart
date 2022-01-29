import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/add_excercise_provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/add_exercise/add_exercise_dropdown_button.dart';
import 'package:wger/widgets/add_exercise/add_exercise_multiselect_button.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';
import 'package:wger/widgets/add_exercise/mixins/image_picker_mixin.dart';
import 'package:wger/widgets/add_exercise/preview_images.dart';
import 'package:wger/widgets/core/app_bar.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({Key? key}) : super(key: key);

  static const routeName = '/exercises/add';
  static const STEPS_IN_FORM = 4;

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

abstract class ValidateStep {
  abstract VoidCallback _submit;
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  int _currentStep = 0;
  int lastStepIndex = AddExerciseScreen.STEPS_IN_FORM - 1;
  final List<GlobalKey<FormState>> _keys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];
  Widget _controlsBuilder(
    BuildContext context, {
    VoidCallback? onStepCancel,
    VoidCallback? onStepContinue,
  }) {
    return Row(
      children: [
        TextButton(
          onPressed: onStepContinue,
          child: Text(_currentStep != lastStepIndex ? 'Next' : 'Submit Exercise'),
        ),
        TextButton(
          onPressed: onStepCancel,
          child: const Text('Previous'),
        ),
      ],
    );
  }

  void _addExercise() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WgerAppBar(
        'Add Exercise',
      ),
      body: Stepper(
        controlsBuilder: _controlsBuilder,
        steps: [
          Step(
            title: const Text('Basics'),
            content: _BasicStepContent(
              formkey: _keys[0],
            ),
          ),
          Step(
            title: const Text('Duplicates and variations'),
            content: _DuplicatesAndVariationsStepContent(),
          ),
          Step(
            title: const Text('Images'),
            content: _ImagesStepContent(),
          ),
          Step(
            title: Text(AppLocalizations.of(context).description),
            content: _DescriptionStepContent(),
          )
        ],
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == lastStepIndex) {
            _addExercise();
          } else {
            if (_keys[_currentStep].currentState?.validate() ?? false) {
              _keys[_currentStep].currentState?.save();
              context.read<AddExcerciseProvider>().printValues();
              setState(() {
                _currentStep += 1;
              });
            }
          }
        },
        onStepCancel: () => setState(() {
          _currentStep -= 1;
        }),
      ),
    );
  }
}

class _BasicStepContent extends StatelessWidget {
  // final GlobalKey<FormState> _basicStepFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formkey;
  _BasicStepContent({required this.formkey});
  @override
  Widget build(BuildContext context) {
    final addExercideProvider = context.read<AddExcerciseProvider>();
    final exerciseProvider = context.read<ExercisesProvider>();
    final categories = exerciseProvider.categories;
    final muscles = exerciseProvider.muscles;
    return Form(
      key: formkey,
      child: Column(
        children: [
          AddExerciseTextArea(
            onChange: (value) => print(value),
            title: '${AppLocalizations.of(context).name}*',
            isRequired: true,
            validator: (name) => name?.isEmpty ?? true ? 'Name is required' : null,
            onSaved: (String? name) => addExercideProvider.exerciseName = name!,
          ),
          AddExerciseTextArea(
            onChange: (value) => print(value),
            title: 'Alternative names',
            isMultiline: true,
            helperText: 'One name per line',
            onSaved: (String? alternateName) => addExercideProvider.alternateName = alternateName,
          ),
          AddExerciseDropdownButton(
            title: 'Target area*',
            items: categories.map((e) => e.name).toList(),
            onChange: (value) => print(value),
            validator: (value) => value?.isEmpty ?? true ? 'Target Area is Required ' : null,
            onSaved: (String? targetArea) => addExercideProvider.targetArea = targetArea!,
          ),
          AddExerciseMultiselectButton(
            title: AppLocalizations.of(context).muscles,
            items: muscles.map((e) => e.name).toList(),
            onChange: (value) => print(value),
            onSaved: (List<String?>? muscles) => addExercideProvider.primaryMuclses = muscles,
          ),
          AddExerciseMultiselectButton(
            title: AppLocalizations.of(context).musclesSecondary,
            items: muscles.map((e) => e.name).toList(),
            onChange: (value) => print(value),
            onSaved: (List<String?>? muscles) => addExercideProvider.secondayMuclses = muscles,
          ),
        ],
      ),
    );
  }
}

class _DuplicatesAndVariationsStepContent extends StatelessWidget {
  final GlobalKey<FormState> _duplicatesAndVariationsFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _duplicatesAndVariationsFormKey,
      child: Column(
        children: [
          AddExerciseTextArea(
            onChange: (value) => print(value),
            title: AppLocalizations.of(context).name,
            isRequired: true,
          ),
          AddExerciseTextArea(
            onChange: (value) => print(value),
            title: 'Alternative names',
            isMultiline: true,
            helperText: 'One name per line',
          ),
        ],
      ),
    );
  }
}

class _ImagesStepContent extends StatefulWidget {
  @override
  State<_ImagesStepContent> createState() => _ImagesStepContentState();
}

class _ImagesStepContentState extends State<_ImagesStepContent> with ExcerciseImagePickerMixin {
  final GlobalKey<FormState> _imagesStepFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).add_exercise_image_license,
          style: Theme.of(context).textTheme.caption,
        ),
        Consumer<AddExcerciseProvider>(
          builder: (ctx, provider, __) => provider.excerciseImages.isNotEmpty
              ? PreviewExcercizeImages(
                  selectedimages: provider.excerciseImages,
                )
              : ElevatedButton(
                  onPressed: () => pickImages(context),
                  child: const Text('BROWSE FOR FILES'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.black)),
                ),
        ),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.caption,
            children: const <TextSpan>[
              TextSpan(text: 'Only JPEG, PNG and WEBP files below 20 MB are supported'),
            ],
          ),
        )
      ],
    );
  }
}

class _DescriptionStepContent extends StatelessWidget {
  final GlobalKey<FormState> _descriptionStepFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _descriptionStepFormKey,
      child: Column(
        children: [
          AddExerciseTextArea(
            onChange: (value) => print(value),
            title: AppLocalizations.of(context).name,
            isRequired: true,
          ),
          AddExerciseTextArea(
            onChange: (value) => print(value),
            title: 'Alternative names',
            isMultiline: true,
            helperText: 'One name per line',
          ),
        ],
      ),
    );
  }
}
