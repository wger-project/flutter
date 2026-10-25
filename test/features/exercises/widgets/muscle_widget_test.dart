/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/features/exercises/models/muscle.dart';
import 'package:wger/features/exercises/widgets/exercises.dart';

void main() {
  const muscleFront1 = Muscle(id: 1, name: 'Biceps brachii', nameEn: 'Biceps', isFront: true);
  const muscleFront2 = Muscle(id: 2, name: 'Anterior deltoid', nameEn: 'Deltoid', isFront: true);
  const muscleBack1 = Muscle(id: 3, name: 'Gluteus maximus', nameEn: 'Glutes', isFront: false);

  Widget createWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: child,
        ),
      ),
    );
  }

  group('MuscleWidget tests', () {
    testWidgets('Renders front background and front main muscles', (tester) async {
      await tester.pumpWidget(
        createWidget(
          MuscleWidget(
            muscles: const [muscleFront1, muscleBack1],
            isFront: true,
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader is SvgAssetLoader &&
              (widget.bytesLoader as SvgAssetLoader).assetName == 'assets/images/muscles/front.svg',
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader is SvgAssetLoader &&
              (widget.bytesLoader as SvgAssetLoader).assetName ==
                  'assets/images/muscles/main/muscle-1.svg',
        ),
        findsOneWidget,
      );

      // Back muscle should not be rendered on front view
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader is SvgAssetLoader &&
              (widget.bytesLoader as SvgAssetLoader).assetName ==
                  'assets/images/muscles/main/muscle-3.svg',
        ),
        findsNothing,
      );
    });

    testWidgets('Renders back background and back secondary muscles', (tester) async {
      await tester.pumpWidget(
        createWidget(
          MuscleWidget(
            musclesSecondary: const [muscleBack1, muscleFront1],
            isFront: false,
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader is SvgAssetLoader &&
              (widget.bytesLoader as SvgAssetLoader).assetName == 'assets/images/muscles/back.svg',
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader is SvgAssetLoader &&
              (widget.bytesLoader as SvgAssetLoader).assetName ==
                  'assets/images/muscles/secondary/muscle-3.svg',
        ),
        findsOneWidget,
      );

      // Front muscle should not be rendered on back view
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader is SvgAssetLoader &&
              (widget.bytesLoader as SvgAssetLoader).assetName ==
                  'assets/images/muscles/secondary/muscle-1.svg',
        ),
        findsNothing,
      );
    });

    testWidgets('Prioritizes main muscle when muscle is in both main and secondary lists', (
      tester,
    ) async {
      // Muscle 1 is passed as BOTH main and secondary
      await tester.pumpWidget(
        createWidget(
          MuscleWidget(
            muscles: const [muscleFront1],
            musclesSecondary: const [muscleFront1, muscleFront2],
            isFront: true,
          ),
        ),
      );

      // Main muscle 1 should be rendered
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader is SvgAssetLoader &&
              (widget.bytesLoader as SvgAssetLoader).assetName ==
                  'assets/images/muscles/main/muscle-1.svg',
        ),
        findsOneWidget,
      );

      // Secondary muscle 1 should NOT be rendered
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader is SvgAssetLoader &&
              (widget.bytesLoader as SvgAssetLoader).assetName ==
                  'assets/images/muscles/secondary/muscle-1.svg',
        ),
        findsNothing,
      );

      // Secondary muscle 2 should be rendered
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader is SvgAssetLoader &&
              (widget.bytesLoader as SvgAssetLoader).assetName ==
                  'assets/images/muscles/secondary/muscle-2.svg',
        ),
        findsOneWidget,
      );
    });
  });
}
