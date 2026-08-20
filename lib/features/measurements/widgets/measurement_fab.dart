/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/widgets/forms/entry.dart';
import 'package:wger/features/measurements/widgets/forms/group_entry.dart';
import 'package:wger/features/measurements/widgets/metric_picker.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// The overview's add button: opens a menu with one action per hand-kept
/// category (straight into its entry form) plus the metric picker for
/// starting something new.
///
/// A [MenuAnchor] rather than a hand-rolled expanding FAB: dismissal,
/// positioning and focus come with it. Flutter's M3 menu is also as close as
/// the stable SDK gets to the M3 FAB menu for now.
class MeasurementsFab extends ConsumerWidget {
  const MeasurementsFab({super.key});

  Future<void> _addEntry(BuildContext context, MeasurementCategory category) async {
    await Navigator.pushNamed(
      context,
      FormScreen.routeName,
      arguments: FormScreenArguments(
        AppLocalizations.of(context).newEntry,
        category.hasChildren
            ? GroupMeasurementEntryForm(category)
            : MeasurementEntryForm(category.id!),
      ),
    );
  }

  /// Whether [category] is fed by hand rather than by the health sync or by
  /// the server, judged by who wrote its newest reading. A category without
  /// entries counts as hand-kept: it was just created and logging is what it
  /// is waiting for. A calculated one never does, also while it is still
  /// empty, since the server refuses entries there.
  bool _isHandKept(MeasurementCategory category, Map<String, MeasurementEntry> latest) {
    if (category.isCalculated) {
      return false;
    }

    final newest = category.hasChildren
        ? category.children.map((c) => latest[c.id])
        : [latest[category.id]];

    return newest.nonNulls.every((entry) => entry.source == measurementSourceUser);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(measurementCategoriesProvider).value ?? const [];
    final latest = ref.watch(latestMeasurementEntriesProvider).value ?? const {};
    final handKept = [
      for (final category in categories)
        if (category.parentId == null &&
            !category.isOfficialBodyWeight &&
            _isHandKept(category, latest))
          category,
    ];

    return MenuAnchor(
      menuChildren: [
        for (final category in handKept)
          MenuItemButton(
            leadingIcon: const Icon(Icons.add),
            onPressed: () => _addEntry(context, category),
            child: Text(category.displayName(context)),
          ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.playlist_add),
          onPressed: () => showMetricPicker(context),
          child: Text(AppLocalizations.of(context).trackNewMetric),
        ),
      ],
      builder: (context, controller, child) => FloatingActionButton(
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        child: AnimatedRotation(
          turns: controller.isOpen ? 0.125 : 0,
          duration: const Duration(milliseconds: 200),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
