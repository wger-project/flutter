import 'package:powersync/sqlite3.dart' as sqlite;
import 'package:wger/models/schema.dart';
import 'package:wger/powersync.dart';

class Muscle {
  final String id;
  final String name;
  final String nameEn;
  final bool isFront;

  const Muscle({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.isFront,
  });

  factory Muscle.fromRow(sqlite.Row row) {
    return Muscle(
      id: row['id'],
      name: row['name'],
      nameEn: row['name_en'],
      isFront: row['is_front'] == 1,
    );
  }

  Future<void> delete() async {
    await db.execute('DELETE FROM $musclesTable WHERE id = ?', [id]);
  }

  /// Watch all lists.
  static Stream<List<Muscle>> watchMuscles() {
    return db.watch('SELECT * FROM muscles ORDER BY id').map((results) {
      return results.map(Muscle.fromRow).toList(growable: false);
    });
  }
}
