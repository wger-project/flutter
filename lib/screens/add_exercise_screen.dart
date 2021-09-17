import 'package:flutter/material.dart';
import 'package:wger/widgets/add_exercise/add_exercise_dropdown_button.dart';
import 'package:wger/widgets/add_exercise/add_exercise_multiselect_button.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';
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
            title: Text('Basics'),
            content: _BasicStepContent(),
          ),
          Step(
            title: Text('Duplicats and variations'),
            content: _DuplicatesAndVariationsStepContent(),
          ),
          Step(
            title: Text('Images'),
            content: _ImagesStepContent(),
          ),
          Step(
            title: Text('Description'),
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
            title: 'Name',
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
            title: 'Primary muscles',
            items: ['Arms', 'Chest', 'Shoulders'],
            onChange: (value) => print(value),
          ),
          AddExerciseMultiselectButton(
            title: 'Secondary Muscles',
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
            title: 'Name',
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

class _ImagesStepContent extends StatelessWidget {
  final GlobalKey<FormState> _imagesStepFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _imagesStepFormKey,
      child: Column(
        children: [
          AddExerciseTextArea(
            onChange: (value) => print(value),
            title: 'Name',
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
            title: 'Name',
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
