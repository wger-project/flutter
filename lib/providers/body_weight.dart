/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/body_weight/weight_entry.dart';

import 'body_weight_repository.dart';

part 'body_weight.g.dart';

@riverpod
final class WeightEntryNotifier extends _$WeightEntryNotifier {
  final _logger = Logger('WeightEntryNotifier');
  late final BodyWeightRepository _repo;

  @override
  // BodyWeightState build() {
  Stream<List<WeightEntry>> build([BodyWeightRepository? repository]) {
    _repo = repository ?? ref.read(bodyWeightRepositoryProvider);
    _logger.finer('Building WeightEntryNotifier');

    // final state = BodyWeightState();
    // repo.watchAllDrift(database).listen((entries) {
    //   state.setItems(entries);
    // });
    // return state;

    return _repo.watchAllDrift();
  }

  Future<void> deleteEntry(String id) async {
    await _repo.deleteLocalDrift(id);
  }

  Future<void> updateEntry(WeightEntry entry) async {
    await _repo.updateLocalDrift(entry);
  }

  Future<void> addEntry(WeightEntry entry) async {
    await _repo.addLocalDrift(entry);
  }
}
