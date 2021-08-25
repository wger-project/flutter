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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/providers/measurement.dart';

class EntriesList extends StatelessWidget {
  late MeasurementCategory _category;

  Future<void> _loadEntries(BuildContext context) async {
    final provider = Provider.of<MeasurementProvider>(context, listen: false);
    final int categoryId = ModalRoute.of(context)!.settings.arguments as int;
    await provider.fetchAndSetCategoryEntries(categoryId);
    _category = provider.findCategoryById(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadEntries(context),
      builder: (ctx, authResultSnapshot) =>
          authResultSnapshot.connectionState == ConnectionState.waiting
              ? Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _category.entries.length,
                  itemBuilder: (context, index) {
                    final currentEntry = _category.entries[index];
                    return Card(
                      child: ListTile(
                        title: Text(currentEntry.value.toString()),
                        subtitle: Text(
                          DateFormat.yMd(Localizations.localeOf(context).languageCode)
                              .format(currentEntry.date),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
