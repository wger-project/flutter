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

import 'package:drift/drift.dart' hide JsonKey;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wger/core/exceptions/no_such_entry_exception.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/uuid.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

part 'measurement_category.freezed.dart';

@freezed
class MeasurementCategory with _$MeasurementCategory {
  @override
  final String uuid;

  @override
  final int? id;

  @override
  final String name;

  @override
  final String unit;

  @override
  final List<MeasurementEntry> entries;

  MeasurementCategory({
    String? uuid,
    this.id,
    this.name = '',
    this.unit = '',
    this.entries = const [],
  }) : uuid = uuid ?? uuidV4();

  MeasurementEntry findEntryByUuid(String entryUuid) {
    return entries.firstWhere(
      (entry) => entry.uuid == entryUuid,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  // Boilerplate
  MeasurementCategoryTableCompanion toCompanion({bool includeId = false}) {
    return MeasurementCategoryTableCompanion(
      uuid: Value(uuid),
      name: Value(name),
      unit: Value(unit),
    );
  }
}
