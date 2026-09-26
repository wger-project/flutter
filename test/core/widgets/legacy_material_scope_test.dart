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

import 'package:flutter/material.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/widgets/legacy_material_scope.dart';

void main() {
  const seed = Color(0xFF2A4C7D);

  Widget app(Widget child) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed)),
    home: Scaffold(body: child),
  );

  testWidgets('an SDK InkWell finds its Material ancestor', (tester) async {
    await tester.pumpWidget(
      app(
        LegacyMaterialScope(
          child: legacy.InkWell(onTap: () {}, child: const Text('tap')),
        ),
      ),
    );
    await tester.tap(find.text('tap'));

    expect(tester.takeException(), isNull);
  });

  testWidgets('SDK widgets see the app theme and localizations', (tester) async {
    late legacy.ThemeData legacyTheme;
    late legacy.MaterialLocalizations? legacyL10n;
    await tester.pumpWidget(
      app(
        LegacyMaterialScope(
          ink: false,
          child: Builder(
            builder: (context) {
              legacyTheme = legacy.Theme.of(context);
              legacyL10n = Localizations.of(context, legacy.MaterialLocalizations);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(
      legacyTheme.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: seed).primary,
    );
    expect(legacyL10n, isNotNull);
  });
}
