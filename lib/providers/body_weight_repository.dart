/*
 * Repository for body weight network operations.
 */

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/body_weight/weight_entry.dart';

import '../database/powersync/database.dart';

final bodyWeightRepositoryProvider = Provider<BodyWeightRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return BodyWeightRepository(db);
});

class BodyWeightRepository {
  final _logger = Logger('BodyWeightRepository');
  final DriftPowersyncDatabase _db;

  BodyWeightRepository(this._db);

  Stream<List<WeightEntry>> watchAllDrift() {
    _logger.finer('Watching all local weight entries');
    final query = _db.select(_db.weightEntryTable)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<void> deleteLocalDrift(String id) async {
    _logger.finer('Deleting local weight entry $id');
    await (_db.delete(_db.weightEntryTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateLocalDrift(WeightEntry entry) async {
    _logger.finer('Updating local weight entry ${entry.id}');
    final stmt = _db.update(_db.weightEntryTable)..where((t) => t.id.equals(entry.id!));
    await stmt.write(
      WeightEntryTableCompanion(
        date: Value(entry.date),
        weight: Value(entry.weight as double),
      ),
    );
  }

  Future<void> addLocalDrift(WeightEntry entry) async {
    _logger.finer('Adding local weight entry ${entry.date}');
    await _db
        .into(_db.weightEntryTable)
        .insert(
          WeightEntryTableCompanion.insert(
            date: Value(entry.date),
            weight: entry.weight as double,
          ),
        );
  }
}
