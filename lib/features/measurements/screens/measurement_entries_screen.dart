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
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/widgets/chart_range_selector.dart';
import 'package:wger/features/measurements/widgets/entries.dart';
import 'package:wger/features/measurements/widgets/forms.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

enum MeasurementOptions {
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

  /// Owned here rather than in the list below, because it bounds the query
  /// that reads the entries, not only the span the chart draws
  ChartRange _range = ChartRange.last3Months;

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
    final categoryValue = ref.watch(
      measurementCategorySinceProvider(_categoryId, _range.readCutoff),
    );

    return categoryValue.when(
      loading: () => const BoxedProgressIndicator(),
      error: (error, _) => StreamErrorIndicator(error.toString()),
      data: (category) {
        // Category was deleted (locally or via PowerSync from another device).
        // Leave this now-stale screen.
        if (category == null) {
          return objectGoneRedirect(context);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(category.name),
            actions: [
              PopupMenuButton<MeasurementOptions>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case MeasurementOptions.edit:
                      Navigator.pushNamed(
                        context,
                        FormScreen.routeName,
                        arguments: FormScreenArguments(
                          AppLocalizations.of(context).edit,
                          MeasurementCategoryForm(category),
                        ),
                      );
                      break;

                    case MeasurementOptions.delete:
                      showConfirmDeleteDialog(
                        context,
                        itemName: category.name,
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
                    PopupMenuItem<MeasurementOptions>(
                      value: MeasurementOptions.edit,
                      child: Text(AppLocalizations.of(context).edit),
                    ),
                    PopupMenuItem<MeasurementOptions>(
                      value: MeasurementOptions.delete,
                      child: Text(AppLocalizations.of(context).delete),
                    ),
                  ];
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(
                context,
                FormScreen.routeName,
                arguments: FormScreenArguments(
                  AppLocalizations.of(context).newEntry,
                  // A group holds no entries itself: one reading is a value per
                  // component, entered in one go
                  category.isGroup
                      ? GroupMeasurementEntryForm(category)
                      : MeasurementEntryForm(_categoryId),
                ),
              );
            },
          ),
          body: WidescreenWrapper(
            child: SingleChildScrollView(
              child: EntriesList(
                category,
                range: _range,
                onRangeChanged: (range) => setState(() => _range = range),
              ),
            ),
          ),
        );
      },
    );
  }
}
