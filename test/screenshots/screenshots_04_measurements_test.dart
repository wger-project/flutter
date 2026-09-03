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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/features/measurements/widgets/categories_card.dart';
import 'package:wger/features/measurements/widgets/measurement_tile.dart';

import 'screenshots_04_measurements.dart';

void main() {
  setUp(() {
    // The overview reads the shared chart range, which hydrates from prefs
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('the store scene fills the grid: weight card plus one tile per form', (
    tester,
  ) async {
    // Tall enough for the whole grid; the slivers build only what they show
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(createMeasurementScreen());
    await tester.pumpAndSettle();

    // The weight card on top, every other category as a tile
    expect(find.byType(CategoriesCard), findsOneWidget);
    expect(find.byType(MeasurementTile), findsNWidgets(7));

    // One tile per spark form, recognisable by its hero or footer: the sleep
    // total, the fixed last-night reading, and the hand-kept tape measure
    expect(find.text('7:12 h'), findsOneWidget);
    expect(find.text('38.5 cm'), findsOneWidget);
  });
}
