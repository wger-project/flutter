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
import 'package:powersync/powersync.dart' as ps;
import 'package:wger/core/exceptions/no_such_entry_exception.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

part 'measurement_category.freezed.dart';

/// Namespace of the derived category ids.
///
/// MUST stay identical to CATEGORY_NAMESPACE on the server: a UUIDv5 hashes
/// namespace and name together, so a different constant here derives different
/// ids and the whole point of [deterministicCategoryId] collapses.
const categoryIdNamespace = '4c5ef6dd-97c9-5b18-9f8b-2a5c1ed70a2f';

/// The id the category of [metricType] has for the user [userId].
///
/// A typed category is the one place its metric lives, but the app creates it
/// while offline, so two devices would otherwise produce two rows for the same
/// metric. Deriving the id makes both arrive at the same one, and the server
/// acknowledges the second push as a no-op instead of rejecting it against its
/// uniqueness constraint.
String deterministicCategoryId(String userId, MetricType metricType) =>
    ps.uuid.v5(categoryIdNamespace, '$userId:${metricType.wireValue}');

/// Largest value the server's column can hold (numeric(8, 2)). It is what a
/// category without a metric type is bounded by, since nothing about a
/// free-form category says more.
const measurementSchemaMaxValue = 999999.99;

/// The range a measurement value of one metric type may be in.
///
/// [min] and [max] are what the API enforces, a value outside them comes back
/// as a 400. [softMin] and [softMax] are the everyday range, meant for warnings
/// and chart axes; nothing enforces them.
class MetricLimits {
  final num min;
  final num max;
  final num? softMin;
  final num? softMax;

  const MetricLimits(this.min, this.max, [this.softMin, this.softMax]);

  bool contains(num value) => value >= min && value <= max;
}

