/*
 * Repository for body weight network operations.
 */

import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/powersync.dart' as ps;
import 'package:wger/powersync/schema.dart';

class BodyWeightRepository {
  final _logger = Logger('BodyWeightRepository');

  static const BODY_WEIGHT_URL = 'weightentry';

  BodyWeightRepository();

  /// Fetches all weight entries (paginated on the server side)
  Future<List<WeightEntry>> fetchAll() async {
    _logger.info('Repository: fetching all body weight entries');

    // final data = await baseProvider.fetchPaginated(
    //   baseProvider.makeUrl(
    //     BODY_WEIGHT_URL,
    //     query: {'ordering': '-date', 'limit': API_MAX_PAGE_SIZE},
    //   ),
    // );

    final out = <WeightEntry>[];
    // for (final entry in data) {
    //   out.add(WeightEntry.fromJson(entry));
    // }

    return out;
  }

  /// Creates a new weight entry on the server and returns the created object
  Future<WeightEntry> create(WeightEntry entry) async {
    _logger.info('Repository: creating weight entry');
    final result = await ps.db.execute(
      'INSERT INTO $tableBodyWeight (id, weight, date) VALUES (?, ?, ?)',
      [
        uuid.v4(),
        entry.weight,
        entry.date.toIso8601String(),
      ],
    );
    _logger.fine('result of insert: $result');

    return WeightEntry();
    return WeightEntry.fromRow(result.first);
  }

  /// Updates an existing weight entry on the server
  Future<WeightEntry> update(WeightEntry entry) async {
    _logger.info('Repository: updating weight entry ${entry.id}');

    final result = await ps.db.execute(
      'UPDATE $tableBodyWeight SET weight = ?, date = ? WHERE id = ?',
      [
        entry.weight,
        entry.date.toIso8601String(),
        entry.id,
      ],
    );

    _logger.fine('result of update: $result');

    return WeightEntry();
    return WeightEntry.fromRow(result.first);
  }

  /// Deletes a weight entry on the server
  Future<void> delete(String id) async {
    _logger.info('Repository: deleting weight entry $id');
    await ps.db.execute(
      'DELETE FROM $tableBodyWeight WHERE id = ?',
      [id],
    );
  }
}
