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

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

import 'measurement_repository.dart';

part 'measurement_notifier.g.dart';

@riverpod
final class MeasurementNotifier extends _$MeasurementNotifier {
  final _logger = Logger('MeasurementNotifier');
  late final MeasurementRepository _repo;
  @override
  Stream<List<MeasurementCategory>> build() {
    _repo = ref.read(measurementRepositoryProvider);
    _logger.finer('Building MeasurementEntryNotifier (categories stream)');

    // Return the repository stream that emits fully populated categories
    // including their entries.
    return _repo.watchAll();
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

  // --- MeasurementCategory operations (delegated to repository) ---
  Future<void> deleteCategory(String id) async {
    await _repo.deleteLocalDriftCategory(id);
  }

  Future<void> updateCategory(MeasurementCategory category) async {
    await _repo.updateLocalDriftCategory(category);
  }

  Future<void> addCategory(MeasurementCategory category) async {
    await _repo.addLocalDriftCategory(category);
  }
}
