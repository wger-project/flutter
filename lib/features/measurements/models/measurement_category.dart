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

import 'package:drift/drift.dart' hide JsonKey;
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wger/core/exceptions/no_such_entry_exception.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

part 'measurement_category.freezed.dart';

/// The wire values mirror the Django API field names (e.g., 'body_weight', 'heart_rate'),
enum MetricType {
  custom('custom'),
  bodyWeight('body_weight'),
  bodyFat('body_fat'),
  height('height'),
  bloodPressure('blood_pressure'),
  heartRate('heart_rate'),
  steps('steps'),
  distance('distance'),
  energy('energy'),
  sleep('sleep');

  final String wireValue;
  const MetricType(this.wireValue);

  /// Looks up an enum case by its Django wire value.
  ///
  /// Defaults to [MetricType.custom] if the value is not recognized.
  static MetricType fromWire(String value) => MetricType.values.firstWhere(
    (e) => e.wireValue == value,
    orElse: () => MetricType.custom,
  );

  /// `true` for metric types that should be aggregated per-day and shown as
  /// a bar/histogram instead of a raw-sample line chart.
  bool get isSummedPerDay => switch (this) {
    MetricType.steps || MetricType.distance || MetricType.energy || MetricType.sleep => true,
    _ => false,
  };
}

extension MeasurementMetricTypeL10n on MetricType {
  /// Localized human-readable label (e.g., "Body Weight", "Heart Rate").
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      MetricType.custom => l10n.metricCustom,
      MetricType.bodyWeight => l10n.metricBodyWeight,
      MetricType.bodyFat => l10n.metricBodyFat,
      MetricType.height => l10n.metricHeight,
      MetricType.bloodPressure => l10n.metricBloodPressure,
      MetricType.heartRate => l10n.metricHeartRate,
      MetricType.steps => l10n.metricSteps,
      MetricType.distance => l10n.metricDistance,
      MetricType.energy => l10n.metricEnergy,
      MetricType.sleep => l10n.metricSleep,
    };
  }
}

@freezed
class MeasurementCategory with _$MeasurementCategory {
  /// Inclusive upper bound for [name]
  static const maxNameChars = 100;

  /// Inclusive upper bound for [unit]
  static const maxUnitChars = 30;

  /// Client-generated UUID, is `null` only before the first persist
  @override
  final String? id;

  @override
  final String name;

  @override
  final String unit;

  @override
  final List<MeasurementEntry> entries;

  /// Drives the health-platform mapping (and, later, default unit/aggregation/
  /// chart). [MetricType.custom] for plain user-created categories.
  @override
  final MetricType metricType;

  @override
  final int order;

  MeasurementCategory({
    this.id,
    this.name = '',
    this.unit = '',
    this.entries = const [],
    this.metricType = MetricType.custom,
    this.order = 0,
  });

  MeasurementEntry findEntryById(String id) {
    return entries.firstWhere(
      (entry) => entry.id == id,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  // Boilerplate
  MeasurementCategoryTableCompanion toCompanion() {
    return MeasurementCategoryTableCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      name: Value(name),
      unit: Value(unit),
      metricType: Value(metricType),
      order: Value(order),
    );
  }
}
