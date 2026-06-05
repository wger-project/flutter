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
import 'package:powersync/powersync.dart' as ps;
import 'package:wger/database/converters/utc_datetime_converter.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_image.dart' show IngredientImage;
import 'package:wger/models/nutrition/ingredient_weight_unit.dart' show IngredientWeightUnit;

@UseRowClass(Ingredient)
class IngredientTable extends Table {
  @override
  String get tableName => 'nutrition_ingredient';

  // Numerical id from the remote API
  IntColumn get id => integer()();

  // Local client UUID for sync purposes
  TextColumn get uuid => text().clientDefault(() => ps.uuid.v4())();

  // Other metadata
  IntColumn get languageId => integer().named('language_id')();
  TextColumn get remoteId => text().nullable().named('remote_id')();
  TextColumn get sourceName => text().nullable().named('source_name')();
  TextColumn get sourceUrl => text().nullable().named('source_url')();
  TextColumn get licenseObjectURl => text().named('license_object_url').nullable()();

  // Product code / barcode
  TextColumn get code => text().nullable()();

  // Display name (required)
  TextColumn get name => text()();

  // Brand of the product
  TextColumn get brand => text().nullable()();

  // Creation timestamp from server
  DateTimeColumn get created => dateTime().map(const UtcDateTimeConverter())();

  // Energy and macronutrients
  IntColumn get energy => integer()();
  RealColumn get carbohydrates => real()();
  RealColumn get carbohydratesSugar => real().nullable().named('carbohydrates_sugar')();
  RealColumn get protein => real()();
  RealColumn get fat => real()();
  RealColumn get fatSaturated => real().nullable().named('fat_saturated')();
  RealColumn get fiber => real().nullable()();
  RealColumn get sodium => real().nullable()();

  BoolColumn get isVegan => boolean().nullable().named('is_vegan')();
  BoolColumn get isVegetarian => boolean().nullable().named('is_vegetarian')();

  // Stored as a single character ('a'–'e') matching `NutriScore.<x>.name`.
  Column<String> get nutriscore => textEnum<NutriScore>().nullable()();
}

const PowersyncIngredientTable = ps.Table(
  'nutrition_ingredient',
  [
    ps.Column.text('uuid'),
    ps.Column.integer('language_id'),
    ps.Column.text('remote_id'),
    ps.Column.text('source_name'),
    ps.Column.text('source_url'),
    ps.Column.text('license_object_url'),
    ps.Column.text('code'),
    ps.Column.text('name'),
    ps.Column.text('brand'),
    ps.Column.text('created'),
    ps.Column.integer('energy'),
    ps.Column.real('carbohydrates'),
    ps.Column.real('carbohydrates_sugar'),
    ps.Column.real('protein'),
    ps.Column.real('fat'),
    ps.Column.real('fat_saturated'),
    ps.Column.real('fiber'),
    ps.Column.real('sodium'),
    ps.Column.integer('is_vegan'),
    ps.Column.integer('is_vegetarian'),
    ps.Column.text('nutriscore'),
  ],
  indexes: [
    ps.Index('language_idx', [ps.IndexedColumn('language_id')]),
  ],
);

@UseRowClass(IngredientImage)
class IngredientImageTable extends Table {
  @override
  String get tableName => 'nutrition_image';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get ingredientId => integer().named('ingredient_id').references(IngredientTable, #id)();
  // Relative path under MEDIA_ROOT (Django's ImageField stores this)
  TextColumn get image => text()();
  IntColumn get size => integer()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  DateTimeColumn get created => dateTime().map(const UtcDateTimeConverter())();
  DateTimeColumn get lastUpdate =>
      dateTime().named('last_update').map(const UtcDateTimeConverter())();

  // License (TASL). license_author may be null on the server (TextField with
  // null=True); the others are not-null strings (possibly empty).
  IntColumn get licenseId => integer().named('license_id')();
  TextColumn get author => text().named('license_author').nullable()();
  TextColumn get authorUrl => text().named('license_author_url')();
  TextColumn get title => text().named('license_title')();
  TextColumn get objectUrl => text().named('license_object_url')();
  TextColumn get derivativeSourceUrl => text().named('license_derivative_source_url')();
}

const PowersyncIngredientImageTable = ps.Table(
  'nutrition_image',
  [
    ps.Column.text('uuid'),
    ps.Column.integer('ingredient_id'),
    ps.Column.text('image'),
    ps.Column.integer('size'),
    ps.Column.integer('width'),
    ps.Column.integer('height'),
    ps.Column.text('created'),
    ps.Column.text('last_update'),
    ps.Column.integer('license_id'),
    ps.Column.text('license_author'),
    ps.Column.text('license_author_url'),
    ps.Column.text('license_title'),
    ps.Column.text('license_object_url'),
    ps.Column.text('license_derivative_source_url'),
  ],
  indexes: [
    ps.Index('ingredient_idx', [ps.IndexedColumn('ingredient_id')]),
    ps.Index('license_idx', [ps.IndexedColumn('license_id')]),
  ],
);

@UseRowClass(IngredientWeightUnit)
class IngredientWeightUnitTable extends Table {
  @override
  String get tableName => 'nutrition_ingredientweightunit';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get ingredientId => integer().named('ingredient_id').references(IngredientTable, #id)();
  TextColumn get name => text()();
  IntColumn get grams => integer().named('gram')();
}

const PowersyncIngredientWeightUnitTable = ps.Table(
  'nutrition_ingredientweightunit',
  [
    ps.Column.text('uuid'),
    ps.Column.integer('ingredient_id'),
    ps.Column.text('name'),
    ps.Column.integer('gram'),
  ],
  indexes: [
    ps.Index('ingredient_idx', [ps.IndexedColumn('ingredient_id')]),
  ],
);
