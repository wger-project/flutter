import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/add_exercise_provider.dart';
import 'package:wger/widgets/add_exercise/steps/basics.dart';
import 'package:wger/widgets/add_exercise/steps/description.dart';
import 'package:wger/widgets/add_exercise/steps/images.dart';
import 'package:wger/widgets/add_exercise/steps/translations.dart';
import 'package:wger/widgets/add_exercise/steps/variations.dart';
import 'package:wger/widgets/core/app_bar.dart';

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
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (_currentStep == lastStepIndex)
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(AppLocalizations.of(context).save),
              )
            else
              OutlinedButton(
                onPressed: details.onStepContinue,
                child: Text(AppLocalizations.of(context).next),
              ),
            OutlinedButton(
              onPressed: details.onStepCancel,
              child: Text(AppLocalizations.of(context).previous),
            ),
          ],
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
      appBar: EmptyAppBar(AppLocalizations.of(context).contributeExercise),
      body: Stepper(
        controlsBuilder: _controlsBuilder,
        steps: [
          Step(
            title: Text(AppLocalizations.of(context).baseData),
            content: BasicStepContent(formkey: _keys[0]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).variations),
            content: DuplicatesAndVariationsStepContent(formkey: _keys[1]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).description),
            content: DescriptionStepContent(formkey: _keys[2]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).translation),
            content: DescriptionTranslationStepContent(formkey: _keys[3]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).images),
            content: ImagesStepContent(formkey: _keys[4]),
          ),
        ],
        currentStep: _currentStep,
        onStepContinue: () {
          log('Validation for step $_currentStep: ${_keys[_currentStep].currentState?.validate()}');

          if (_keys[_currentStep].currentState?.validate() ?? false) {
            _keys[_currentStep].currentState?.save();

            if (_currentStep != lastStepIndex) {
              setState(() {
                _currentStep += 1;
              });
            }
          }

          if (_currentStep == lastStepIndex) {
            _addExercise();
            context.read<AddExerciseProvider>().addExercise();
          }
        },
        onStepCancel: () => setState(() {
          if (_currentStep != 0) {
            _currentStep -= 1;
          }
        }),
        /*
        onStepTapped: (int index) {
          setState(() {
            _currentStep = index;
          });
        },
         */
      ),
    );
  }
}
