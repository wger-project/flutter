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

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/widgets/svg_icon.dart';

void main() {
  const ASSET = 'assets/icons/meal-diary.svg';

  Future<SvgPicture> pumpIcon(
    WidgetTester tester, {
    required IconThemeData iconTheme,
    Color? color,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: IconTheme(
          data: iconTheme,
          child: SvgIcon(ASSET, color: color),
        ),
      ),
    );
    return tester.widget<SvgPicture>(find.byType(SvgPicture));
  }

  testWidgets('takes size and color from the surrounding icon theme', (tester) async {
    final picture = await pumpIcon(
      tester,
      iconTheme: const IconThemeData(color: Colors.red, size: 42),
    );

    expect(picture.width, 42);
    expect(picture.height, 42);
    expect(picture.colorFilter, const ui.ColorFilter.mode(Colors.red, ui.BlendMode.srcIn));
  });

  testWidgets('an explicit color wins over the icon theme', (tester) async {
    final picture = await pumpIcon(
      tester,
      iconTheme: const IconThemeData(color: Colors.red, size: 42),
      color: Colors.white,
    );

    expect(picture.colorFilter, const ui.ColorFilter.mode(Colors.white, ui.BlendMode.srcIn));
    // the size still comes from the theme
    expect(picture.width, 42);
  });

  testWidgets('falls back to the icon color of the app theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(iconTheme: const IconThemeData(color: Colors.green, size: 15)),
        home: const SvgIcon(ASSET),
      ),
    );

    final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(picture.colorFilter, const ui.ColorFilter.mode(Colors.green, ui.BlendMode.srcIn));
    expect(picture.width, 15);
  });
}
