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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/nutrition/nutritional_diary_detail.dart';

/// Arguments passed to the form screen
class NutritionalDiaryArguments {
  /// Nutritional plan
  final NutritionalPlan plan;

  /// Date to show data for
  final DateTime date;

  const NutritionalDiaryArguments(this.plan, this.date);
}

class NutritionalDiaryScreen extends StatelessWidget {
  const NutritionalDiaryScreen();
  static const routeName = '/nutritional-diary';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as NutritionalDiaryArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMd(Localizations.localeOf(context).languageCode).format(args.date)),
      ),
      body: Consumer<NutritionPlansProvider>(
        builder: (context, nutritionProvider, child) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: NutritionalDiaryDetailWidget(args.plan, args.date),
          ),
        ),
      ),
    );
  }
}
