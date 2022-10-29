import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/widgets/add_exercise/add_exercise_html_editor.dart';

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
          AddExerciseHtmlEditor(
            helperText: AppLocalizations.of(context).description,
          ),
        ],
      ),
    );
  }
}
