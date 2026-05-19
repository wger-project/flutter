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
import 'package:logging/logging.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/core/exceptions/no_such_entry_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/models/measurements/measurement_group.dart';
import 'package:wger/models/measurements/mock_measurement_data.dart';
import 'package:wger/providers/base_provider.dart';

class MeasurementProvider with ChangeNotifier {
  final _logger = Logger('MeasurementProvider');

  static const _categoryUrl = 'measurement-category';
  static const _entryUrl = 'measurement';
  static const _groupUrl = 'measurement-group';
  final WgerBaseProvider baseProvider;

  List<MeasurementCategory> _categories = [];
  List<MeasurementGroup> _groups = [];

  MeasurementProvider(this.baseProvider) {
    // TODO: REMOVE before merge — loads mock data for UI development
    _groups = MeasurementMockData.dummyGroups;
    _categories = MeasurementMockData.dummyCategories;
  }

  List<MeasurementCategory> get categories => _categories;
  List<MeasurementGroup> get groups => _groups;

  /// Clears all lists
  void clear() {
    _categories = [];
    _groups = [];
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
    final requestUrl = baseProvider.makeUrl(_categoryUrl, query: {'limit': API_MAX_PAGE_SIZE});
    final data = await baseProvider.fetchPaginated(requestUrl);
    final List<MeasurementCategory> loadedEntries = [];
    for (final entry in data) {
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
    final requestUrl = baseProvider.makeUrl(
      _entryUrl,
      query: {'category': category.id.toString(), 'limit': API_MAX_PAGE_SIZE},
    );
    final data = await baseProvider.fetchPaginated(requestUrl);
    final List<MeasurementEntry> loadedEntries = [];
    for (final entry in data) {
      loadedEntries.add(MeasurementEntry.fromJson(entry));
    }
    final MeasurementCategory editedCategory = category.copyWith(entries: loadedEntries);
    _categories.removeAt(categoryIndex);
    _categories.insert(categoryIndex, editedCategory);
    notifyListeners();
  }

  /// Fetches and sets the measurement categories and their entries
  Future<void> fetchAndSetAllCategoriesAndEntries() async {
    _logger.info('Fetching all measurement categories and entries');

    await fetchAndSetGroups();
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
  Future<void> editCategory(
    int id,
    String? newName,
    String? newUnit,
    int? newGroupId,
    String? newFormula, {
    bool clearGroup = false,
    bool clearFormula = false,
  }) async {
    final MeasurementCategory oldCategory = findCategoryById(id);
    final int categoryIndex = _categories.indexOf(oldCategory);
    final MeasurementCategory tempNewCategory = oldCategory.copyWith(
      name: newName,
      unit: newUnit,
      groupId: newGroupId,
      clearGroup: clearGroup,
      formula: newFormula,
    );
    final Map<String, dynamic> response = await baseProvider.patch(
      tempNewCategory.toJson(),
      baseProvider.makeUrl(_categoryUrl, id: id),
    );
    final MeasurementCategory newCategory = MeasurementCategory.fromJson(
      response,
    ).copyWith(entries: oldCategory.entries);
    _categories.removeAt(categoryIndex);
    _categories.insert(categoryIndex, newCategory);
    notifyListeners();
  }

  // --- Measurement Groups ---

  /// Finds a group by ID
  MeasurementGroup findGroupById(int id) {
    return _groups.firstWhere(
      (group) => group.id == id,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  /// Fetches and sets all measurement groups from the server.
  Future<void> fetchAndSetGroups() async {
    final requestUrl = baseProvider.makeUrl(_groupUrl, query: {'limit': API_MAX_PAGE_SIZE});
    final data = await baseProvider.fetchPaginated(requestUrl);
    _groups = data.map((e) => MeasurementGroup.fromJson(e)).toList();
    notifyListeners();
  }

  /// Adds a measurement group.
  Future<void> addGroup(MeasurementGroup group) async {
    final Uri postUri = baseProvider.makeUrl(_groupUrl);
    final Map<String, dynamic> newGroupMap = await baseProvider.post(group.toJson(), postUri);
    final MeasurementGroup newGroup = MeasurementGroup.fromJson(newGroupMap);
    _groups.add(newGroup);
    _groups.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  /// Edits a measurement group name/description.
  Future<void> editGroup(int id, String? newName, String? newDescription) async {
    final MeasurementGroup oldGroup = findGroupById(id);
    final int groupIndex = _groups.indexOf(oldGroup);
    final MeasurementGroup tempNew = MeasurementGroup(
      id: oldGroup.id,
      uuid: oldGroup.uuid,
      name: newName ?? oldGroup.name,
      description: newDescription ?? oldGroup.description,
    );
    final Map<String, dynamic> response = await baseProvider.patch(
      tempNew.toJson(),
      baseProvider.makeUrl(_groupUrl, id: id),
    );
    final MeasurementGroup newGroup = MeasurementGroup.fromJson(response);
    _groups.removeAt(groupIndex);
    _groups.insert(groupIndex, newGroup);
    notifyListeners();
  }

  /// Deletes a measurement group.
  Future<void> deleteGroup(int id) async {
    final MeasurementGroup group = findGroupById(id);
    final int groupIndex = _groups.indexOf(group);
    _groups.remove(group);
    notifyListeners();
    try {
      await baseProvider.deleteRequest(_groupUrl, id);
    } on WgerHttpException {
      _groups.insert(groupIndex, group);
      notifyListeners();
      rethrow;
    }
  }

  // --- Measurement Entries ---

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

    final Map<String, dynamic> response = await baseProvider.patch(
      tempNewEntry.toJson(),
      baseProvider.makeUrl(_entryUrl, id: id),
    );

    final MeasurementEntry newEntry = MeasurementEntry.fromJson(response);
    category.entries.removeAt(entryIndex);
    category.entries.insert(entryIndex, newEntry);
    notifyListeners();
  }
}
