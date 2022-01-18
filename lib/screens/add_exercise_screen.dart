import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/add_excercise_provider.dart';
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

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  int _currentStep = 0;
  int lastStepIndex = AddExerciseScreen.STEPS_IN_FORM - 1;

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
            content: _BasicStepContent(),
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
            setState(() {
              _currentStep += 1;
            });
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
  final GlobalKey<FormState> _basicStepFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _basicStepFormKey,
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
          AddExerciseDropdownButton(
            title: 'Target area',
            items: ['Arms'],
            onChange: (value) => print(value),
          ),
          AddExerciseMultiselectButton(
            title: AppLocalizations.of(context).muscles,
            items: ['Arms', 'Chest', 'Shoulders'],
            onChange: (value) => print(value),
          ),
          AddExerciseMultiselectButton(
            title: AppLocalizations.of(context).musclesSecondary,
            items: ['Arms', 'Chest', 'Shoulders'],
            onChange: (value) => print(value),
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
          AppLocalizations.of(context).add_excercise_image_license,
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
