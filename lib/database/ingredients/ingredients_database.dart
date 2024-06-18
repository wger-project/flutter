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

  DateTimeColumn get lastUpdate => dateTime()();
}

@DriftDatabase(tables: [Ingredients])
class IngredientDatabase extends _$IngredientDatabase {
  IngredientDatabase() : super(_openConnection());

  // Named constructor for creating in-memory database
  IngredientDatabase.inMemory(super.e);

  @override
  // TODO: implement schemaVersion
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationCacheDirectory();
    final file = File(p.join(dbFolder.path, 'ingredients.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
