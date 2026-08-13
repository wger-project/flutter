/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

part 'body_weight_provider.g.dart';

/// The user's official body weight category.
///
/// The category is created by the server (registration / data migration) and
/// only arrives via sync; a `null` value means the initial sync has not
/// delivered it yet. Mutations go through `measurementProvider`'s notifier,
/// its readings through the aggregated queries, which take its id from here.
///
/// Selected by its type in the query rather than picked out of every category
/// afterwards: it has no fixed id, the server assigns it.
@riverpod
Stream<MeasurementCategory?> bodyWeightCategoryOnly(Ref ref) {
  return ref.read(measurementRepositoryProvider).watchOfficialBodyWeightCategory();
}
