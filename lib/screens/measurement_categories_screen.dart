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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/measurements/categories.dart';
import 'package:wger/widgets/measurements/forms.dart';

class MeasurementCategoriesScreen extends StatelessWidget {
  const MeasurementCategoriesScreen();
  static const routeName = '/measurement-categories';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).measurements)),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          Navigator.pushNamed(
            context,
            FormScreen.routeName,
            arguments: FormScreenArguments(
              AppLocalizations.of(context).newEntry,
              MeasurementCategoryForm(),
            ),
          );
        },
      ),
      body: Consumer<MeasurementProvider>(
        builder: (context, provider, child) => const CategoriesList(),
      ),
    );
  }
}
