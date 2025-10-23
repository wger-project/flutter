import 'package:drift/drift.dart';
import 'package:wger/models/exercises/language.dart';

@UseRowClass(Language)
class LanguageTable extends Table {
  @override
  String get tableName => 'core_language';

  IntColumn get id => integer()();
  TextColumn get shortName => text().named('short_name')();
  TextColumn get fullName => text().named('full_name')();
}
