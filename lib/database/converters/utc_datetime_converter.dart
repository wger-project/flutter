/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

/// Persists [DateTime] values as UTC and returns them in the device's local zone.
///
/// Use only on columns backed by a Django `DateTimeField`. Date-only
/// (`DateField`) columns must not use it, or their calendar day would shift in
/// zones west or east of UTC. The local conversion on read is required because
/// both local writes and server sync store instants as UTC
class UtcDateTimeConverter extends TypeConverter<DateTime, DateTime> {
  const UtcDateTimeConverter();

  @override
  DateTime fromSql(DateTime fromDb) => fromDb.toLocal();

  @override
  DateTime toSql(DateTime value) => value.toUtc();
}
