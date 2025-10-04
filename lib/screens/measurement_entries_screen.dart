/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/measurements/entries.dart';
import 'package:wger/widgets/measurements/forms.dart';

enum MeasurementOptions { edit, delete }

class MeasurementEntriesScreen extends StatelessWidget {
  const MeasurementEntriesScreen();

  static const routeName = '/measurement-entries';

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final categoryId = ModalRoute.of(context)!.settings.arguments as int;
    final category = Provider.of<MeasurementProvider>(context).findCategoryById(categoryId);

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
                    arguments: FormScreenArguments(i18n.edit, MeasurementCategoryForm(category)),
                  );
                  break;

                case MeasurementOptions.delete:
                  showDialog(
                    context: context,
                    builder: (BuildContext contextDialog) {
                      return AlertDialog(
                        content: Text(
                          AppLocalizations.of(contextDialog).confirmDelete(category.name),
                        ),
                        actions: [
                          TextButton(
                            child: Text(MaterialLocalizations.of(contextDialog).cancelButtonLabel),
                            onPressed: () => Navigator.of(contextDialog).pop(),
                          ),
                          TextButton(
                            child: Text(
                              AppLocalizations.of(contextDialog).delete,
                              style: TextStyle(color: Theme.of(contextDialog).colorScheme.error),
                            ),
                            onPressed: () {
                              // Confirmed, delete the workout
                              Provider.of<MeasurementProvider>(
                                contextDialog,
                                listen: false,
                              ).deleteCategory(category.id!);

                              // Close the popup
                              Navigator.of(contextDialog).pop();

                              // and inform the user
                              ScaffoldMessenger.of(contextDialog).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(contextDialog).successfullyDeleted,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MeasurementOptions>(
                  value: MeasurementOptions.edit,
                  child: Text(i18n.edit),
                ),
                PopupMenuItem<MeasurementOptions>(
                  value: MeasurementOptions.delete,
                  child: Text(i18n.delete),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: category.externallySynced
          ? FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(i18n.newEntry, MeasurementEntryForm(categoryId)),
                );
              },
            )
          : null,
      body: SingleChildScrollView(
        child: Consumer<MeasurementProvider>(
          builder: (context, provider, child) => EntriesList(category),
        ),
      ),
    );
  }
}