/// The wire values mirror the Django API field names (e.g., 'body_weight', 'heart_rate'),
enum MetricType {
  custom('custom'),
  bodyWeight('body_weight'),
  bodyFat('body_fat'),
  height('height'),
  bloodPressure('blood_pressure'),
  bloodPressureSystolic('blood_pressure_systolic'),
  bloodPressureDiastolic('blood_pressure_diastolic'),
  heartRate('heart_rate'),
  restingHeartRate('resting_heart_rate'),
  steps('steps'),
  distance('distance'),
  energy('energy'),
  sleep('sleep'),
  sleepTotal('sleep_total'),
  sleepLight('sleep_light'),
  sleepDeep('sleep_deep'),
  sleepRem('sleep_rem'),
  sleepAwake('sleep_awake');

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
    MetricType.steps ||
    MetricType.distance ||
    MetricType.energy ||
    MetricType.sleep ||
    MetricType.sleepTotal ||
    MetricType.sleepLight ||
    MetricType.sleepDeep ||
    MetricType.sleepRem ||
    MetricType.sleepAwake => true,
    _ => false,
  };

  /// `true` for metric types that are reserved for the official categories
  /// the server manages: users cannot create categories of these types.
  bool get isOfficial => switch (this) {
    MetricType.bodyWeight => true,
    _ => false,
  };

  /// The components of the multi-value metric types with the name their
  /// category is created under, in group order. Mirrors GROUP_COMPONENTS on
  /// the server, names included, so both sides create the same categories.
  static const _groupComponents = <MetricType, List<(MetricType, String)>>{
    MetricType.bloodPressure: [
      (MetricType.bloodPressureSystolic, 'Systolic'),
      (MetricType.bloodPressureDiastolic, 'Diastolic'),
    ],
    // The total is a component of its own because a group carries no
    // measurements. It is not the sum of the three stages below it: platforms
    // also report sleep without a stage breakdown, which counts towards the
    // total and has no stage category to live in
    MetricType.sleep: [
      (MetricType.sleepTotal, 'Total sleep'),
      (MetricType.sleepLight, 'Light sleep'),
      (MetricType.sleepDeep, 'Deep sleep'),
      (MetricType.sleepRem, 'REM sleep'),
      (MetricType.sleepAwake, 'Awake'),
    ],
  };

  /// `true` for a container type whose readings live in its components, e.g.
  /// blood pressure. A group category never carries entries of its own.
  bool get isGroup => _groupComponents.containsKey(this);

  /// `true` for one component of a group, e.g. systolic. Components exist
  /// only as children of their group and are not offered when creating a
  /// category.
  bool get isComponent =>
      _groupComponents.values.any((components) => components.any((c) => c.$1 == this));

  /// The components of this group, in group order; empty for every other type
  List<(MetricType, String)> get components => _groupComponents[this] ?? const [];

  /// `true` for the component that rolls its siblings up instead of being one
  /// part next to them. Total sleep already covers the stages beside it, so a
  /// stacked chart has to leave it out or it counts every night twice.
  bool get isGroupTotal => this == MetricType.sleepTotal;

  /// `true` for the types whose category id is derived instead of random,
  /// see [deterministicCategoryId]. Body weight is excluded: the server
  /// creates that category itself and the app looks it up by [isOfficial].
  bool get hasDeterministicId => this != MetricType.custom && this != MetricType.bodyWeight;

  /// `true` for metric types whose charts show nutrition plan periods for
  /// context. Custom categories are typically hand-kept body measurements
  /// (waist, biceps), so they qualify; the typed health metrics do not.
  bool get correlatesWithNutrition => switch (this) {
    MetricType.bodyWeight || MetricType.bodyFat || MetricType.custom => true,
    _ => false,
  };

  /// The range a value of this type may be in, in the unit the type is stored
  /// in. Body weight is the only one that comes in more than one unit, so it is
  /// the only one [unit] matters for.
  ///
  /// MUST stay identical to METRIC_LIMITS on the server: this is the copy the
  /// app validates against while offline, and a value the app accepts but the
  /// server does not is rejected permanently on push. Bounds may therefore be
  /// widened over releases, never tightened.
  MetricLimits limits([String? unit]) => switch (this) {
    MetricType.bodyWeight =>
      unit == 'lb' ? const MetricLimits(44, 770, 66, 661) : const MetricLimits(20, 350, 30, 300),
    MetricType.bodyFat => const MetricLimits(2, 60, 5, 50),
    MetricType.height => const MetricLimits(50, 250, 140, 210),
    MetricType.bloodPressureSystolic => const MetricLimits(50, 250, 90, 180),
    MetricType.bloodPressureDiastolic => const MetricLimits(30, 150, 50, 110),
    MetricType.heartRate => const MetricLimits(30, 250, 40, 200),
    MetricType.restingHeartRate => const MetricLimits(30, 120, 40, 100),
    // The cumulative types hold a whole day, and a rest day really is 0 steps
    MetricType.steps => const MetricLimits(0, 100000, 0, 30000),
    MetricType.distance => const MetricLimits(0, 500, 0, 30),
    MetricType.energy => const MetricLimits(0, 10000, 0, 2000),
    // Sleep is stored in minutes, so the upper bound is not a rarity but
    // arithmetic: a day has 1440 of them
    MetricType.sleepTotal => const MetricLimits(0, 1440, 180, 720),
    MetricType.sleepLight ||
    MetricType.sleepDeep ||
    MetricType.sleepRem ||
    MetricType.sleepAwake => const MetricLimits(0, 1440, 0, 720),
    // Free-form categories, and the group containers, which carry no
    // measurements at all
    _ => const MetricLimits(0, measurementSchemaMaxValue),
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
      MetricType.bloodPressureSystolic => l10n.metricBloodPressureSystolic,
      MetricType.bloodPressureDiastolic => l10n.metricBloodPressureDiastolic,
      MetricType.heartRate => l10n.metricHeartRate,
      MetricType.restingHeartRate => l10n.metricRestingHeartRate,
      MetricType.steps => l10n.metricSteps,
      MetricType.distance => l10n.metricDistance,
      MetricType.energy => l10n.metricEnergy,
      MetricType.sleep => l10n.metricSleep,
      MetricType.sleepTotal => l10n.metricSleepTotal,
      MetricType.sleepLight => l10n.metricSleepLight,
      MetricType.sleepDeep => l10n.metricSleepDeep,
      MetricType.sleepRem => l10n.metricSleepRem,
      MetricType.sleepAwake => l10n.metricSleepAwake,
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

  /// Multi-value groups (e.g. blood pressure): id of the parent category, one
  /// child per component. Max. one level of nesting; only leaf categories
  /// (no children) carry entries.
  @override
  final String? parentId;

  /// Position in the category list; for children, the position within the group
  @override
  final int order;

  /// Server-managed official category (max. one per metric type and user).
  /// The app never creates official categories itself.
  @override
  final bool isOfficial;

  /// Child categories (components) of this group. Populated by the repository
  /// for display, never persisted directly.
  @override
  final List<MeasurementCategory> children;

  MeasurementCategory({
    this.id,
    this.name = '',
    this.unit = '',
    this.entries = const [],
    this.metricType = MetricType.custom,
    this.parentId,
    this.order = 0,
    this.isOfficial = false,
    this.children = const [],
  });

  /// `true` for group parents (blood pressure etc.), which hold no entries of
  /// their own
  bool get isGroup => children.isNotEmpty;

  /// The user's body weight category. It has its own screens (weight feature)
  /// and is hidden from the general measurements UI.
  bool get isOfficialBodyWeight => isOfficial && metricType == MetricType.bodyWeight;

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
      parentId: Value(parentId),
      order: Value(order),
      isOfficial: Value(isOfficial),
    );
  }
}
