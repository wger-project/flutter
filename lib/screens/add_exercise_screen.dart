import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/exercise_screen.dart';
import 'package:wger/widgets/add_exercise/steps/step1basics.dart';
import 'package:wger/widgets/add_exercise/steps/step2variations.dart';
import 'package:wger/widgets/add_exercise/steps/step3description.dart';
import 'package:wger/widgets/add_exercise/steps/step4translations.dart';
import 'package:wger/widgets/add_exercise/steps/step5images.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/user/forms.dart';

import 'form_screen.dart';

class AddExerciseScreen extends StatelessWidget {
  const AddExerciseScreen({super.key});

  static const routeName = '/exercises/add';

  @override
  Widget build(BuildContext context) {
    final profile = context.read<UserProvider>().profile;

    return profile!.isTrustworthy ? const AddExerciseStepper() : const EmailNotVerified();
  }
}

class AddExerciseStepper extends StatefulWidget {
  const AddExerciseStepper({super.key});

  static const STEPS_IN_FORM = 5;

  @override
  _AddExerciseStepperState createState() => _AddExerciseStepperState();
}

class _AddExerciseStepperState extends State<AddExerciseStepper> {
  int _currentStep = 0;
  int lastStepIndex = AddExerciseStepper.STEPS_IN_FORM - 1;
  bool _isLoading = false;

  final List<GlobalKey<FormState>> _keys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  Widget _controlsBuilder(BuildContext context, ControlsDetails details) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: details.onStepCancel,
              child: Text(AppLocalizations.of(context).previous),
            ),
            if (_currentStep == lastStepIndex)
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final addExerciseProvider = context.read<AddExerciseProvider>();
                        final exerciseProvider = context.read<ExercisesProvider>();

                        final baseId = await addExerciseProvider.addExercise();
                        final base = await exerciseProvider.fetchAndSetExercise(baseId);
                        final name = base
                            .getExercise(
                              Localizations.localeOf(context).languageCode,
                            )
                            .name;

                        setState(() {
                          _isLoading = false;
                        });

                        if (!context.mounted) return;
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context).success),
                              content: Text(
                                AppLocalizations.of(context).cacheWarning,
                              ),
                              actions: [
                                TextButton(
                                  child: Text(name),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacementNamed(
                                      context,
                                      ExerciseDetailScreen.routeName,
                                      arguments: base,
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(AppLocalizations.of(context).save),
              )
            else
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(AppLocalizations.of(context).next),
              ),
          ],
        ),
      ],
    );
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
            content: Step1Basics(formkey: _keys[0]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).variations),
            content: Step2Variations(formkey: _keys[1]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).description),
            content: Step3Description(formkey: _keys[2]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).translation),
            content: Step4Translation(formkey: _keys[3]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).images),
            content: Step5Images(formkey: _keys[4]),
          ),
        ],
        currentStep: _currentStep,
        onStepContinue: () {
          if (_keys[_currentStep].currentState?.validate() ?? false) {
            _keys[_currentStep].currentState?.save();

            if (_currentStep != lastStepIndex) {
              setState(() {
                _currentStep += 1;
              });
            }
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

class EmailNotVerified extends StatelessWidget {
  const EmailNotVerified({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().profile;

    return Scaffold(
      appBar: EmptyAppBar(AppLocalizations.of(context).unVerifiedEmail),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.warning),
                  title: Text(AppLocalizations.of(context).unVerifiedEmail),
                  subtitle: Text(AppLocalizations.of(context)
                      .contributeExerciseWarning(MIN_ACCOUNT_AGE.toString())),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          FormScreen.routeName,
                          arguments: FormScreenArguments(
                            AppLocalizations.of(context).userProfile,
                            UserProfileForm(user!),
                          ),
                        );
                      },
                      child: Text(AppLocalizations.of(context).userProfile),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
