import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/widgets/add_exercise/preview_images.dart';
import 'package:wger/widgets/core/cards.dart';

class Step6Overview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Consumer<AddExerciseProvider>(
      builder: (ctx, provider, __) => Column(
        spacing: 8,
        children: [
          Text(i18n.baseData, style: Theme.of(context).textTheme.headlineSmall),
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
            children: [
              TableRow(children: [Text(i18n.name), Text(provider.exerciseNameEn ?? '...')]),
              TableRow(
                children: [
                  Text(i18n.alternativeNames),
                  Text(
                    provider.alternateNamesEn.isNotEmpty
                        ? provider.alternateNamesEn.join('\n')
                        : '...',
                  ),
                ],
              ),
              TableRow(children: [Text(i18n.description), Text(provider.descriptionEn ?? '...')]),
              TableRow(children: [Text(i18n.category), Text(provider.category?.name ?? '...')]),
              TableRow(
                children: [
                  Text(i18n.muscles),
                  Text(
                    provider.primaryMuscles.isNotEmpty
                        ? provider.primaryMuscles.map((m) => m.name).join('\n')
                        : '...',
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text(i18n.musclesSecondary),
                  Text(
                    provider.secondaryMuscles.isNotEmpty
                        ? provider.secondaryMuscles.map((m) => m.name).join('\n')
                        : '...',
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text(i18n.equipment),
                  Text(
                    provider.equipment.isNotEmpty
                        ? provider.equipment.map((m) => m.name).join('\n')
                        : '...',
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text(i18n.variations),
                  Text(
                    provider.variationId != null
                        ? 'Using variation ID ${provider.variationId}'
                        : provider.variationConnectToExercise != null
                        ? 'Connecting to exercise ${provider.variationConnectToExercise}'
                        : '',
                  ),
                ],
              ),
            ],
          ),
          Text(i18n.translation, style: Theme.of(context).textTheme.headlineSmall),
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
            children: [
              TableRow(children: [Text(i18n.name), Text(provider.exerciseNameTrans ?? '...')]),
              TableRow(
                children: [
                  Text(i18n.alternativeNames),
                  Text(
                    provider.alternateNamesTrans.isNotEmpty
                        ? provider.alternateNamesTrans.join('\n')
                        : '...',
                  ),
                ],
              ),
              TableRow(
                children: [Text(i18n.description), Text(provider.descriptionTrans ?? '...')],
              ),
              TableRow(
                children: [
                  Text(i18n.language),
                  Text(provider.languageTranslation?.fullName ?? '...'),
                ],
              ),
            ],
          ),
          if (provider.exerciseImages.isNotEmpty)
            PreviewExerciseImages(selectedImages: provider.exerciseImages, allowEdit: false),
          InfoCard(text: i18n.checkInformationBeforeSubmitting),
        ],
      ),
    );
  }
}
