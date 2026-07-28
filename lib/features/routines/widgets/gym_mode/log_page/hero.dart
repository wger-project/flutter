/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

part of '../log_page.dart';

// ---------------------------------------------------------------------------
// Exercise hero
// ---------------------------------------------------------------------------

class _ExerciseHero extends StatelessWidget {
  final Exercise? exercise;
  final List<Exercise> exercises;
  final int? activeExerciseId;
  final bool isSuperset;
  final SetConfigData? firstConfig;
  final String languageCode;
  const _ExerciseHero({
    required this.exercise,
    required this.exercises,
    required this.activeExerciseId,
    required this.isSuperset,
    required this.firstConfig,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = GymPalette.of(context);
    final i18n = AppLocalizations.of(context);
    final ex = exercise;

    final exerciseName = ex?.getTranslation(languageCode).name ?? '';
    final targetText = firstConfig?.textRepr ?? '';
    final comment = firstConfig?.comment ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.divider, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSuperset)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      i18n.superset.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.08,
                        color: p.onAccent,
                      ),
                    ),
                  ),
                  for (var i = 0; i < exercises.length; i++)
                    Builder(
                      builder: (context) {
                        final isActive = exercises[i].id == activeExerciseId;
                        final letter = String.fromCharCode(65 + i); // A, B, C…
                        final name = exercises[i].getTranslation(languageCode).name;
                        return Text(
                          '$letter · $name',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? p.onAccentTint : p.textSecondary,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    if (targetText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                          decoration: BoxDecoration(
                            color: p.accentTint,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            targetText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: p.onAccentTint,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: p.accentTint,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: 15,
                    color: p.onAccentTint,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      comment,
                      style: TextStyle(
                        fontSize: 12,
                        color: p.onAccentTint,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
