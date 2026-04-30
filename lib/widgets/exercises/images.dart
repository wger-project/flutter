/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'package:flutter/material.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/widgets/core/wger_image.dart';

/// Renders an exercise image with disk + memory caching, falling back to
/// a tinted asset placeholder when [image] is null or the network load
/// fails. Optional [height] constrains the rendered box; width is always
/// derived from the parent.
class ExerciseImageWidget extends StatelessWidget {
  const ExerciseImageWidget({super.key, this.image, this.height});

  final ExerciseImage? image;
  final double? height;

  static const _placeholder = Image(
    image: AssetImage('assets/images/placeholder.png'),
    color: Color.fromRGBO(255, 255, 255, 0.3),
    colorBlendMode: BlendMode.modulate,
    semanticLabel: 'Placeholder',
  );

  @override
  Widget build(BuildContext context) {
    return WgerImage(
      mediaPath: image?.image,
      height: height,
      // No width — let the parent decide, matching the previous Image.network
      // behaviour where the natural aspect ratio drove sizing.
      fit: BoxFit.contain,
      errorWidget: _placeholder,
    );
  }
}
