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
import 'package:wger/core/form_screen.dart';
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/core/widgets/app_bar.dart';
import 'package:wger/features/measurements/widgets/chart_range_selector.dart';
import 'package:wger/features/weight/providers/body_weight_provider.dart';
import 'package:wger/features/weight/widgets/forms.dart';
import 'package:wger/features/weight/widgets/weight_overview.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen();

  static const routeName = '/weight';

  @override
  ConsumerState<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  /// Owned here rather than in the overview below, because it bounds the query
  /// that reads the entries, not only the span the chart draws
  ChartRange _range = ChartRange.last3Months;

  @override
  Widget build(BuildContext context) {
    // New entries need the official category, which the server creates and the
    // initial sync delivers; hide the FAB until it is there.
    final category = ref.watch(bodyWeightCategorySinceProvider(_range.readCutoff)).value;

    return Scaffold(
      appBar: EmptyAppBar(AppLocalizations.of(context).weight),
      floatingActionButton: category == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context).newEntry,
                    WeightForm(category),
                  ),
                );
              },
            ),
      body: WidescreenWrapper(
        child: SingleChildScrollView(
          child: WeightOverview(
            range: _range,
            onRangeChanged: (range) => setState(() => _range = range),
          ),
        ),
      ),
    );
  }
}
