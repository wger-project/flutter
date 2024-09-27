import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'ingredients_database.g.dart';

@DataClassName('IngredientTable')
class Ingredients extends Table {
  const Ingredients();

  IntColumn get id => integer()();

  TextColumn get data => text()();

  /// The date when the ingredient was last fetched from the server
  DateTimeColumn get lastFetched => dateTime()();
}

@DriftDatabase(tables: [Ingredients])
class IngredientDatabase extends _$IngredientDatabase {
  IngredientDatabase() : super(_openConnection());

  // Named constructor for creating in-memory database
  IngredientDatabase.inMemory(super.e);

  /// Note that this needs to be bumped if the JSON response from the server changes
  @override
  int get schemaVersion => 2;

  /// There is not really a migration strategy. If we bump the version
  /// number, delete everything and recreate the new tables. The nutrition provider
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
        await delete(table).go();
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationCacheDirectory();
    final file = File(p.join(dbFolder.path, 'ingredients.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
