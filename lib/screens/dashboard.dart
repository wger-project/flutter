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
import 'package:wger/helpers/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/dashboard/calendar.dart';
import 'package:wger/widgets/dashboard/widgets/measurements.dart';
import 'package:wger/widgets/dashboard/widgets/nutrition.dart';
import 'package:wger/widgets/dashboard/widgets/routines.dart';
import 'package:wger/widgets/dashboard/widgets/weight.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < MATERIAL_XS_BREAKPOINT;

    late final int crossAxisCount;
    if (width < MATERIAL_XS_BREAKPOINT) {
      crossAxisCount = 1;
    } else if (width < MATERIAL_MD_BREAKPOINT) {
      crossAxisCount = 2;
    } else if (width < MATERIAL_LG_BREAKPOINT) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    final items = [
      const DashboardRoutineWidget(),
      const DashboardNutritionWidget(),
      const DashboardWeightWidget(),
      const DashboardMeasurementWidget(),
      const DashboardCalendarWidget(),
    ];

    return Scaffold(
      appBar: MainAppBar(AppLocalizations.of(context).labelDashboard),
      extendBodyBehindAppBar: true,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MATERIAL_LG_BREAKPOINT.toDouble()),
          child: isMobile
              ? ListView.builder(
                  padding: getAppBarBodyPadding(
                    context,
                    left: 10,
                    right: 10,
                    bottom: 10,
                    extraTop: 10,
                  ),
                  itemBuilder: (context, index) => items[index],
                  itemCount: items.length,
                )
              : GridView.builder(
                  padding: getAppBarBodyPadding(
                    context,
                    left: 10,
                    right: 10,
                    bottom: 10,
                    extraTop: 10,
                  ),
                  itemBuilder: (context, index) => SingleChildScrollView(child: items[index]),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.7,
                  ),
                ),
        ),
      ),
    );
  }
}
