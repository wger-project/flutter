/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

/*
 * Riverpod notifier for measurement entries backed by Drift.
 */

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/core/network/auth_credentials_storage.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';

import 'measurement_repository.dart';

part 'measurement_notifier.g.dart';

/// All categories with the entries from [since] on, null covering the full
/// history.
///
/// The bound is applied in the query rather than in the chart, so showing
/// three months does not read years of entries into memory. Kept apart from
/// [measurementProvider], which stays unbounded for the consumers that need
/// the latest entry regardless of its age (the dashboard card).
@riverpod
Stream<List<MeasurementCategory>> measurementCategoriesSince(Ref ref, DateTime? since) {
  return ref.read(measurementRepositoryProvider).watchAll(entriesSince: since);
}

/// One category with its children and the entries from [since] on, null while
/// it does not exist (or no longer does).
@riverpod
Stream<MeasurementCategory?> measurementCategorySince(Ref ref, String id, DateTime? since) {
  return ref
      .read(measurementRepositoryProvider)
      .watchLocalDriftCategoryById(id, entriesSince: since);
}

@riverpod
final class MeasurementNotifier extends _$MeasurementNotifier {
  final _logger = Logger('MeasurementNotifier');

  late MeasurementRepository _repo;

  @override
  Stream<List<MeasurementCategory>> build() {
    _repo = ref.read(measurementRepositoryProvider);
    _logger.finer('Building stream');

    return _repo.watchAll();
  }

  Stream<MeasurementCategory?> watchCategoryById(String id) {
    _logger.finer('Watching local measurement category $id');
    return _repo.watchLocalDriftCategoryById(id);
  }

  Future<MeasurementCategory?> getCategoryById(String id) async {
    // Data already loaded
    final categories = state.asData?.value;
    if (categories != null) {
      return categories.firstWhereOrNull((c) => c.id == id);
    }

    // Read from DB
    return _repo.watchLocalDriftCategoryById(id).first;
  }

  Future<void> deleteEntry(String id) async {
    await _repo.deleteLocalDrift(id);
  }

  Future<void> updateEntry(MeasurementEntry entry) async {
    await _repo.updateLocalDrift(entry);
  }

  Future<void> addEntry(MeasurementEntry entry) async {
    await _repo.addLocalDrift(entry);
  }

  /// Adds one reading of a multi-value group (one entry per component,
  /// persisted atomically).
  Future<void> addGroupEntries(List<MeasurementEntry> entries) async {
    await _repo.addLocalDriftGroupEntries(entries);
  }

  // --- MeasurementCategory operations (delegated to repository) ---
  Future<void> deleteCategory(String id) async {
    await _repo.deleteLocalDriftCategory(id);
  }

  Future<void> updateCategory(MeasurementCategory category) async {
    await _repo.updateLocalDriftCategory(category);
  }

  /// Adds a category, and its components when it is a group.
  ///
  /// A typed category takes the id derived from user and metric type (see
  /// [deterministicCategoryId]) instead of a random one, so that a category
  /// created here and the same one created on another device converge on one
  /// row rather than colliding with the server's uniqueness constraint.
  Future<void> addCategory(MeasurementCategory category) async {
    final userId = await ref.read(authCredentialsStorageProvider).dbOwnerUserId();
    if (userId == null || !category.metricType.hasDeterministicId) {
      await _repo.addLocalDriftCategory(category);
      return;
    }

    final parent = category.copyWith(
      id: category.id ?? deterministicCategoryId(userId, category.metricType),
    );
    await _repo.addLocalDriftCategory(parent);

    // A group is a container, its readings live in one child per component.
    // The server creates them as well, on the same ids, so whichever side
    // gets there first wins and the other is acknowledged as a no-op
    for (final (order, (metricType, name)) in parent.metricType.components.indexed) {
      await _repo.addLocalDriftCategory(
        MeasurementCategory(
          id: deterministicCategoryId(userId, metricType),
          name: name,
          unit: parent.unit,
          metricType: metricType,
          parentId: parent.id,
          order: order,
        ),
      );
    }
  }

  /// Moves the top-level category at [oldIndex] to [newIndex] and renumbers
  /// all top-level categories accordingly.
  ///
  /// Indices refer to the top-level list only (children of multi-value groups
  /// keep their in-group order). The official body weight category is not
  /// part of the list, matching the sort screen it is hidden from.
  Future<void> setCategoryOrder(int oldIndex, int newIndex) async {
    final categories = state.asData?.value;
    if (categories == null) {
      return;
    }

    final reordered = categories
        .where((c) => c.parentId == null && !c.isOfficialBodyWeight)
        .toList();
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    await _repo.reorderCategories([for (final c in reordered) c.id!]);
  }
}
