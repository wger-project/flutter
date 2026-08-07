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
import 'package:wger/core/widgets/progress_indicator.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/body_weight_provider.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/measurements/widgets/entries.dart';
import 'package:wger/features/measurements/widgets/weight_form.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Body weight, presented as its own tab.
///
/// The data is the official body weight category, so this is [EntriesList]
/// over it. What the category alone does not say is presentation: the values
/// are shown in the profile unit (entries can be stored in kg or lb), the
/// title is translated rather than taken from the server-created category, and
/// the entry form is the one with the quick steppers.
class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen();

  static const routeName = '/weight';

  @override
  ConsumerState<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  /// Owned here rather than in the list below, because the selector and the
  /// charts it drives sit in different widgets
  ChartRange _range = ChartRange.last3Months;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    // New entries need the official category, which the server creates and the
    // initial sync delivers; hide the FAB until it is there.
    final category = ref.watch(bodyWeightCategoryOnlyProvider).value;
    // The profile decides the display unit, so nothing can be drawn without it
    final profile = ref.watch(userProfileProvider).value;

    return Scaffold(
      appBar: EmptyAppBar(i18n.weight),
      floatingActionButton: category == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    i18n.newEntry,
                    WeightForm(category),
                  ),
                );
              },
            ),
      body: WidescreenWrapper(
        child: SingleChildScrollView(
          child: category == null || profile == null
              ? const BoxedProgressIndicator()
              : EntriesList(
                  category,
                  range: _range,
                  onRangeChanged: (range) => setState(() => _range = range),
                  title: i18n.weight,
                  displayUnit: weightDisplayUnit(profile.isMetric),
                  displayUnitLabel: weightUnit(profile.isMetric, context),
                  editFormBuilder: (entry) => WeightForm(category, entry),
                ),
        ),
      ),
    );
  }
}
