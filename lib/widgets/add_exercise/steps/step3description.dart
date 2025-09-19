import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/exercises/forms.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';

class Step3Description extends StatelessWidget {
  final GlobalKey<FormState> formkey;

  const Step3Description({required this.formkey});

  @override
  Widget build(BuildContext context) {
    final addExerciseProvider = context.read<AddExerciseProvider>();
    final i18n = AppLocalizations.of(context);

    return Form(
      key: formkey,
      child: Column(
        children: [
          AddExerciseTextArea(
            onChange: (value) => {},
            title: '${i18n.description}*',
            helperText: i18n.enterTextInLanguage,
            isRequired: true,
            isMultiline: true,
            validator: (name) => validateExerciseDescription(name, context),
            onSaved: (String? description) => addExerciseProvider.descriptionEn = description!,
          ),
        ],
      ),
    );
  }
}
