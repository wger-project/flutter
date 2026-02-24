/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:wger/helpers/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/dashboard/calendar.dart';
import 'package:wger/widgets/dashboard/widgets/measurements.dart';
import 'package:wger/widgets/dashboard/widgets/nutrition.dart';
import 'package:wger/widgets/dashboard/widgets/routines.dart';
import 'package:wger/widgets/dashboard/widgets/trophies.dart';
import 'package:wger/widgets/dashboard/widgets/weight.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  Widget _getDashboardWidget(DashboardWidget widget) {
    switch (widget) {
      case DashboardWidget.routines:
        return const DashboardRoutineWidget();
      case DashboardWidget.weight:
        return const DashboardWeightWidget();
      case DashboardWidget.measurements:
        return const DashboardMeasurementWidget();
      case DashboardWidget.calendar:
        return const DashboardCalendarWidget();
      case DashboardWidget.nutrition:
        return const DashboardNutritionWidget();
      case DashboardWidget.trophies:
        return const DashboardTrophiesWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < MATERIAL_XS_BREAKPOINT;
    final user = Provider.of<UserProvider>(context);

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

    return Scaffold(
      appBar: MainAppBar(AppLocalizations.of(context).labelDashboard),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: MATERIAL_LG_BREAKPOINT),
          child: isMobile
              ? ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) =>
                      _getDashboardWidget(user.dashboardWidgets[index]),
                  itemCount: user.dashboardWidgets.length,
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) => SingleChildScrollView(
                    child: _getDashboardWidget(user.dashboardWidgets[index]),
                  ),
                  itemCount: user.dashboardWidgets.length,
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
