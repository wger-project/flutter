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

    return Consumer<UserProvider>(
      builder: (context, user, _) {
        return Column(
          children: [
            SwitchListTile(
              title: Text(i18n.routines),
              value: user.isDashboardWidgetVisible(DashboardWidget.routines),
              onChanged: (v) => user.setDashboardWidgetVisible(DashboardWidget.routines, v),
            ),
            SwitchListTile(
              title: Text(i18n.weight),
              value: user.isDashboardWidgetVisible(DashboardWidget.weight),
              onChanged: (v) => user.setDashboardWidgetVisible(DashboardWidget.weight, v),
            ),
            SwitchListTile(
              title: Text(i18n.measurements),
              value: user.isDashboardWidgetVisible(DashboardWidget.measurements),
              onChanged: (v) => user.setDashboardWidgetVisible(DashboardWidget.measurements, v),
            ),
            SwitchListTile(
              title: Text(i18n.calendar),
              value: user.isDashboardWidgetVisible(DashboardWidget.calendar),
              onChanged: (v) => user.setDashboardWidgetVisible(DashboardWidget.calendar, v),
            ),
            SwitchListTile(
              title: Text(i18n.nutritionalPlans),
              value: user.isDashboardWidgetVisible(DashboardWidget.nutrition),
              onChanged: (v) => user.setDashboardWidgetVisible(DashboardWidget.nutrition, v),
            ),
          ],
        );
      },
    );
  }
}
