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
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

class MeasurementProvider extends WgerBaseProvider with ChangeNotifier {
  static const _categoryUrl = 'measurement-category';
  static const _entryUrl = 'measurement';

  List<MeasurementCategory> _categories = [];

  MeasurementProvider(AuthProvider auth, [http.Client? client]) : super(auth, client);

  List<MeasurementCategory> get categories {
    return [..._categories];
  }

  /// Clears all lists
  clear() {
    _categories = [];
  }

  /// Finds the category by ID
  MeasurementCategory findCategoryById(int id) {
    return _categories.firstWhere((category) => category.id == id);
  }

  /// Fetches and sets the categories from the server (no entries)
  Future<List<MeasurementCategory>> fetchAndSetCategories() async {
    // Process the response
    final data = await fetch(makeUrl(_categoryUrl));
    final List<MeasurementCategory> loadedEntries = [];
    for (final entry in data['results']) {
      loadedEntries.add(MeasurementCategory.fromJson(entry));
    }

    _categories = loadedEntries;
    notifyListeners();
    return _categories;
  }

  /// Fetches and sets the measurement entries for the given category
  Future<MeasurementCategory> fetchAndSetCategoryEntries(int id) async {
    final category = findCategoryById(id);

    // Process the response
    final data = await fetch(makeUrl(_entryUrl, query: {'category': category.id.toString()}));
    final List<MeasurementEntry> loadedEntries = [];
    for (final entry in data['results']) {
      loadedEntries.add(MeasurementEntry.fromJson(entry));
    }
    category.entries = loadedEntries;
    notifyListeners();

    return category;
  }
}
