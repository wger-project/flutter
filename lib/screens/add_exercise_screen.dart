import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/exercise_screen.dart';
import 'package:wger/widgets/add_exercise/steps/step_1_basics.dart';
import 'package:wger/widgets/add_exercise/steps/step_2_variations.dart';
import 'package:wger/widgets/add_exercise/steps/step_3_description.dart' as step3;
import 'package:wger/widgets/add_exercise/steps/step_4_translations.dart' as step4;
import 'package:wger/widgets/add_exercise/steps/step_5_images.dart';
import 'package:wger/widgets/add_exercise/steps/step_6_overview.dart';
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

  static const STEPS_IN_FORM = 6;

  @override
  _AddExerciseStepperState createState() => _AddExerciseStepperState();
}

class _AddExerciseStepperState extends State<AddExerciseStepper> {
  int _currentStep = 0;
  int lastStepIndex = AddExerciseStepper.STEPS_IN_FORM - 1;
  bool _isLoading = false;
  bool _isValidating = false;
  Widget errorWidget = const SizedBox.shrink();
  WgerHttpException? _validationError;

  final List<GlobalKey<FormState>> _keys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  Future<bool> _validateLanguageOnServer(BuildContext context) async {
    final addExerciseProvider = context.read<AddExerciseProvider>();

    try {
      if (_currentStep == 2) {
        await addExerciseProvider.validateLanguage(
          addExerciseProvider.descriptionEn ?? '',
          'en',
        );
      }

      if (_currentStep == 3 && addExerciseProvider.descriptionTrans != null) {
        final languageCode = addExerciseProvider.languageTranslation?.shortName ?? '';
        if (languageCode.isNotEmpty) {
          await addExerciseProvider.validateLanguage(
            addExerciseProvider.descriptionTrans ?? '',
            languageCode,
          );
        }
      }

      return true;
    } on WgerHttpException catch (error) {
      if (mounted) {
        setState(() {
          _validationError = error;
        });
      }
      return false;
    } catch (error) {
      if (mounted) {
        setState(() {
          _validationError = WgerHttpException({'error': [error.toString()]});
        });
      }
      return false;
    }
  }

  Widget _controlsBuilder(BuildContext context, ControlsDetails details) {
    return Column(
      children: [
        const SizedBox(height: 10),

        if (_validationError != null && _currentStep != lastStepIndex)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: FormHttpErrorsWidget(_validationError!),
          ),

        if (_currentStep == lastStepIndex) errorWidget,

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: _isValidating ? null : details.onStepCancel,
              child: Text(AppLocalizations.of(context).previous),
            ),

            // Submit button on last step
            if (_currentStep == lastStepIndex)
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                  setState(() {
                    _isLoading = true;
                    errorWidget = const SizedBox.shrink();
                  });
                  final addExerciseProvider = context.read<AddExerciseProvider>();
                  final exerciseProvider = context.read<ExercisesProvider>();

                  Exercise? exercise;
                  try {
                    final exerciseId = await addExerciseProvider.postExerciseToServer();
                    exercise = await exerciseProvider.fetchAndSetExercise(exerciseId);
                  } on WgerHttpException catch (error) {
                    if (context.mounted) {
                      setState(() {
                        errorWidget = FormHttpErrorsWidget(error);
                      });
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }

                  if (exercise == null || !context.mounted) {
                    return;
                  }

                  final name = exercise
                      .getTranslation(Localizations.localeOf(context).languageCode)
                      .name;

                  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context).success),
                        content: Text(AppLocalizations.of(context).cacheWarning),
                        actions: [
                          TextButton(
                            child: Text(name),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacementNamed(
                                context,
                                ExerciseDetailScreen.routeName,
                                arguments: exercise,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                    : Text(AppLocalizations.of(context).save),
              )
            else
              ElevatedButton(
                onPressed: _isValidating
                    ? null
                    : () async {
                  setState(() {
                    _validationError = null;
                  });

                  if (!(_keys[_currentStep].currentState?.validate() ?? false)) {
                    return;
                  }

                  _keys[_currentStep].currentState?.save();

                  if (_currentStep == 2 || _currentStep == 3) {
                    setState(() {
                      _isValidating = true;
                    });

                    final isValid = await _validateLanguageOnServer(context);

                    if (mounted) {
                      setState(() {
                        _isValidating = false;
                      });
                    }

                    if (!isValid) {
                      return;
                    }
                  }

                  if (_currentStep != lastStepIndex) {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                },
                child: _isValidating
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(AppLocalizations.of(context).next),
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
            content: step3.Step3Description(formkey: _keys[2]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).translation),
            content: step4.Step4Translation(formkey: _keys[3]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).images),
            content: Step5Images(formkey: _keys[4]),
          ),
          Step(
            title: Text(AppLocalizations.of(context).overview),
            content: Step6Overview(),
          ),
        ],
        currentStep: _currentStep,
        onStepContinue: null, // Použijeme vlastnú logiku v _controlsBuilder
        onStepCancel: () => setState(() {
          if (_currentStep != 0) {
            _currentStep -= 1;
            _validationError = null; // Resetovať chybu pri návrate
          }
        }),
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
                  subtitle: Text(
                    AppLocalizations.of(
                      context,
                    ).contributeExerciseWarning(MIN_ACCOUNT_AGE.toString()),
                  ),
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