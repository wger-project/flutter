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
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
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
      builder: (ctx, provider, _) => Column(
        spacing: 8,
        children: [
          // Base data
          Text(i18n.baseData, style: Theme.of(context).textTheme.headlineSmall),
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
            children: [
              TableRow(children: [Text(i18n.author), Text(provider.author)]),
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
              TableRow(
                children: [
                  Text(i18n.description),
                  Html(data: md.markdownToHtml(provider.descriptionEn ?? '...')),
                ],
              ),
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

          // Translation
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
                children: [
                  Text(i18n.description),

                  // for consistent formatting, the thml element has other padding, etc
                  if (provider.descriptionTrans == null)
                    const Text('...')
                  else
                    Html(data: md.markdownToHtml(provider.descriptionTrans!)),
                ],
              ),
              TableRow(
                children: [
                  Text(i18n.language),
                  Text(provider.languageTranslation?.fullName ?? '...'),
                ],
              ),
            ],
          ),

          // Images
          if (provider.exerciseImages.isNotEmpty)
            PreviewExerciseImages(selectedImages: provider.exerciseImages, allowEdit: false),
          InfoCard(text: i18n.checkInformationBeforeSubmitting),
        ],
      ),
    );
  }
}
