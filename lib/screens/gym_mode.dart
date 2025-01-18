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
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/gym_mode.dart';

class GymModeArguments {
  final int routineId;
  final int dayId;
  final int iteration;

  const GymModeArguments(this.routineId, this.dayId, this.iteration);
}

class GymModeScreen extends StatelessWidget {
  const GymModeScreen();

  static const routeName = '/gym-mode';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GymModeArguments;

    final routinesProvider = context.read<RoutinesProvider>();
    final routine = routinesProvider.findById(args.routineId);
    final dayDataDisplay =
        routine.dayData.firstWhere((e) => e.iteration == args.iteration && e.day?.id == args.dayId);
    final dayDataGym = routine.dayDataGym
        .where((e) => e.iteration == args.iteration && e.day?.id == args.dayId)
        .first;

    return Scaffold(
      body: SafeArea(
        child: Consumer<RoutinesProvider>(
          builder: (context, value, child) => GymMode(dayDataGym, dayDataDisplay, args.iteration),
        ),
      ),
    );
  }
}
