/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:wger/helpers/exercises/validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/add_exercise_notifier.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';

class Step3Description extends ConsumerWidget {
  final GlobalKey<FormState> formkey;

  const Step3Description({required this.formkey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addExerciseProvider.notifier);
    final descriptionEn = ref.read(addExerciseProvider).descriptionEn;
    final i18n = AppLocalizations.of(context);

    return Form(
      key: formkey,
      child: Column(
        children: [
          AddExerciseTextArea(
            useMarkdownEditor: true,
            initialValue: descriptionEn ?? '',
            onChange: (value) => notifier.setDescriptionEn(value),
            title: '${i18n.description}*',
            helperText: i18n.enterTextInLanguage,
            isMultiline: true,
            validator: (name) => validateExerciseDescription(name, context),
            onSaved: (String? description) => notifier.setDescriptionEn(description),
          ),
        ],
      ),
    );
  }
}
