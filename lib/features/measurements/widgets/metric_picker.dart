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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/form_screen.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/forms/category.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Asks what to track and creates the category for it.
///
/// A known metric needs no form: its name, unit and chart follow from the
/// metric type, and the type is what the health import and the value limits
/// hang off. It also cannot be changed afterwards, so it is picked here rather
/// than being one field among others.
Future<void> showMetricPicker(BuildContext context) => showModalBottomSheet(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  // The list is long enough to fill the screen, which leaves nothing to tap
  // next to the sheet and makes it dismissable by dragging alone
  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
  builder: (context) => const MetricPickerSheet(),
);

class MetricPickerSheet extends ConsumerWidget {
  const MetricPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    // Only the types matter here, so this reads the categories without their
    // entries rather than every reading of a synced account
    final categories = ref.watch(measurementCategoriesProvider).value ?? const [];
    final taken = categories.map((c) => c.metricType).toSet();

    // Alphabetical by the name the user reads: the order they are declared in
    // means nothing to them, and the list is long enough to look through
    final pickable = [
      for (final metricType in MetricType.values)
        if (metricType.isPickable) metricType,
    ]..sort((a, b) => a.localized(context).compareTo(b.localized(context)));

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              i18n.whatToTrack,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // First, and above the divider: it is the one that fits whatever
          // the user wants to track, the rest are a catalogue of known ones
          ListTile(
            leading: const Icon(Icons.straighten),
            title: Text(i18n.customMeasurement),
            subtitle: Text(i18n.measurementCategoriesHelpText),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                FormScreen.routeName,
                arguments: FormScreenArguments(
                  i18n.newEntry,
                  const MeasurementCategoryForm(),
                  hasListView: true,
                ),
              );
            },
          ),
          const Divider(),
          for (final metricType in pickable)
            ListTile(
              enabled: !taken.contains(metricType),
              title: Text(metricType.localized(context)),
              // A metric without a unit gets no subtitle rather than an empty
              // one, which would still take up its line
              subtitle: switch ((taken.contains(metricType), metricType.defaultUnit)) {
                (true, _) => Text(i18n.metricAlreadyTracked),
                (false, '') => null,
                (false, final unit) => Text(unit),
              },
              onTap: () async {
                final id = await ref
                    .read(measurementProvider.notifier)
                    .addCategory(
                      MeasurementCategory(
                        name: metricType.canonicalName,
                        unit: metricType.defaultUnit,
                        metricType: metricType,
                      ),
                    );
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop();
                // Straight to the new category: the overview is long enough
                // that a card appearing somewhere in it does not read as
                // "something happened"
                if (id != null) {
                  Navigator.pushNamed(
                    context,
                    MeasurementEntriesScreen.routeName,
                    arguments: id,
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
