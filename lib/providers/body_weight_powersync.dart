// Helper to read body weight entries from PowerSync local database and convert to WeightEntry

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/body_weight/weight_entry.dart';

import '../database/powersync/database.dart';

part 'body_weight_powersync.g.dart';

final _log = Logger('body_weight_powersync');

@riverpod
final class WeightEntryNotifier extends _$WeightEntryNotifier {
  @override
  Stream<List<WeightEntry>> build() {
    final database = ref.watch(driftPowerSyncDatabase);
    final query = database.select(database.weightEntryTable)
      ..orderBy([(t) => OrderingTerm(expression: t.date)]);
    return query.watch();
  }

  Future<void> deleteEntry(String id) async {
    final db = ref.read(driftPowerSyncDatabase);

    await (db.delete(db.weightEntryTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateEntry(WeightEntry entry) async {
    final db = ref.read(driftPowerSyncDatabase);

    final stmt = db.update(db.weightEntryTable)..where((t) => t.id.equals(entry.id!));

    await stmt.write(
      WeightEntryTableCompanion(
        date: Value(entry.date),
        weight: Value(entry.weight as double),
      ),
    );
  }
}
