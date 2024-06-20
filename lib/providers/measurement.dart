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
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/base_provider.dart';

class MeasurementProvider with ChangeNotifier {
  static const _categoryUrl = 'measurement-category';
  static const _entryUrl = 'measurement';

  final WgerBaseProvider baseProvider;

  List<MeasurementCategory> _categories = [];

  MeasurementProvider(this.baseProvider);

  List<MeasurementCategory> get categories => _categories;

  /// Clears all lists
  void clear() {
    _categories = [];
  }

  /// Finds the category by ID
  MeasurementCategory findCategoryById(int id) {
    return _categories.firstWhere(
      (category) => category.id == id,
      orElse: () => throw const NoSuchEntryException(),
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
    final MeasurementCategory editedCategory = category.copyWith(entries: loadedEntries);
    _categories.removeAt(categoryIndex);
    _categories.insert(categoryIndex, editedCategory);
    notifyListeners();
  }

  /// Fetches and sets the measurement categories and their entries
  Future<void> fetchAndSetAllCategoriesAndEntries() async {
    await fetchAndSetCategories();
    await Future.wait(_categories.map((e) => fetchAndSetCategoryEntries(e.id!)).toList());
  }

  /// Adds a measurement category
  Future<void> addCategory(MeasurementCategory category) async {
    final Uri postUri = baseProvider.makeUrl(_categoryUrl);

    final Map<String, dynamic> newCategoryMap = await baseProvider.post(category.toJson(), postUri);
    final MeasurementCategory newCategory = MeasurementCategory.fromJson(newCategoryMap);
    _categories.add(newCategory);
    _categories.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  /// Deletes a measurement category
  Future<void> deleteCategory(int id) async {
    final MeasurementCategory category = findCategoryById(id);
    final int categoryIndex = _categories.indexOf(category);
    _categories.remove(category);
    notifyListeners();

    try {
      await baseProvider.deleteRequest(_categoryUrl, id);
    } on WgerHttpException {
      _categories.insert(categoryIndex, category);
      notifyListeners();
      rethrow;
    }
  }

  /// Edits a measurement category
  /// Currently there isn't any fallback if the call to the api is unsuccessful, as WgerBaseProvider.patch only returns the response body and not the whole response
  Future<void> editCategory(int id, String? newName, String? newUnit) async {
    final MeasurementCategory oldCategory = findCategoryById(id);
    final int categoryIndex = _categories.indexOf(oldCategory);
    final MeasurementCategory tempNewCategory = oldCategory.copyWith(name: newName, unit: newUnit);

    final Map<String, dynamic> response = await baseProvider.patch(
      tempNewCategory.toJson(),
      baseProvider.makeUrl(_categoryUrl, id: id),
    );
    final MeasurementCategory newCategory =
        MeasurementCategory.fromJson(response).copyWith(entries: oldCategory.entries);
    _categories.removeAt(categoryIndex);
    _categories.insert(categoryIndex, newCategory);
    notifyListeners();
  }

  /// Adds a measurement entry
  Future<void> addEntry(MeasurementEntry entry) async {
    final Uri postUri = baseProvider.makeUrl(_entryUrl);

    final Map<String, dynamic> newEntryMap = await baseProvider.post(entry.toJson(), postUri);
    final MeasurementEntry newEntry = MeasurementEntry.fromJson(newEntryMap);

    final MeasurementCategory category = findCategoryById(newEntry.category);

    category.entries.add(newEntry);
    category.entries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  /// Deletes a measurement entry
  Future<void> deleteEntry(int id, int categoryId) async {
    final MeasurementCategory category = findCategoryById(categoryId);

    final MeasurementEntry entry = category.findEntryById(id);
    final int entryIndex = category.entries.indexOf(entry);

    category.entries.removeAt(entryIndex);
    notifyListeners();

    try {
      await baseProvider.deleteRequest(_entryUrl, id);
    } on WgerHttpException {
      category.entries.insert(entryIndex, entry);
      notifyListeners();
      rethrow;
    }
  }

  /// Edits a measurement entry
  /// Currently there isn't any fallback if the call to the api is unsuccessful, as
  /// WgerBaseProvider.patch only returns the response body and not the whole response
  Future<void> editEntry(
    int id,
    int categoryId,
    num? newValue,
    String? newNotes,
    DateTime? newDate,
  ) async {
    final MeasurementCategory category = findCategoryById(categoryId);
    final MeasurementEntry oldEntry = category.findEntryById(id);
    final int entryIndex = category.entries.indexOf(oldEntry);
    final MeasurementEntry tempNewEntry = oldEntry.copyWith(
      value: newValue,
      notes: newNotes,
      date: newDate,
    );

    final Map<String, dynamic> response =
        await baseProvider.patch(tempNewEntry.toJson(), baseProvider.makeUrl(_entryUrl, id: id));

    final MeasurementEntry newEntry = MeasurementEntry.fromJson(response);
    category.entries.removeAt(entryIndex);
    category.entries.insert(entryIndex, newEntry);
    notifyListeners();
  }
}
