/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:collection/collection.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';

/// Answers the four reads a measurement screen does from one seeded list: the
/// entries-free category streams, and the paged lists, which get the entries
/// the categories carry.
///
/// [repo] is a generated `MockMeasurementRepository`, typed dynamically
/// because only the mock's own signatures accept mockito's matchers.
void stubMeasurementReads(dynamic repo, List<MeasurementCategory> categories) {
  // A fixture either carries its children already or is a flat list to be
  // grouped, and both shapes are in use
  final withChildren = [
    for (final category in categories)
      if (category.children.isNotEmpty)
        category
      else
        category.copyWith(children: categories.where((c) => c.parentId == category.id).toList()),
  ];
  final flat = [
    for (final category in categories) ...[category, ...category.children],
  ];

  when(repo.watchAllWithoutEntries()).thenAnswer((_) => Stream.value(withChildren));

  when(repo.watchOfficialBodyWeightCategory(withEntries: false)).thenAnswer(
    (_) => Stream.value(withChildren.firstWhereOrNull((c) => c.isOfficialBodyWeight)),
  );

  when(repo.watchCategoryWithoutEntries(any)).thenAnswer((invocation) {
    final id = invocation.positionalArguments.first as String;
    return Stream.value(withChildren.firstWhereOrNull((c) => c.id == id));
  });

  when(repo.watchEntries(any, limit: anyNamed('limit'))).thenAnswer((invocation) {
    final id = invocation.positionalArguments.first as String;
    final entries = flat.firstWhereOrNull((c) => c.id == id)?.entries ?? const <MeasurementEntry>[];
    return Stream.value(_newestFirst(entries, invocation.namedArguments[#limit] as int));
  });

  when(repo.watchGroupEntries(any, limit: anyNamed('limit'))).thenAnswer((invocation) {
    final id = invocation.positionalArguments.first as String;
    final group = withChildren.firstWhereOrNull((c) => c.id == id);
    final entries = [
      for (final child in group?.children ?? const <MeasurementCategory>[]) ...child.entries,
    ];
    return Stream.value(_newestFirst(entries, invocation.namedArguments[#limit] as int));
  });
}

List<MeasurementEntry> _newestFirst(Iterable<MeasurementEntry> entries, int limit) =>
    (entries.toList()..sort((a, b) => b.date.compareTo(a.date))).take(limit).toList();
