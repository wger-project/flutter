/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/exercise_state_notifier.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/exercise_screen.dart';
import 'package:wger/widgets/add_exercise/steps/step_1_basics.dart';
import 'package:wger/widgets/add_exercise/steps/step_2_variations.dart';
import 'package:wger/widgets/add_exercise/steps/step_3_description.dart';
import 'package:wger/widgets/add_exercise/steps/step_4_translations.dart';
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

class AddExerciseStepper extends ConsumerStatefulWidget {
  const AddExerciseStepper({super.key});

  static const STEPS_IN_FORM = 6;

  @override
  _AddExerciseStepperState createState() => _AddExerciseStepperState();
}

class _AddExerciseStepperState extends ConsumerState<AddExerciseStepper> {
  int _currentStep = 0;
  int lastStepIndex = AddExerciseStepper.STEPS_IN_FORM - 1;
  bool _isLoading = false;
  Widget errorWidget = const SizedBox.shrink();

  final List<GlobalKey<FormState>> _keys = [
    GlobalKey<FormState>(),
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
        if (_currentStep == lastStepIndex) errorWidget,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: details.onStepCancel,
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

                        Exercise? exercise;
                        try {
                          final exerciseId = await addExerciseProvider.postExerciseToServer();
                          exercise = ref.read(exerciseStateProvider.notifier).getById(exerciseId);
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
      body: WidescreenWrapper(
        child: Stepper(
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
            Step(title: Text(AppLocalizations.of(context).overview), content: Step6Overview()),
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
