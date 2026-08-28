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
import 'package:wger/core/form_screen.dart';
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/core/widgets/confirm_delete_dialog.dart';
import 'package:wger/core/widgets/error.dart';
import 'package:wger/core/widgets/object_gone_redirect.dart';
import 'package:wger/core/widgets/progress_indicator.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/chart_range_setting.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/widgets/entries.dart';
import 'package:wger/features/measurements/widgets/forms/category.dart';
import 'package:wger/features/measurements/widgets/forms/entry.dart';
import 'package:wger/features/measurements/widgets/forms/group_entry.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

enum _MeasurementOptions {
  edit,
  delete,
}

class MeasurementEntriesScreen extends ConsumerStatefulWidget {
  const MeasurementEntriesScreen();

  static const routeName = '/measurement-entries';

  @override
  ConsumerState<MeasurementEntriesScreen> createState() => _MeasurementEntriesScreenState();
}

class _MeasurementEntriesScreenState extends ConsumerState<MeasurementEntriesScreen> {
  late final String _categoryId;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialise once, the route argument doesn't change for the lifetime of
    // this screen
    if (!_initialised) {
      _categoryId = ModalRoute.of(context)!.settings.arguments as String;
      _initialised = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryValue = ref.watch(measurementCategoryProvider(_categoryId));

    // Category was deleted (locally or via PowerSync from another device).
    // Leave this now-stale screen.
    if (categoryValue.hasValue && categoryValue.value == null) {
      return objectGoneRedirect(context);
    }

    final category = categoryValue.value;

    // The scaffold is built whether or not there is data: a bare indicator in
    // its place is a screen without a background, i.e. a black flash
    return Scaffold(
      appBar: AppBar(
        title: Text(category?.displayName(context) ?? ''),
        actions: [
          if (category != null)
            PopupMenuButton<_MeasurementOptions>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case _MeasurementOptions.edit:
                    Navigator.pushNamed(
                      context,
                      FormScreen.routeName,
                      arguments: FormScreenArguments(
                        AppLocalizations.of(context).edit,
                        MeasurementCategoryForm(category),
                        hasListView: true,
                      ),
                    );
                    break;

                  case _MeasurementOptions.delete:
                    showConfirmDeleteDialog(
                      context,
                      itemName: category.displayName(context),
                      onConfirm: () =>
                          ref.read(measurementProvider.notifier).deleteCategory(category.id!),
                      // Exit the detail screen once the category is gone.
                      onDeleted: () => Navigator.of(context).pop(),
                    );
                    break;
                }
              },
              itemBuilder: (context) {
                return [
                  if (category.isEditable)
                    PopupMenuItem<_MeasurementOptions>(
                      value: _MeasurementOptions.edit,
                      child: Text(AppLocalizations.of(context).edit),
                    ),
                  PopupMenuItem<_MeasurementOptions>(
                    value: _MeasurementOptions.delete,
                    child: Text(AppLocalizations.of(context).delete),
                  ),
                ];
              },
            ),
        ],
      ),
      // The entries of a calculated category are maintained by the server
      floatingActionButton: category == null || category.isCalculated
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context).newEntry,
                    // A group holds no entries itself: one reading is a value
                    // per component, entered in one go
                    category.hasChildren
                        ? GroupMeasurementEntryForm(category)
                        : MeasurementEntryForm(_categoryId),
                  ),
                );
              },
            ),
      body: WidescreenWrapper(
        child: switch ((category, categoryValue)) {
          (final MeasurementCategory category, _) => SingleChildScrollView(
            child: EntriesList(
              category,
              // Shared with the overview: the range picked there follows the
              // user in here, and a pick here follows them back out
              range: ref.watch(chartRangeSettingProvider),
              onRangeChanged: (range) => ref.read(chartRangeSettingProvider.notifier).set(range),
            ),
          ),
          (_, AsyncError(:final error)) => StreamErrorIndicator(error.toString()),
          _ => const BoxedProgressIndicator(),
        },
      ),
    );
  }
}
