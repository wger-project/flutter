import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/widgets/core/cards.dart';

class Step6Overview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final addExerciseProvider = context.read<AddExerciseProvider>();

    return Column(
      spacing: 8,
      children: [
        Text(
          i18n.baseData,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              children: [
                Text(i18n.name),
                Text(addExerciseProvider.exerciseNameEn ?? '...'),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.alternativeNames),
                Text(
                  addExerciseProvider.alternateNamesEn.isNotEmpty
                      ? addExerciseProvider.alternateNamesEn.join('\n')
                      : '...',
                ),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.description),
                Text(addExerciseProvider.descriptionEn ?? '...'),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.category),
                Text(addExerciseProvider.category?.name ?? '...'),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.muscles),
                Text(
                  addExerciseProvider.primaryMuscles.isNotEmpty
                      ? addExerciseProvider.primaryMuscles.map((m) => m.name).join('\n')
                      : '...',
                ),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.musclesSecondary),
                Text(
                  addExerciseProvider.secondaryMuscles.isNotEmpty
                      ? addExerciseProvider.secondaryMuscles.map((m) => m.name).join('\n')
                      : '...',
                ),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.equipment),
                Text(
                  addExerciseProvider.equipment.isNotEmpty
                      ? addExerciseProvider.equipment.map((m) => m.name).join('\n')
                      : '...',
                ),
              ],
            ),
          ],
        ),
        Text(
          i18n.translation,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              children: [
                Text(i18n.name),
                Text(addExerciseProvider.exerciseNameTrans ?? '...'),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.alternativeNames),
                Text(
                  addExerciseProvider.alternateNamesTrans.isNotEmpty
                      ? addExerciseProvider.alternateNamesTrans.join('\n')
                      : '...',
                ),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.description),
                Text(addExerciseProvider.descriptionTrans ?? '...'),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.language),
                Text(addExerciseProvider.languageTranslation?.fullName ?? '...'),
              ],
            ),
          ],
        ),
        InfoCard(text: i18n.checkInformationBeforeSubmitting)
      ],
    );
  }
}
