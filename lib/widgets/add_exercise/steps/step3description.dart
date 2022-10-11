import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/exercises/forms.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';

class Step3Description extends StatelessWidget {
  final GlobalKey<FormState> formkey;
  const Step3Description({required this.formkey});

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
