/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/screens/exercise_screen.dart';
import 'package:wger/widgets/exercises/images.dart';

class ExerciseListTile extends StatelessWidget {
  const ExerciseListTile({Key? key, required this.exercise}) : super(key: key);

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    //final theme = Theme.of(context);
    const double IMG_SIZE = 60;

    return ListTile(
      leading: SizedBox(
        height: IMG_SIZE,
        width: IMG_SIZE,
        child: CircleAvatar(
          backgroundColor: const Color(0x00ffffff),
          child: ClipOval(
            child: SizedBox(
              height: IMG_SIZE,
              width: IMG_SIZE,
              child: ExerciseImageWidget(
                image: exercise.getMainImage,
              ),
            ),
          ),
        ),
      ),
      trailing: Text(exercise.language.shortName),
      title: Text(
        exercise.name,
        //style: theme.textTheme.headline6,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Text(
        exercise.category.name,
      ),
      onTap: () {
        Navigator.pushNamed(context, ExerciseDetailScreen.routeName, arguments: exercise);
      },
      /*
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: theme.primaryColorLight.withOpacity(0.15),
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          exercise.category.name,
        ),
      ),

       */
    );

    /*
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: size.width * 0.2,
            child: Center(
              child: ExerciseImageWidget(
                image: exercise.getMainImage,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: theme.primaryColorLight.withOpacity(0.15),
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  exercise.category.name,
                ),
              ),
              Text(
                exercise.name,
                style: theme.textTheme.headline6,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              Text(
                exercise.equipment.map((equipment) => equipment.name).join(", "),
              )
            ],
          ),
        )
      ],
    );

     */
  }
}
