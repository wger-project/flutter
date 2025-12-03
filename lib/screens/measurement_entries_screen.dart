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
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/measurements/entries.dart';
import 'package:wger/widgets/measurements/forms.dart';
import '../models/measurements/measurement_category.dart';

enum MeasurementOptions {
  edit,
  delete,
}

class MeasurementEntriesScreen extends StatelessWidget {
  const MeasurementEntriesScreen();

  static const routeName = '/measurement-entries';

  @override
  Widget build(BuildContext context) {
    final categoryId = ModalRoute.of(context)!.settings.arguments as int;
    final provider = Provider.of<MeasurementProvider>(context);
    MeasurementCategory? category;

    try {
      category = provider.findCategoryById(categoryId);
    } catch (e) {
      // Category deleted → prevent red screen
      Future.microtask(() {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox(); // Return empty widget until pop happens
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
                  showDialog(
                    context: context,
                    builder: (BuildContext contextDialog) {
                      return AlertDialog(
                        content: Text(
                          AppLocalizations.of(context).confirmDelete(category!.name),
                        ),
                        actions: [
                          TextButton(
                            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                            onPressed: () => Navigator.of(contextDialog).pop(),
                          ),
                          TextButton(
                            child: Text(
                              AppLocalizations.of(context).delete,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            onPressed: () {
                              // Confirmed, delete the workout
                              Provider.of<MeasurementProvider>(
                                context,
                                listen: false,
                              ).deleteCategory(category!.id!);
                              // Close the popup
                              Navigator.of(contextDialog).pop();

                              Navigator.of(context).pop(); // Exit detail screen

                              // and inform the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context).successfullyDeleted,
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
              MeasurementEntryForm(categoryId),
            ),
          );
        },
      ),
      body: WidescreenWrapper(
        child: SingleChildScrollView(
          child: Consumer<MeasurementProvider>(
            builder: (context, provider, child) => EntriesList(category!),
          ),
        ),
      ),
    );
  }
}
