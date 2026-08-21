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
import 'package:wger/features/measurements/models/measurement_calculation.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Marks a category whose entries the server computes, and names what they are
/// computed from.
///
/// The mark sits on the category rather than on every one of its entries: all
/// of them are calculated, so a badge per row would repeat the same thing for
/// each value. Renders nothing for a hand-kept category.
class CalculationMark extends ConsumerWidget {
  const CalculationMark(this.category, {this.dense = false, super.key});

  final MeasurementCategory category;

  /// Badge and provenance share one line instead of stacking. For the overview
  /// tile, which is sized to the rows it already has.
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!category.isCalculated) {
      return const SizedBox.shrink();
    }

    final badge = _Badge(dense: dense);
    // The ratio names the category it reads, so its sentence needs the name
    final sourceId = category.dynamicParams?['category_id'];
    final source = (ref.watch(measurementCategoriesProvider).value ?? const <MeasurementCategory>[])
        .where((candidate) => candidate.id == sourceId)
        .firstOrNull;
    final description = calculationTypeOf(
      category.dynamicType,
    )?.localizedDescription(context, category: source?.displayName(context) ?? '');

    // Not every calculation brings a sentence, and one from a newer server
    // brings none either: the badge alone is what is still true of it
    if (description == null) {
      return badge;
    }

    final provenance = Text(
      description,
      style: Theme.of(context).textTheme.bodySmall,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (dense) {
      return Row(
        children: [
          badge,
          const SizedBox(width: 6),
          Expanded(child: provenance),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        badge,
        const SizedBox(height: 4),
        provenance,
      ],
    );
  }
}

/// The badge itself: outlined rather than filled, it qualifies the category
/// instead of competing with its value.
class _Badge extends StatelessWidget {
  const _Badge({required this.dense});

  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 4 : 6, vertical: dense ? 0 : 2),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        AppLocalizations.of(context).calculationBadge,
        style: (dense ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
