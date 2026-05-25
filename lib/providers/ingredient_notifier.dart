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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/ingredient_filters_notifier.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/network_provider.dart';

part 'ingredient_notifier.g.dart';

/// Debounce window applied to the search-term keystrokes
const _searchDebounce = Duration(milliseconds: 350);

/// Stream of all locally-synced ingredients, ordered by name. Only those
/// ingredients used in a nutritional plan or log are synced for offline use.
@riverpod
Stream<List<Ingredient>> allLocalIngredients(Ref ref) {
  return ref.watch(ingredientRepositoryProvider).watchAllDrift();
}

/// Per-id lookup for a single ingredient from the local Drift database.
/// Riverpod caches per `id` while listeners exist and disposes otherwise,
/// and concurrent reads of the same id share the same future automatically.
@riverpod
Future<Ingredient?> ingredientById(Ref ref, int id) {
  return ref.watch(ingredientRepositoryProvider).getById(id);
}

/// Reactive per-id watch for a single ingredient. Re-emits whenever the
/// ingredient row, its image or any of its weight units changes locally
/// (e.g. PowerSync just pulled an update). Emits `null` if no row with
/// that id exists yet.
@riverpod
Stream<Ingredient?> ingredientByIdStream(Ref ref, int id) {
  return ref.watch(ingredientRepositoryProvider).watchById(id);
}

/// Triggers an ingredient search whenever the filter state changes, debounced
/// to avoid one server request per keystroke. Routes to the REST API when
/// online, to the local-DB subset when offline.
@riverpod
Future<List<Ingredient>> searchedIngredients(Ref ref) async {
  final filters = ref.watch(ingredientFiltersSyncProvider);

  // If the filters change again (or the provider is disposed) before the
  // delay elapses, abort this run so we don't fire a request for an
  // intermediate keystroke.
  var disposed = false;
  ref.onDispose(() => disposed = true);
  await Future.delayed(_searchDebounce);
  if (disposed) {
    throw StateError('search debounced');
  }

  final repo = ref.read(ingredientRepositoryProvider);
  final isOnline = ref.read(networkStatusProvider);
  return repo.search(
    filters.searchTerm,
    isOnline: isOnline,
    searchLanguage: filters.searchLanguage,
    isVegan: filters.isVegan,
    isVegetarian: filters.isVegetarian,
    nutriscoreMax: filters.nutriscoreMax,
  );
}
