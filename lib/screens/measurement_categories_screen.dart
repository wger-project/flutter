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
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/widgets/core/time_range_tab_bar.dart';
import 'package:wger/widgets/measurements/categories.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/edit_modals.dart';

class MeasurementCategoriesScreen extends StatefulWidget {
  const MeasurementCategoriesScreen();

  static const routeName = '/measurement-categories';

  @override
  State<MeasurementCategoriesScreen> createState() => _MeasurementCategoriesScreenState();
}

class _MeasurementCategoriesScreenState extends State<MeasurementCategoriesScreen> {
  ChartTimeRange _selectedRange = ChartTimeRange.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).measurements)),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => showEditCategoryModal(context, null),
      ),
      body: WidescreenWrapper(
        child: Consumer<MeasurementProvider>(
          builder: (context, provider, child) => Column(
            children: [
              // Time range tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TimeRangeTabBar(
                  selectedRange: _selectedRange,
                  onRangeChanged: (range) => setState(() => _selectedRange = range),
                ),
              ),
              // Categories list
              Expanded(
                child: CategoriesList(timeRange: _selectedRange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
