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
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/core/widgets/async_value_widget.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Drag-and-drop reordering of the top-level measurement categories.
///
/// Children of multi-value groups are not listed; they keep their in-group
/// order and follow their parent.
class MeasurementCategorySortScreen extends ConsumerWidget {
  static const routeName = '/measurement-categories-sort';

  const MeasurementCategorySortScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.reorderCategories),
      ),
      body: WidescreenWrapper(
        child: AsyncValueWidget<List<MeasurementCategory>>(
          value: ref.watch(measurementProvider),
          loggerName: 'MeasurementCategorySortScreen',
          data: (categories) => _SortableList(categories.where((c) => c.parentId == null).toList()),
        ),
      ),
    );
  }
}

class _SortableList extends ConsumerWidget {
  final List<MeasurementCategory> _categories;
  const _SortableList(this._categories);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(measurementProvider.notifier);
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return ListTile(
          key: ValueKey(category.id),
          title: Text(category.name),
          subtitle: Text(category.unit),
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        );
      },
      onReorderItem: notifier.setCategoryOrder,
    );
  }
}
