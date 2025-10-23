import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/exercises/language.dart';

part 'core_data.g.dart';

@riverpod
final class LanguageNotifier extends _$LanguageNotifier {
  @override
  Stream<List<Language>> build() {
    final db = ref.read(driftPowerSyncDatabase);
    return db.select(db.languageTable).watch();
  }
}
