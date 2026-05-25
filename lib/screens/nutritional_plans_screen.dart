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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/ingredients_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/nutritional_plans_list.dart';

enum _NutritionalPlansAppBarOptions {
  list,
}

class NutritionalPlansScreen extends ConsumerWidget {
  const NutritionalPlansScreen();

  static const routeName = '/nutrition';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.nutritionalPlans),
        actions: [
          PopupMenuButton<_NutritionalPlansAppBarOptions>(
            itemBuilder: (context) {
              return [
                PopupMenuItem<_NutritionalPlansAppBarOptions>(
                  value: _NutritionalPlansAppBarOptions.list,
                  child: Text(i18n.ingredients),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case _NutritionalPlansAppBarOptions.list:
                  Navigator.of(context).pushNamed(IngredientsScreen.routeName);
                  break;
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            FormScreen.routeName,
            arguments: FormScreenArguments(
              AppLocalizations.of(context).newNutritionalPlan,
              hasListView: true,
              PlanForm(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: const WidescreenWrapper(child: NutritionalPlansList()),
    );
  }
}
