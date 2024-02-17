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
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/base_provider.dart';

class BodyWeightProvider with ChangeNotifier {
  final WgerBaseProvider baseProvider;

  static const BODY_WEIGHT_URL = 'weightentry';

  List<WeightEntry> _entries = [];

  BodyWeightProvider(this.baseProvider);

  List<WeightEntry> get items {
    return [..._entries];
  }

  set items(List<WeightEntry> entries) {
    _entries = entries;
  }

  /// Clears all lists
  void clear() {
    _entries = [];
  }

  /// Returns the latest (newest) weight entry or null if there are none
  WeightEntry? getNewestEntry() {
    return _entries.isNotEmpty ? _entries.first : null;
  }

  WeightEntry findById(int id) {
    return _entries.firstWhere((plan) => plan.id == id);
  }

  WeightEntry? findByDate(DateTime date) {
    try {
      return _entries.firstWhere((plan) => plan.date == date);
    } on StateError {
      return null;
    }
  }

  Future<List<WeightEntry>> fetchAndSetEntries() async {
    // Process the response
    final data = await baseProvider.fetchPaginated(baseProvider.makeUrl(
      BODY_WEIGHT_URL,
      query: {'ordering': '-date', 'limit': '100'},
    ));
    _entries = [];
    for (final entry in data) {
      _entries.add(WeightEntry.fromJson(entry));
    }

    notifyListeners();
    return _entries;
  }

  Future<WeightEntry> addEntry(WeightEntry entry) async {
    // Create entry and return it
    final data = await baseProvider.post(entry.toJson(), baseProvider.makeUrl(BODY_WEIGHT_URL));
    final WeightEntry weightEntry = WeightEntry.fromJson(data);
    _entries.add(weightEntry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    return weightEntry;
  }

  /// Update an existing weight entry
  Future<void> editEntry(WeightEntry entry) async {
    await baseProvider.patch(
      entry.toJson(),
      baseProvider.makeUrl(BODY_WEIGHT_URL, id: entry.id),
    );
    notifyListeners();
  }

  Future<void> deleteEntry(int id) async {
    // Send the request and remove the entry from the list...
    final existingEntryIndex = _entries.indexWhere((element) => element.id == id);
    final existingWeightEntry = _entries[existingEntryIndex];
    _entries.removeAt(existingEntryIndex);
    notifyListeners();

    final response = await baseProvider.deleteRequest(BODY_WEIGHT_URL, id);

    // ...but that didn't work, put it back again
    if (response.statusCode >= 400) {
      _entries.insert(existingEntryIndex, existingWeightEntry);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
  }
}
