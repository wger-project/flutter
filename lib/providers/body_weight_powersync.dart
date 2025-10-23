// Helper to read body weight entries from PowerSync local database and convert to WeightEntry

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/body_weight/weight_entry.dart';

import 'body_weight_repository.dart';

part 'body_weight_powersync.g.dart';

@riverpod
final class WeightEntryNotifier extends _$WeightEntryNotifier {
  final _log = Logger('WeightEntryNotifier');
  late final BodyWeightRepository _repo;

  @override
  // BodyWeightState build() {
  Stream<List<WeightEntry>> build([BodyWeightRepository? repository]) {
    _repo = repository ?? ref.read(bodyWeightRepositoryProvider);

    // final state = BodyWeightState();
    // repo.watchAllDrift(database).listen((entries) {
    //   state.setItems(entries);
    // });
    // return state;

    return _repo.watchAllDrift();
  }

  Future<void> deleteEntry(String id) async {
    await _repo.deleteLocalDrift(id);
  }

  Future<void> updateEntry(WeightEntry entry) async {
    await _repo.updateLocalDrift(entry);
  }

  Future<void> addEntry(WeightEntry entry) async {
    await _repo.addLocalDrift(entry);
  }
}
