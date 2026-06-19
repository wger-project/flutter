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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/add_exercise_notifier.dart';
import 'package:wger/widgets/add_exercise/preview_images.dart';
import 'package:wger/widgets/core/cards.dart';

class Step6Overview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final state = ref.watch(addExerciseProvider);

    return Column(
      spacing: 8,
      children: [
        // Base data
        Text(i18n.baseData, style: Theme.of(context).textTheme.headlineSmall),
        Table(
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
          children: [
            TableRow(children: [Text(i18n.author), Text(state.author)]),
            TableRow(children: [Text(i18n.name), Text(state.exerciseNameEn ?? '...')]),
            TableRow(
              children: [
                Text(i18n.alternativeNames),
                Text(
                  state.alternateNamesEn.isNotEmpty ? state.alternateNamesEn.join('\n') : '...',
                ),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.description),
                Html(data: md.markdownToHtml(state.descriptionEn ?? '...')),
              ],
            ),
            TableRow(children: [Text(i18n.category), Text(state.category?.name ?? '...')]),
            TableRow(
              children: [
                Text(i18n.muscles),
                Text(
                  state.primaryMuscles.isNotEmpty
                      ? state.primaryMuscles.map((m) => m.name).join('\n')
                      : '...',
                ),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.musclesSecondary),
                Text(
                  state.secondaryMuscles.isNotEmpty
                      ? state.secondaryMuscles.map((m) => m.name).join('\n')
                      : '...',
                ),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.equipment),
                Text(
                  state.equipment.isNotEmpty
                      ? state.equipment.map((m) => m.name).join('\n')
                      : '...',
                ),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.variations),
                Text(
                  state.variationGroup != null
                      ? 'Using variation group ${state.variationGroup}'
                      : state.variationConnectToExercise != null
                      ? 'Connecting to exercise ${state.variationConnectToExercise}'
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
            TableRow(children: [Text(i18n.name), Text(state.exerciseNameTrans ?? '...')]),
            TableRow(
              children: [
                Text(i18n.alternativeNames),
                Text(
                  state.alternateNamesTrans.isNotEmpty
                      ? state.alternateNamesTrans.join('\n')
                      : '...',
                ),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.description),

                // for consistent formatting, the thml element has other padding, etc
                if (state.descriptionTrans == null)
                  const Text('...')
                else
                  Html(data: md.markdownToHtml(state.descriptionTrans!)),
              ],
            ),
            TableRow(
              children: [
                Text(i18n.language),
                Text(state.languageTranslation?.fullName ?? '...'),
              ],
            ),
          ],
        ),

        // Images
        if (state.exerciseImages.isNotEmpty)
          PreviewExerciseImages(selectedImages: state.exerciseImages, allowEdit: false),
        InfoCard(text: i18n.checkInformationBeforeSubmitting),
      ],
    );
  }
}
