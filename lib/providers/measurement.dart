/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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
import 'package:http/http.dart' as http;
import 'package:wger/exceptions/no_result_exception.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

class MeasurementProvider with ChangeNotifier {
  static const _categoryUrl = 'measurement-category';
  static const _entryUrl = 'measurement';

  final WgerBaseProvider baseProvider;

  List<MeasurementCategory> _categories = [];

  MeasurementProvider(this.baseProvider);
  //: super(auth, client);

  List<MeasurementCategory> get categories => _categories;

  /// Clears all lists
  void clear() {
    _categories = [];
  }

  /// Finds the category by ID
  MeasurementCategory findCategoryById(int id) {
    return _categories.firstWhere(
      (category) => category.id == id,
      orElse: () => throw NoResultException(),
    );
  }

  /// Fetches and sets the categories from the server (no entries)
  Future<void> fetchAndSetCategories() async {
    // Process the response
    final requestUrl = baseProvider.makeUrl(_categoryUrl);
    final data = await baseProvider.fetch(requestUrl);
    final List<MeasurementCategory> loadedEntries = [];
    for (final entry in data['results']) {
      loadedEntries.add(MeasurementCategory.fromJson(entry));
    }

    _categories = loadedEntries;
    notifyListeners();
  }

  /// Fetches and sets the measurement entries for the given category
  Future<void> fetchAndSetCategoryEntries(int id) async {
    final category = findCategoryById(id);

    // Process the response
    final requestUrl = baseProvider.makeUrl(_entryUrl, query: {'category': category.id.toString()});
    final data = await baseProvider.fetch(requestUrl);
    final List<MeasurementEntry> loadedEntries = [];
    for (final entry in data['results']) {
      loadedEntries.add(MeasurementEntry.fromJson(entry));
    }
    category.entries = loadedEntries;
    notifyListeners();
  }
}
