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

/// Ignores mouse wheel and trackpad scrolls until the viewport has content
/// dimensions. The framework reads them unguarded, so a scroll that lands on a
/// not-yet-laid-out list would otherwise crash with a null check.
class LaidOutScrollPhysics extends ScrollPhysics {
  const LaidOutScrollPhysics({super.parent});

  @override
  LaidOutScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return LaidOutScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return position.hasContentDimensions && super.shouldAcceptUserOffset(position);
  }
}

/// App-wide scroll behavior: the platform default physics wrapped in
/// [LaidOutScrollPhysics].
class WgerScrollBehavior extends MaterialScrollBehavior {
  const WgerScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const LaidOutScrollPhysics().applyTo(super.getScrollPhysics(context));
  }
}
