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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/dashboard/calendar.dart';
import 'package:wger/widgets/dashboard/widgets/measurements.dart';
import 'package:wger/widgets/dashboard/widgets/nutrition.dart';
import 'package:wger/widgets/dashboard/widgets/routines.dart';
import 'package:wger/widgets/dashboard/widgets/weight.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen();

  static const routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(AppLocalizations.of(context).labelDashboard),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            DashboardRoutineWidget(),
            DashboardNutritionWidget(),
            DashboardWeightWidget(),
            DashboardMeasurementWidget(),
            DashboardCalendarWidget(),
          ],
        ),
      ),
    );
  }
}
