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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/nutrition/nutritional_diary_detail.dart';

/// Arguments passed to the form screen
class NutritionalDiaryArguments {
  /// Nutritional plan
  final String plan;

  /// Date to show data for
  final DateTime date;

  const NutritionalDiaryArguments(this.plan, this.date);
}

class NutritionalDiaryScreen extends StatefulWidget {
  const NutritionalDiaryScreen();
  static const routeName = '/nutritional-diary';

  @override
  State<NutritionalDiaryScreen> createState() => _NutritionalDiaryScreenState();
}

class _NutritionalDiaryScreenState extends State<NutritionalDiaryScreen> {
  NutritionalPlan? _plan;
  late DateTime date;
  StreamSubscription? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as NutritionalDiaryArguments;
    date = args.date;

    final stream =
        Provider.of<NutritionPlansProvider>(context, listen: false).watchNutritionPlan(args.plan);
    _subscription = stream.listen((plan) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        _plan = plan;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMd(Localizations.localeOf(context).languageCode).format(date)),
      ),
      body: Consumer<NutritionPlansProvider>(
        builder: (context, nutritionProvider, child) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _plan == null
                ? const Text('plan not found')
                : NutritionalDiaryDetailWidget(_plan!, date),
          ),
        ),
      ),
    );
  }
}
