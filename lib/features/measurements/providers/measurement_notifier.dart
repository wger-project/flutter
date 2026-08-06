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
import 'package:wger/features/measurements/models/measurement_bucket.dart';
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

/// The newest entry of every category, keyed by category id.
///
/// For the rows that show a last known value next to a chart of a shorter
/// range: widening the chart's range to reach the value would materialise
/// every entry in between.
@riverpod
Stream<Map<String, MeasurementEntry>> latestMeasurementEntries(Ref ref) {
  return ref.read(measurementRepositoryProvider).watchLatestEntries();
}

/// The chart points of one category, condensed by SQLite.
///
/// Kept apart from the category streams, which hand over the entries
/// themselves. [level] is what the chart in question needs, see
/// `chartBucketLevel`.
@riverpod
Stream<List<MeasurementBucket>> measurementChartBuckets(
  Ref ref,
  String categoryId,
  DateTime? since,
  MeasurementBucketLevel level,
) {
  return ref
      .read(measurementRepositoryProvider)
      .watchEntryBuckets(categoryId, since: since, level: level);
}

/// The chart points of a group's components, keyed by component id.
///
/// One query for the whole group, and one calendar unit: a component condensed
/// on its own would put the halves of a reading in different buckets.
@riverpod
Stream<Map<String, List<MeasurementBucket>>> measurementGroupBuckets(
  Ref ref,
  String parentId,
  DateTime? since,
  MeasurementBucketLevel level,
) {
  return ref
      .read(measurementRepositoryProvider)
      .watchGroupBuckets(parentId, since: since, level: level);
}

/// How often each value of a category occurred, for the histogram.
@riverpod
Stream<List<MeasurementValueCount>> measurementValueCounts(
  Ref ref,
  String categoryId,
  DateTime? since,
  bool summedPerDay,
) {
  return ref
      .read(measurementRepositoryProvider)
      .watchValueCounts(categoryId, since: since, summedPerDay: summedPerDay);
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

  /// Adds a category, and its components when it is a group. Returns the id it
  /// was created under, null for a free-form one, where the database assigns it.
  ///
  /// A typed category takes the id derived from user and metric type (see
  /// [deterministicCategoryId]) instead of a random one, so that a category
  /// created here and the same one created on another device converge on one
  /// row rather than colliding with the server's uniqueness constraint.
  Future<String?> addCategory(MeasurementCategory category) async {
    final userId = await ref.read(authCredentialsStorageProvider).dbOwnerUserId();
    if (userId == null || !category.metricType.hasDeterministicId) {
      await _repo.addLocalDriftCategory(category);
      return category.id;
    }

    final parent = category.copyWith(
      id: category.id ?? deterministicCategoryId(userId, category.metricType),
    );
    await _repo.addLocalDriftCategory(parent);

    // A group is a container, its readings live in one child per component.
    // The server creates them as well, on the same ids, so whichever side
    // gets there first wins and the other is acknowledged as a no-op
    for (final (order, metricType) in parent.metricType.components.indexed) {
      await _repo.addLocalDriftCategory(
        MeasurementCategory(
          id: deterministicCategoryId(userId, metricType),
          name: metricType.canonicalName,
          unit: metricType.defaultUnit,
          metricType: metricType,
          parentId: parent.id,
          order: order,
        ),
      );
    }
    return parent.id;
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
