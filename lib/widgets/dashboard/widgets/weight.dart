/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/models/user/profile.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/user_profile_notifier.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/widgets/core/error.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/helpers.dart';
import 'package:wger/widgets/weight/forms.dart';

class DashboardWeightWidget extends ConsumerWidget {
  const DashboardWeightWidget();

  Widget _shell(BuildContext context, Widget body) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context).weight,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            leading: FaIcon(
              FontAwesomeIcons.weightScale,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
          ),
          body,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(weightEntryProvider);
    final profileAsync = ref.watch(userProfileProvider);

    // Composite loading / error / data resolution. We need both providers
    // ready before we can render the chart (entries → series, profile →
    // unit). Treating them independently with a nested .when() is what gave
    // us the eternal-spinner bug when fetchProfile() returned null — so we
    // funnel everything through a single decision tree here.
    if (entriesAsync.isLoading || profileAsync.isLoading) {
      return _shell(context, const BoxedProgressIndicator());
    }
    if (entriesAsync.hasError) {
      return _shell(
        context,
        StreamErrorIndicator(
          entriesAsync.error.toString(),
          stacktrace: entriesAsync.stackTrace,
        ),
      );
    }
    if (profileAsync.hasError) {
      return _shell(
        context,
        StreamErrorIndicator(
          profileAsync.error.toString(),
          stacktrace: profileAsync.stackTrace,
        ),
      );
    }
    final profile = profileAsync.value;
    if (profile == null) {
      // Loaded successfully but the API returned no profile — treat the same
      // way we treat a server error so the user isn't stuck on a spinner.
      return _shell(context, const StreamErrorIndicator('User profile is unavailable'));
    }

    return _shell(context, _buildContent(context, entriesAsync.value!, profile));
  }

  Widget _buildContent(BuildContext context, List<WeightEntry> entriesList, Profile profile) {
    if (entriesList.isEmpty) {
      return NothingFound(
        AppLocalizations.of(context).noWeightEntries,
        AppLocalizations.of(context).newEntry,
        WeightForm(),
      );
    }

    final (entriesAll, entries7dAvg) = sensibleRange(
      entriesList.map((e) => MeasurementChartEntry(e.weight, e.date)).toList(),
    );

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: MeasurementChartWidgetFl(
            entriesAll,
            weightUnit(profile.isMetric, context),
            avgs: entries7dAvg,
          ),
        ),
        if (entries7dAvg.isNotEmpty)
          MeasurementOverallChangeWidget(
            entries7dAvg.first,
            entries7dAvg.last,
            weightUnit(profile.isMetric, context),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: Text(
                        AppLocalizations.of(context).goToDetailPage,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(WeightScreen.routeName);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          FormScreen.routeName,
                          arguments: FormScreenArguments(
                            AppLocalizations.of(context).newEntry,
                            WeightForm(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
