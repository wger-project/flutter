/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:drift/drift.dart';
import 'package:powersync/powersync.dart' as ps;
import 'package:wger/models/core/language.dart';

@UseRowClass(Language)
class LanguageTable extends Table {
  @override
  String get tableName => 'core_language';

  IntColumn get id => integer()();
  TextColumn get shortName => text().named('short_name')();
  TextColumn get fullName => text().named('full_name')();
}

const PowersyncLanguageTable = ps.Table(
  'core_language',
  [
    ps.Column.text('short_name'),
    ps.Column.text('full_name'),
  ],
);
