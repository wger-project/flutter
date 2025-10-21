/*
 * Repository for body weight network operations.
 */

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/base_provider.dart';

class BodyWeightRepository {
  final _logger = Logger('BodyWeightRepository');
  final WgerBaseProvider baseProvider;

  static const BODY_WEIGHT_URL = 'weightentry';

  BodyWeightRepository(this.baseProvider);

  /// Fetches all weight entries (paginated on the server side)
  Future<List<WeightEntry>> fetchAll() async {
    _logger.info('Repository: fetching all body weight entries');

    final data = await baseProvider.fetchPaginated(
      baseProvider.makeUrl(
        BODY_WEIGHT_URL,
        query: {'ordering': '-date', 'limit': API_MAX_PAGE_SIZE},
      ),
    );

    final out = <WeightEntry>[];
    for (final entry in data) {
      out.add(WeightEntry.fromJson(entry));
    }

    return out;
  }

  /// Creates a new weight entry on the server and returns the created object
  Future<WeightEntry> create(WeightEntry entry) async {
    _logger.info('Repository: creating weight entry');
    final data = await baseProvider.post(entry.toJson(), baseProvider.makeUrl(BODY_WEIGHT_URL));
    return WeightEntry.fromJson(data);
  }

  /// Updates an existing weight entry on the server
  Future<void> update(WeightEntry entry) async {
    _logger.info('Repository: updating weight entry ${entry.id}');
    await baseProvider.patch(
      entry.toJson(),
      baseProvider.makeUrl(BODY_WEIGHT_URL, id: int.parse(entry.id!)),
    );
  }

  /// Deletes a weight entry on the server
  Future<Response> delete(String id) async {
    _logger.info('Repository: deleting weight entry $id');
    return await baseProvider.deleteRequest(BODY_WEIGHT_URL, int.parse(id));
  }
}
