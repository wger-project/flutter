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
import 'package:provider/provider.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/workouts/gym_mode.dart';

class GymModeScreen extends StatelessWidget {
  const GymModeScreen();
  static const routeName = '/gym-mode';

  @override
  Widget build(BuildContext context) {
    final day = ModalRoute.of(context)!.settings.arguments as Day;

    return Scaffold(
      body: SafeArea(
        child: Consumer<WorkoutPlansProvider>(
          builder: (context, value, child) => GymMode(day),
        ),
      ),
    );
  }
}
