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
import 'package:logging/logging.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/core/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/core/widgets/error.dart';
import 'package:wger/core/widgets/progress_indicator.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/body_weight_provider.dart';
import 'package:wger/features/measurements/screens/weight_screen.dart';
import 'package:wger/features/measurements/widgets/categories_card.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/features/measurements/widgets/weight_form.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class DashboardWeightWidget extends ConsumerWidget {
  static final _logger = Logger('DashboardWeightWidget');

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

  /// The error state of one of the providers the card resolves, logged the way
  /// `AsyncValueWidget` logs the cards that only resolve a single one.
  Widget _errorShell(BuildContext context, AsyncValue<Object?> value) {
    _logger.warning('Async error in DashboardWeightWidget', value.error, value.stackTrace);

    return _shell(context, StreamErrorIndicator(value.error!, stacktrace: value.stackTrace));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(bodyWeightCategoryOnlyProvider);
    final profileAsync = ref.watch(userProfileProvider);

    // Composite loading / error / data resolution. We need both providers
    // ready before we can render the chart (category → series, profile →
    // unit). Treating them independently with a nested .when() is what gave
    // us the eternal-spinner bug when fetchProfile() returned null, so we
    // funnel everything through a single decision tree here.
    if (categoryAsync.isLoading || profileAsync.isLoading) {
      return _shell(context, const BoxedProgressIndicator());
    }
    if (categoryAsync.hasError) {
      return _errorShell(context, categoryAsync);
    }
    if (profileAsync.hasError) {
      return _errorShell(context, profileAsync);
    }
    final profile = profileAsync.value;
    if (profile == null) {
      // The profile stream can legitimately emit null right after login,
      // before the local `user_profile` PowerSync bucket has finished its
      // first sync (see NutritionalPlansList, which treats this the same
      // way). Keep showing the spinner instead of a permanent-looking error;
      // the widget rebuilds once the row lands.
      return _shell(context, const BoxedProgressIndicator());
    }
    final category = categoryAsync.value;
    if (category == null) {
      // The official body weight category is created by the server; it is
      // missing only while the initial sync is still running.
      return _shell(context, const BoxedProgressIndicator());
    }

    // The same watch the card below runs (one underlying stream), resolved
    // here as well so the empty state and errors render dashboard-style
    final pointsAsync = chartPointsFor(
      ref,
      category,
      ChartRange.all,
      targetUnit: weightDisplayUnit(profile.isMetric),
    );
    if (pointsAsync.hasError) {
      return _errorShell(context, pointsAsync);
    }
    final points = pointsAsync.value;
    if (points == null) {
      return _shell(context, const BoxedProgressIndicator());
    }
    if (points.isEmpty) {
      return _shell(
        context,
        NothingFound(
          AppLocalizations.of(context).noWeightEntries,
          AppLocalizations.of(context).newEntry,
          WeightForm(category),
        ),
      );
    }

    // The card the body tab shows, over the full history; the shell above
    // already titles the widget
    return _shell(
      context,
      CategoriesCard(
        category,
        elevation: 0,
        range: ChartRange.all,
        title: '',
        displayUnit: weightDisplayUnit(profile.isMetric),
        displayUnitLabel: weightUnit(profile.isMetric, context),
        newEntryForm: WeightForm(category),
        onShowDetails: () => Navigator.pushNamed(context, WeightScreen.routeName),
      ),
    );
  }
}
