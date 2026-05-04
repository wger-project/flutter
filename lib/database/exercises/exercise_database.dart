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
import 'package:drift_flutter/drift_flutter.dart';
import 'package:logging/logging.dart';
import 'package:wger/database/exercises/type_converters.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';

part 'exercise_database.g.dart';

@DataClassName('ExerciseTable')
class Exercises extends Table {
  const Exercises();

  IntColumn get id => integer()();

  TextColumn get data => text()();

  // TextColumn get data => text().map(const ExerciseBaseConverter())();

  DateTimeColumn get lastUpdate => dateTime()();

  /// The date when the exercise was last fetched from the API. While we know
  /// when the exercise itself was last updated in `lastUpdate`, we can save
  /// ourselves a lot of requests if we don't check too often
  DateTimeColumn get lastFetched => dateTime()();
}

@DataClassName('MuscleTable')
class Muscles extends Table {
  const Muscles();

  IntColumn get id => integer()();

  TextColumn get data => text().map(const MuscleConverter())();
}

@DataClassName('CategoryTable')
class Categories extends Table {
  const Categories();

  IntColumn get id => integer()();

  TextColumn get data => text().map(const ExerciseCategoryConverter())();
}

@DataClassName('LanguagesTable')
class Languages extends Table {
  const Languages();

  IntColumn get id => integer()();

  TextColumn get data => text().map(const LanguageConverter())();
}

@DataClassName('EquipmentTable')
class Equipments extends Table {
  const Equipments();

  IntColumn get id => integer()();

  TextColumn get data => text().map(const EquipmentConverter())();
}

@DriftDatabase(tables: [Exercises, Muscles, Equipments, Categories, Languages])
class ExerciseDatabase extends _$ExerciseDatabase {
  final _logger = Logger('ExerciseDatabase');

  ExerciseDatabase() : super(_openConnection());

  // Named constructor for creating in-memory database
  ExerciseDatabase.inMemory(super.e);

  /// Note that this needs to be bumped if the JSON response from the server changes
  @override
  int get schemaVersion => 4;

  /// There is not really a migration strategy. If we bump the version
  /// number, delete everything and recreate the new tables. The provider
  /// will fetch everything as needed from the server
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // no-op, but needs to be defined
      return;
    },
    beforeOpen: (openingDetails) async {
      if (openingDetails.hadUpgrade) {
        final m = createMigrator();
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
          await m.createTable(table);
        }
      }
    },
  );

  Future<void> deleteEverything() {
    return transaction(() async {
      for (final table in allTables) {
        _logger.info('Deleting db cache table ${table.actualTableName}');
        await delete(table).go();
      }
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'exercises');
}
