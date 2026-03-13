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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/providers/measurement_notifier.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/helpers.dart';

import 'forms.dart';

class EntriesList extends ConsumerWidget {
  final MeasurementCategory _category;

  const EntriesList(this._category);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = legacy_provider.Provider.of<NutritionPlansProvider>(context, listen: false).items;
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final provider = ref.read(measurementProvider.notifier);

    final entriesAll = _category.entries
        .map((e) => MeasurementChartEntry(e.value, e.date))
        .toList();
    final entries7dAvg = moving7dAverage(entriesAll);

    return Column(
      children: [
        ...getOverviewWidgetsSeries(
          _category.name,
          entriesAll,
          entries7dAvg,
          plans,
          _category.unit,
          context,
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: _category.entries.length,
            itemBuilder: (context, index) {
              final currentEntry = _category.entries[index];

              return Card(
                child: ListTile(
                  title: Text('${numberFormat.format(currentEntry.value)} ${_category.unit}'),
                  subtitle: Text(
                    DateFormat.yMd(
                      Localizations.localeOf(context).languageCode,
                    ).format(currentEntry.date),
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context).edit),
                          onTap: () => Navigator.pushNamed(
                            context,
                            FormScreen.routeName,
                            arguments: FormScreenArguments(
                              AppLocalizations.of(context).edit,
                              MeasurementEntryForm(
                                _category.uuid,
                                currentEntry,
                              ),
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          child: Text(AppLocalizations.of(context).delete),
                          onTap: () async {
                            // Delete entry from DB
                            await provider.deleteEntry(currentEntry.uuid);

                            // and inform the user
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context).successfullyDeleted,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ];
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
