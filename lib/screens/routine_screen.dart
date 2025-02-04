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
import 'package:provider/provider.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/app_bar.dart';
import 'package:wger/widgets/routines/routine_detail.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  static const routeName = '/routine-detail';

  @override
  Widget build(BuildContext context) {
    final routineId = ModalRoute.of(context)!.settings.arguments as int;
    final provider = context.read<RoutinesProvider>();

    final routine = provider.findById(routineId);

    return Scaffold(
      appBar: RoutineDetailAppBar(routine),
      body: SingleChildScrollView(
        child: Consumer<RoutinesProvider>(
          builder: (context, value, child) => RoutineDetail(routine),
        ),
      ),
    );
  }
}
