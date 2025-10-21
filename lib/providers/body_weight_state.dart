import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight_repository.dart';

class BodyWeightState extends StateNotifier<List<WeightEntry>> {
  final _logger = Logger('BodyWeightState');
  final BodyWeightRepository repository;

  BodyWeightState(this.repository) : super([]);

  List<WeightEntry> get items => [...state];

  WeightEntry? getNewestEntry() => state.isNotEmpty ? state.first : null;

  WeightEntry? findById(int id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } on StateError {
      return null;
    }
  }

  WeightEntry? findByDate(DateTime date) {
    try {
      return state.firstWhere((e) => e.date == date);
    } on StateError {
      return null;
    }
  }

  void clear() => state = [];

  Future<void> fetchAndSetEntries() async {
    _logger.info('State: fetching entries');
    final entries = await repository.fetchAll();
    // Ensure sorted by date desc
    entries.sort((a, b) => b.date.compareTo(a.date));
    state = entries;
  }

  Future<WeightEntry> addEntry(WeightEntry entry) async {
    final created = await repository.create(entry);
    final newList = [...state, created];
    newList.sort((a, b) => b.date.compareTo(a.date));
    state = newList;
    return created;
  }

  Future<void> editEntry(WeightEntry entry) async {
    await repository.update(entry);
    // Update local copy if present
    final idx = state.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      final newList = [...state];
      newList[idx] = entry;
      newList.sort((a, b) => b.date.compareTo(a.date));
      state = newList;
    }
  }

  Future<void> deleteEntry(int id) async {
    final idx = state.indexWhere((e) => e.id == id);
    if (idx < 0) {
      return;
    }

    final removed = state[idx];
    final newList = [...state]..removeAt(idx);
    state = newList;

    try {
      final response = await repository.delete(id);
      if (response.statusCode >= 400) {
        // Revert
        state = [...state]..insert(idx, removed);
        throw Exception('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      // Revert on any error and rethrow
      state = [...state]..insert(idx, removed);
      rethrow;
    }
  }
}
