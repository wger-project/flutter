import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/providers/add_excercise_provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/add_exercise/add_exercise_multiselect_button.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';
import 'package:wger/widgets/add_exercise/mixins/image_picker_mixin.dart';
import 'package:wger/widgets/add_exercise/preview_images.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/exercises/forms.dart';

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

  Widget _controlsBuilder(BuildContext context, ControlsDetails details) {
    return Row(
      children: [
        TextButton(
          onPressed: details.onStepContinue,
          child: Text(
            _currentStep != lastStepIndex
                ? AppLocalizations.of(context).next
                : AppLocalizations.of(context).save,
          ),
        ),
        TextButton(
          onPressed: details.onStepCancel,
          child: Text(AppLocalizations.of(context).previous),
        ),
      ],
    );
  }

  void _addExercise() {}

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
            content: _BasicStepContent(
              formkey: _keys[0],
            ),
          ),
          Step(
            title: Text(AppLocalizations.of(context).variations),
            content: _DuplicatesAndVariationsStepContent(),
          ),
          Step(
            title: Text(AppLocalizations.of(context).images),
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
            title: AppLocalizations.of(context).alternativeNames,
            isMultiline: true,
            helperText: AppLocalizations.of(context).oneNamePerLine,
            onSaved: (String? alternateName) =>
                addExercideProvider.alternateNames = alternateName!.split('\n'),
          ),
          ExerciseCategoryInputWidget<ExerciseCategory>(
              categories: categories,
              title: AppLocalizations.of(context).category,
              callback: (ExerciseCategory newValue) {
                addExercideProvider.targetArea = newValue;
              }),
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
          Text(AppLocalizations.of(context).whatVariationsExist),
          const Placeholder(fallbackHeight: 200),
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
