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

/// The user's official body weight category, entries sorted newest-first.
///
/// The category is created by the server (registration / data migration) and
/// only arrives via sync; a `null` value means the initial sync has not
/// delivered it yet. Mutations go through `measurementProvider`'s notifier.
///
/// Unbounded, for the consumers that walk the entries themselves (the
/// dashboard card, the nutrition widgets). The body weight screen takes
/// [bodyWeightCategoryOnly], which reads none.
@riverpod
AsyncValue<MeasurementCategory?> bodyWeightCategory(Ref ref) {
  return ref.watch(bodyWeightCategorySinceProvider(null));
}

/// The official body weight category without its entries, for the screen,
/// which reads its chart and its list through their own queries.
@riverpod
Stream<MeasurementCategory?> bodyWeightCategoryOnly(Ref ref) {
  return ref
      .read(measurementRepositoryProvider)
      .watchOfficialBodyWeightCategory(
        withEntries: false,
      );
}

/// The official body weight category with the entries from [since] on, null
/// covering the full history.
///
/// The bound is applied in the query rather than in the chart, so showing three
/// months does not read years of entries into memory. So is the category
/// itself: reading every category and keeping one made a body fat or sleep
/// entry re-materialise the whole measurement history.
@riverpod
Stream<MeasurementCategory?> bodyWeightCategorySince(Ref ref, DateTime? since) {
  return ref
      .read(measurementRepositoryProvider)
      .watchOfficialBodyWeightCategory(entriesSince: since);
}
