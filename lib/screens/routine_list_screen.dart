/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
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
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/routines/app_bar.dart';
import 'package:wger/widgets/routines/forms/routine.dart';
import 'package:wger/widgets/routines/routines_list.dart';

class RoutineListScreen extends riverpod.ConsumerWidget {
  const RoutineListScreen();

  static const routeName = '/workout-plans-list';

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final isOnline = ref.watch(networkStatusProvider);

    return Scaffold(
      appBar: const RoutineListAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isOnline ? null : Colors.grey,
        onPressed: isOnline
            ? () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context).newRoutine,
                    RoutineForm(Routine.empty(), useListView: true),
                    hasListView: true,
                  ),
                );
              }
            : null,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: WidescreenWrapper(child: RoutinesList()),
    );
  }
}
