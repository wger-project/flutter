// Helper to read body weight entries from PowerSync local database and convert to WeightEntry

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/body_weight/weight_entry.dart';

import '../database/powersync/database.dart';
import 'body_weight_riverpod.dart';

part 'body_weight_powersync.g.dart';

final _log = Logger('body_weight_powersync');

@riverpod
final class WeightEntryNotifier extends _$WeightEntryNotifier {
  @override
  Stream<List<WeightEntry>> build() {
    final database = ref.watch(driftPowerSyncDatabase);
    final repo = ref.watch(bodyWeightRepositoryProvider);
    return repo.watchAllDrift(database);
  }

  Future<void> deleteEntry(String id) async {
    final db = ref.read(driftPowerSyncDatabase);
    final repo = ref.read(bodyWeightRepositoryProvider);
    await repo.deleteLocalDrift(db, id);
  }

  Future<void> updateEntry(WeightEntry entry) async {
    final db = ref.read(driftPowerSyncDatabase);
    final repo = ref.read(bodyWeightRepositoryProvider);
    await repo.updateLocalDrift(db, entry);
  }

  Future<void> addEntry(WeightEntry entry) async {
    final db = ref.read(driftPowerSyncDatabase);
    _log.info('Adding new weight entry on local drift: ${entry.date} - ${entry.weight}');
    await db
        .into(db.weightEntryTable)
        .insertReturning(
          WeightEntryTableCompanion.insert(
            date: Value(entry.date),
            weight: entry.weight as double,
          ),
        );
  }
}
