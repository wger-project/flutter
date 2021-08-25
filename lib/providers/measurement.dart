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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/exceptions/no_result_exception.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/helpers.dart';

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
    final categoryIndex = _categories.indexOf(category);

    // Process the response
    final requestUrl = baseProvider.makeUrl(_entryUrl, query: {'category': category.id.toString()});
    final data = await baseProvider.fetch(requestUrl);
    final List<MeasurementEntry> loadedEntries = [];
    for (final entry in data['results']) {
      loadedEntries.add(MeasurementEntry.fromJson(entry));
    }
    MeasurementCategory editedCategory = category.copyWith(entries: loadedEntries);
    _categories.removeAt(categoryIndex);
    _categories.insert(categoryIndex, editedCategory);
    notifyListeners();
  }

  /// Adds a measurement category to the remote db
  Future<void> addCategory(MeasurementCategory category) async {
    Uri postUri = baseProvider.makeUrl(_categoryUrl);
    final Map<String, dynamic> newCategoryMap = await baseProvider.post(category.toJson(), postUri);
    final MeasurementCategory newCategory = MeasurementCategory.fromJson(newCategoryMap);
    _categories.add(newCategory);
    _categories.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  /// Deletes a measurement category from the remote db
  Future<void> deleteCategory(int id) async {
    MeasurementCategory category = _categories.firstWhere((element) => element.id == id,
        orElse: () => throw NoSuchEntryException());
    int categoryIndex = _categories.indexOf(category);
    _categories.remove(category);
    notifyListeners();

    final http.Response response = await baseProvider.deleteRequest(_categoryUrl, id);

    if (response.statusCode >= 400) {
      _categories.insert(categoryIndex, category);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
  }

  /// Adds a measurement entry to the remote db
  Future<void> addEntry(MeasurementEntry entry) async {
    Uri postUri = baseProvider.makeUrl(_entryUrl);

    final Map<String, dynamic> newEntryMap = await baseProvider.post(entry.toJson(), postUri);
    final MeasurementEntry newEntry = MeasurementEntry.fromJson(newEntryMap);

    _categories.firstWhere((categories) {
      if (categories.id == newEntry.category) {
        categories.entries.add(newEntry);
        categories.entries.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
        return true;
      }
      return false;
    }, orElse: () => throw NoSuchEntryException());
  }

  /// Deletes a measurement entry from the remote db
  Future<void> deleteEntry(int id, int categoryId) async {
    final int categoryIndex = _categories.indexWhere((category) => category.id == categoryId);
    if (categoryIndex == -1) throw NoSuchEntryException();

    final MeasurementEntry entry = _categories[categoryIndex]
        .entries
        .firstWhere((entry) => entry.id == id, orElse: () => throw NoSuchEntryException());
    final int entryIndex = _categories[categoryIndex].entries.indexOf(entry);

    _categories[categoryIndex].entries.removeAt(entryIndex);
    notifyListeners();

    final http.Response response = await baseProvider.deleteRequest(_entryUrl, id);

    if (response.statusCode >= 400) {
      _categories[categoryIndex].entries.insert(entryIndex, entry);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
  }
}
