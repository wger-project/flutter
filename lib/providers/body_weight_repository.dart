/*
 * Repository for body weight network operations.
 */

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/body_weight/weight_entry.dart';

import '../database/powersync/database.dart';

class BodyWeightRepository {
  final _logger = Logger('BodyWeightRepository');

  BodyWeightRepository();

  Stream<List<WeightEntry>> watchAllDrift(DriftPowersyncDatabase db) {
    _logger.finer('Watching all local weight entries');
    final query = db.select(db.weightEntryTable)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<void> deleteLocalDrift(DriftPowersyncDatabase db, String id) async {
    _logger.finer('Deleting local weight entry $id');
    await (db.delete(db.weightEntryTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateLocalDrift(DriftPowersyncDatabase db, WeightEntry entry) async {
    _logger.finer('Updating local weight entry ${entry.id}');
    final stmt = db.update(db.weightEntryTable)..where((t) => t.id.equals(entry.id!));
    await stmt.write(
      WeightEntryTableCompanion(
        date: Value(entry.date),
        weight: Value(entry.weight as double),
      ),
    );
  }
}
