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
 * AsyncNotifier for on-demand ingredient lookups (one-shot reads).
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/nutrition/ingredient.dart';

import 'ingredient_repository.dart';

part 'ingredients.g.dart';

@riverpod
final class IngredientNotifier extends _$IngredientNotifier {
  final _logger = Logger('IngredientProvider');

  late IngredientRepository _repo;

  // Cache for fetched ingredients keyed by id. Stores null when DB had no row.
  final Map<int, Ingredient?> _cache = {};

  // Deduplicate simultaneous fetches for the same id.
  final Map<int, Future<Ingredient?>> _inflight = {};

  @override
  FutureOr<void> build() async {
    _repo = ref.read(ingredientRepositoryProvider);
    return null;
  }

  /// Fetch ingredient by [id] from the DB (one-shot) and update state.
  /// If the id is present in the in-memory cache, the cached value is
  /// returned immediately without a DB read. Simultaneous calls for the
  /// same id are deduplicated. The provider `state` is used only as a
  /// status signal (loading/done/error) and does not carry the Ingredient
  /// itself — consumers should read the data from the notifier's cache.
  Future<Ingredient?> fetch(int id) async {
    _logger.finer('Fetching ingredient id: $id');

    // Return cached result if present (could be null meaning 'not found').
    if (_cache.containsKey(id)) {
      final cached = _cache[id];
      if (ref.mounted) {
        state = const AsyncData(null);
      }
      return cached;
    }

    // If a fetch for this id is already ongoing, await it.
    if (_inflight.containsKey(id)) {
      _logger.finer('Awaiting in-flight fetch for id: $id');
      final res = await _inflight[id];
      if (ref.mounted) {
        state = const AsyncData(null);
      }
      return res;
    }

    // Start a new DB read and store the future in _inflight to dedupe.
    final future = _doFetch(id);
    _inflight[id] = future;
    try {
      final item = await future;
      return item;
    } finally {
      // ensure inflight entry removed regardless of success/error
      _inflight.remove(id);
    }
  }

  Future<Ingredient?> _doFetch(int id) async {
    if (ref.mounted) {
      state = const AsyncLoading();
    }
    final item = await _repo.getById(id);
    _cache[id] = item; // store null as 'not found' as well
    if (!ref.mounted) {
      return item;
    }
    state = const AsyncData(null);
    return item;
  }
}
