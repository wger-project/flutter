/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/user.dart';

class SettingsDashboardVisibility extends StatelessWidget {
  const SettingsDashboardVisibility({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    String getTitle(DashboardWidget w) {
      switch (w) {
        case DashboardWidget.routines:
          return i18n.routines;
        case DashboardWidget.weight:
          return i18n.weight;
        case DashboardWidget.measurements:
          return i18n.measurements;
        case DashboardWidget.calendar:
          return i18n.calendar;
        case DashboardWidget.nutrition:
          return i18n.nutritionalPlans;
        case DashboardWidget.trophies:
          return i18n.trophies;
      }
    }

    return Consumer<UserProvider>(
      builder: (context, user, _) {
        return ReorderableListView(
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: user.setDashboardOrder,
          children: user.dashboardOrder.asMap().entries.map((entry) {
            final index = entry.key;
            final w = entry.value;

            return ListTile(
              key: ValueKey(w),
              title: Text(getTitle(w)),
              leading: IconButton(
                icon: user.isDashboardWidgetVisible(w)
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off, color: Colors.grey),
                onPressed: () => user.setDashboardWidgetVisible(
                  w,
                  !user.isDashboardWidgetVisible(w),
                ),
              ),
              trailing: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
