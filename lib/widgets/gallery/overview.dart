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
import 'package:provider/provider.dart';
import 'package:wger/providers/workout_plans.dart';

class Gallery extends StatelessWidget {
  const Gallery();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutPlans>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(5),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        children: List.generate(provider.images.length, (index) {
          return FadeInImage(
            placeholder: AssetImage('assets/images/placeholder.png'),
            image: NetworkImage(provider.images[index].url),
            fit: BoxFit.cover,
          );
        }),
      ),
    );
  }
}
