// Helper to read body weight entries from PowerSync local database and convert to WeightEntry

import 'package:logging/logging.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/models/powersync/schema.dart';
import 'package:wger/powersync.dart' as ps;

final _log = Logger('body_weight_powersync');

/// Watch the body weight entries as a stream.
Stream<List<WeightEntry>> watchBodyWeightEntries({
  Duration pollInterval = const Duration(seconds: 2),
}) {
  return ps.db.watch('SELECT * FROM $tableBodyWeights ORDER BY id').map((results) {
    return results.map(WeightEntry.fromRow).toList(growable: false);
  });
}
