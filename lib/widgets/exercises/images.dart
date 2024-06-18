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

import 'package:flutter/widgets.dart';
import 'package:wger/models/exercises/image.dart';

class ExerciseImageWidget extends StatelessWidget {
  const ExerciseImageWidget({this.image});

  final ExerciseImage? image;

  @override
  Widget build(BuildContext context) {
    return image != null
        ? FadeInImage(
            placeholder: const AssetImage('assets/images/placeholder.png'),
            image: NetworkImage(image!.url),
            fit: BoxFit.cover,
          )
        : const Image(
            image: AssetImage('assets/images/placeholder.png'),
            color: Color.fromRGBO(255, 255, 255, 0.3),
            colorBlendMode: BlendMode.modulate,
          );
  }
}
