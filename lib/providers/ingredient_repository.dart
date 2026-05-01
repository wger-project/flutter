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

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/wger_base.dart';

import '../database/powersync/database.dart';

/// Which language(s) the server-side ingredient search should consider.
enum IngredientSearchLanguage {
  current,
  currentAndEnglish,
  all,
}

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  final base = ref.read(wgerBaseProvider);
  final db = ref.read(driftPowerSyncDatabase);
  return IngredientRepository(base, db);
});

/// Data access for ingredient lookups and searches
class IngredientRepository {
  final _logger = Logger('IngredientRepository');
  final WgerBaseProvider _base;
  final DriftPowersyncDatabase _db;

  static const ingredientInfoPath = 'ingredientinfo';

  IngredientRepository(this._base, this._db);

  /// Watches a single ingredient by [id] with its `image` and `weightUnits`
  /// fields fully hydrated. Emits `null` if no ingredient with that id exists,
  /// and re-emits whenever the ingredient row, its image, or any of its
  /// weight units change.
  Stream<Ingredient?> watchById(int id) {
    _logger.finer('Watching ingredient $id');
    final query = _baseJoinedQuery()..where(_db.ingredientTable.id.equals(id));
    return query.watch().map((rows) {
      final hydrated = _hydrate(rows);
      return hydrated.isEmpty ? null : hydrated.first;
    });
  }

  /// Read a single ingredient by [id] once from the DB
  Future<Ingredient?> getById(int id) async {
    _logger.finer('Reading ingredient $id');
    return watchById(id).first;
  }

  /// Substring-search by name against the locally-synced ingredients,
  /// with optional diet-flag and Nutri-Score filters. Used for offline-mode
  /// ingredient pickers
  ///
  /// Hydrates `image` and `weightUnits` on the returned rows so the
  /// result is shape-compatible with the REST search.
  Future<List<Ingredient>> searchIngredientLocal(
    String term, {
    bool isVegan = false,
    bool isVegetarian = false,
    NutriScore? nutriscoreMax,
    int limit = 100,
  }) async {
    _logger.finer('Local ingredient search: "$term"');
    final query = _baseJoinedQuery()
      ..where(_db.ingredientTable.name.lower().like('%${term.toLowerCase()}%'));

    if (isVegan) {
      query.where(_db.ingredientTable.isVegan.equals(true));
    }
    if (isVegetarian) {
      query.where(_db.ingredientTable.isVegetarian.equals(true));
    }
    if (nutriscoreMax != null) {
      query.where(_db.ingredientTable.nutriscore.isSmallerOrEqualValue(nutriscoreMax.name));
    }
    query
      ..orderBy([OrderingTerm(expression: _db.ingredientTable.name)])
      ..limit(limit);

    return _hydrate(await query.get());
  }

  /// Searches for ingredients via the wger REST API.
  Future<List<Ingredient>> searchIngredientServer(
    String name, {
    String languageCode = 'en',
    IngredientSearchLanguage searchLanguage = IngredientSearchLanguage.current,
    bool isVegan = false,
    bool isVegetarian = false,
    NutriScore? nutriscoreMax,
  }) async {
    if (name.length <= 1) {
      return [];
    }
    final List<String> languages = [];

    switch (searchLanguage) {
      case IngredientSearchLanguage.current:
        languages.add(languageCode);
      case IngredientSearchLanguage.currentAndEnglish:
        languages.add(languageCode);
        if (languageCode != LANGUAGE_SHORT_ENGLISH) {
          languages.add(LANGUAGE_SHORT_ENGLISH);
        }
      case IngredientSearchLanguage.all:
        // Don't add any language code to search in all languages
        break;
    }

    final query = {
      'name__search': name,
      'limit': API_RESULTS_PAGE_SIZE,
    };
    if (languages.isNotEmpty) {
      query['language__code'] = languages.join(',');
    }
    if (isVegan) {
      query['is_vegan'] = 'true';
    }
    if (isVegetarian) {
      query['is_vegetarian'] = 'true';
    }
    if (nutriscoreMax != null) {
      query['nutriscore__lte'] = nutriscoreMax.name;
    }

    _logger.info('Searching ingredients from server');
    final response = await _base.fetch(
      _base.makeUrl(ingredientInfoPath, query: query),
      timeout: const Duration(seconds: 20),
    );

    return (response['results'] as List)
        .map((data) => Ingredient.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// Looks up an ingredient by its product barcode via the REST API.
  /// Returns `null` if no matching product is found.
  Future<Ingredient?> searchIngredientByBarcode(String barcode) async {
    if (barcode.isEmpty) {
      return null;
    }
    final data = await _base.fetch(
      _base.makeUrl(ingredientInfoPath, query: {'code': barcode}),
    );
    if (data['count'] == 0) {
      return null;
    }
    return Ingredient.fromJson(data['results'][0]);
  }

  /// Builds the standard joined query used by every ingredient lookup
  JoinedSelectStatement<HasResultSet, dynamic> _baseJoinedQuery() {
    return _db.select(_db.ingredientTable).join([
      leftOuterJoin(
        _db.ingredientImageTable,
        _db.ingredientImageTable.ingredientId.equalsExp(_db.ingredientTable.id),
      ),
      leftOuterJoin(
        _db.ingredientWeightUnitTable,
        _db.ingredientWeightUnitTable.ingredientId.equalsExp(_db.ingredientTable.id),
      ),
    ]);
  }

  /// Collapses cross-joined rows into a deduped list of hydrated ingredients
  List<Ingredient> _hydrate(Iterable<TypedResult> rows) {
    final Map<int, Ingredient> ingredients = {};
    final Map<int, List<IngredientWeightUnit>> weightUnits = {};

    for (final row in rows) {
      final ingredient = row.readTable(_db.ingredientTable);
      final image = row.readTableOrNull(_db.ingredientImageTable);
      final weightUnit = row.readTableOrNull(_db.ingredientWeightUnitTable);

      final entry = ingredients.putIfAbsent(ingredient.id, () => ingredient);
      if (image != null) {
        entry.image = image;
      }
      if (weightUnit != null) {
        final list = weightUnits.putIfAbsent(ingredient.id, () => []);
        if (!list.any((w) => w.id == weightUnit.id)) {
          list.add(weightUnit);
        }
      }
    }

    for (final entry in ingredients.values) {
      entry.weightUnits = weightUnits[entry.id] ?? const [];
    }

    return ingredients.values.toList();
  }
}
