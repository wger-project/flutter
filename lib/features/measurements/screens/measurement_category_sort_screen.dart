import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/core/widgets/async_value_widget.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

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
          data: (categories) => _SortableList(categories),
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
      // physics: const NeverScrollableScrollPhysics(),
      // shrinkWrap: true,
      // buildDefaultDragHandles: false,
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return ListTile(
          key: ValueKey(category.id),
          title: Text(category.name),
          subtitle: Text(category.unit),
          trailing: ReorderableDelayedDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        );
      },
      onReorderItem: (oldIndex, newIndex) => notifier.setCategoryOrder(oldIndex, newIndex),
    );
  }
}
