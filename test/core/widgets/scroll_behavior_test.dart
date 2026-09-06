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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/widgets/scroll_behavior.dart';

void main() {
  ScrollMetrics metrics({double? minExtent, double? maxExtent, double? pixels}) {
    return FixedScrollMetrics(
      minScrollExtent: minExtent,
      maxScrollExtent: maxExtent,
      pixels: pixels,
      viewportDimension: 100,
      axisDirection: AxisDirection.down,
      devicePixelRatio: 1,
    );
  }

  group('LaidOutScrollPhysics', () {
    const physics = LaidOutScrollPhysics();

    test('rejects user offsets before the viewport has content dimensions', () {
      expect(physics.shouldAcceptUserOffset(metrics()), isFalse);
    });

    test('delegates to the parent once laid out', () {
      final chained = physics.applyTo(const ClampingScrollPhysics());

      expect(
        chained.shouldAcceptUserOffset(metrics(minExtent: 0, maxExtent: 50, pixels: 0)),
        isTrue,
      );
      expect(
        chained.shouldAcceptUserOffset(metrics(minExtent: 0, maxExtent: 0, pixels: 0)),
        isFalse,
      );
    });
  });

  testWidgets('WgerScrollBehavior wraps the platform physics', (tester) async {
    late ScrollPhysics physics;
    await tester.pumpWidget(
      MaterialApp(
        scrollBehavior: const WgerScrollBehavior(),
        home: Builder(
          builder: (context) {
            physics = ScrollConfiguration.of(context).getScrollPhysics(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(physics, isA<LaidOutScrollPhysics>());
    expect(physics.parent, isNotNull);
  });
}
