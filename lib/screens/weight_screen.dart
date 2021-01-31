/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/weight/entries_list.dart';
import 'package:wger/widgets/weight/forms.dart';

class WeightScreen extends StatefulWidget {
  static const routeName = '/weight';

  @override
  _WeightScreenState createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  WeightEntry weightEntry = WeightEntry();

  Widget getAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).weight),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          showFormBottomSheet(
            context,
            AppLocalizations.of(context).newEntry,
            WeightForm(),
          );
        },
      ),
      body: Consumer<BodyWeight>(
        builder: (context, weightProvider, child) => WeightEntriesList(weightProvider),
      ),
    );
  }

  showWeightEntrySheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return Container(margin: EdgeInsets.all(20), child: WeightForm());
      },
    );
  }
}
