import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/exercises/language.dart';

part 'core_data.g.dart';

@riverpod
Stream<List<Language>> languages(Ref ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return db.select(db.languageTable).watch();
}
