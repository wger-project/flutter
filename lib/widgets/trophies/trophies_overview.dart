/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2025 - 2026 wger Team
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
import 'package:wger/helpers/material.dart';
import 'package:wger/models/trophies/user_trophy_progression.dart';
import 'package:wger/providers/trophies.dart';

class TrophiesOverview extends ConsumerWidget {
  const TrophiesOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trophyState = ref.watch(trophyStateProvider);

    // Responsive grid: determine columns based on screen width
    final width = MediaQuery.widthOf(context);
    int crossAxisCount = 1;
    if (width <= MATERIAL_XS_BREAKPOINT) {
      crossAxisCount = 2;
    } else if (width > MATERIAL_XS_BREAKPOINT && width < MATERIAL_MD_BREAKPOINT) {
      crossAxisCount = 3;
    } else if (width >= MATERIAL_MD_BREAKPOINT && width < MATERIAL_LG_BREAKPOINT) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 5;
    }

    // If empty, show placeholder
    if (trophyState.trophyProgression.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No trophies yet',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ),
        key: const ValueKey('trophy-grid'),
        itemCount: trophyState.trophyProgression.length,
        itemBuilder: (context, index) {
          return _TrophyCardImage(userProgression: trophyState.trophyProgression[index]);
        },
      ),
    );
  }
}

class _TrophyCardImage extends StatelessWidget {
  final UserTrophyProgression userProgression;

  const _TrophyCardImage({required this.userProgression});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double progress = (userProgression.progress.toDouble() / 100.0).clamp(0.0, 1.0);

    return Opacity(
      opacity: userProgression.isEarned ? 1.0 : 0.5,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
            width: userProgression.isEarned ? 1.2 : 0,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: ClipOval(
                      child: Image.network(
                        userProgression.trophy.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.emoji_events, size: 28, color: colorScheme.primary),
                        ),
                      ),
                    ),
                  ),

                  Text(
                    userProgression.trophy.name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  Text(
                    userProgression.trophy.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  if (userProgression.trophy.isProgressive && !userProgression.isEarned)
                    Tooltip(
                      message: 'Progress: ${userProgression.progressDisplay}',
                      child: SizedBox(
                        height: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                            backgroundColor: colorScheme.onSurface.withAlpha((0.06 * 255).round()),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (userProgression.isEarned)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
