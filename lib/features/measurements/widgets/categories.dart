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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/widgets/async_value_widget.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/widgets/chart_range_selector.dart';

import 'categories_card.dart';

class CategoriesList extends ConsumerStatefulWidget {
  const CategoriesList();

  @override
  ConsumerState<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends ConsumerState<CategoriesList> {
  // One range for all cards: picking it per card would put three buttons on
  // every entry of the list
  ChartRange _range = ChartRange.last3Months;

  @override
  Widget build(BuildContext context) {
    return AsyncValueWidget<List<MeasurementCategory>>(
      // Only the entries the range charts are read: a synced account holds
      // years of them, and this list draws three months by default
      value: ref.watch(measurementCategoriesSinceProvider(_range.readCutoff)),
      loggerName: 'CategoriesList',
      data: (categoriesList) {
        // Children of multi-value groups are rendered inside their parent's
        // card, not as own list items. Body weight has its own screens.
        final topLevel = categoriesList
            .where((c) => c.parentId == null && !c.isOfficialBodyWeight)
            .toList();

        return Column(
          children: [
            const SizedBox(height: 10),
            ChartRangeSelector(
              value: _range,
              onChanged: (range) => setState(() => _range = range),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: topLevel.length,
                itemBuilder: (context, index) => CategoriesCard(topLevel[index], range: _range),
              ),
            ),
          ],
        );
      },
    );
  }
}
