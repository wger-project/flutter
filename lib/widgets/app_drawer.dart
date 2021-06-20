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
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/core/about.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('wger'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            //dense: true,
            leading: Icon(Icons.exit_to_app),
            title: Text(AppLocalizations.of(context).logout),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Provider.of<WorkoutPlansProvider>(context, listen: false).clear();
              Provider.of<NutritionPlansProvider>(context, listen: false)
                  .clear();
              Provider.of<BodyWeightProvider>(context, listen: false).clear();
              Provider.of<GalleryProvider>(context, listen: false).clear();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          WgerAboutListTile()
        ],
      ),
    );
  }
}
