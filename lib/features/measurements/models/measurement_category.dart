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
import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:powersync/powersync.dart' as ps;
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

part 'measurement_category.freezed.dart';

/// Namespace of the derived category ids.
///
/// MUST stay identical to CATEGORY_NAMESPACE on the server: a UUIDv5 hashes
/// namespace and name together, so a different constant here derives different
/// ids and the whole point of [deterministicCategoryId] collapses.
const _categoryIdNamespace = '4c5ef6dd-97c9-5b18-9f8b-2a5c1ed70a2f';

/// The id the category of [metricType] has for the user [userId].
///
/// A typed category is the one place its metric lives, but the app creates it
/// while offline, so two devices would otherwise produce two rows for the same
/// metric. Deriving the id makes both arrive at the same one, and the server
/// acknowledges the second push as a no-op instead of rejecting it against its
/// uniqueness constraint.
String deterministicCategoryId(String userId, MetricType metricType) =>
    ps.uuid.v5(_categoryIdNamespace, '$userId:${metricType.wireValue}');

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

/// Chart a category is drawn as.
///
/// The wire values mirror the server's ChartType, where the override is a
/// nullable column: [ChartType.auto] is that null, i.e. "derive the chart from
/// the metric type", which is what every category does unless the user picked
/// something else. Only the shapes that are a matter of taste are offered; a
/// floating bar (two components) and a stacked bar (a summed group) follow from
/// what the group is and are not choices.
enum ChartType {
  auto(null),
  line('line'),
  bar('bar'),
  heatmap('heatmap'),
  delta('delta'),
  distribution('distribution');

  final String? wireValue;
  const ChartType(this.wireValue);

  /// Looks up an enum case by its Django wire value.
  ///
  /// Defaults to [ChartType.auto] for an unknown value, which is what keeps a
  /// chart type added after this release from leaving the chart blank.
  static ChartType fromWire(String? value) => ChartType.values.firstWhere(
    (e) => e.wireValue == value,
    orElse: () => ChartType.auto,
  );
}

/// What both line settings take when the user turns their line off
const chartLineOff = 'none';

/// How closely the trend line follows the values, as the EMA period it maps to.
///
/// Stored as the character rather than the number, so the periods stay tunable
/// without touching what users configured.
enum TrendCharacter {
  /// No trend line at all, see [chartLineOff]
  none(chartLineOff, null),
  reactive('reactive', 5),
  balanced('balanced', 10),
  sluggish('sluggish', 20);

  final String wireValue;

  /// Null for [TrendCharacter.none], which draws nothing
  final int? emaPeriod;
  const TrendCharacter(this.wireValue, this.emaPeriod);

  /// Falls back to [TrendCharacter.balanced], which is the unconfigured chart.
  static TrendCharacter fromWire(Object? value) => TrendCharacter.values.firstWhere(
    (e) => e.wireValue == value,
    orElse: () => TrendCharacter.balanced,
  );
}

extension MeasurementTrendCharacterL10n on TrendCharacter {
  /// Localized human-readable label for the picker.
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      TrendCharacter.none => l10n.off,
      TrendCharacter.reactive => l10n.trendReactive,
      TrendCharacter.balanced => l10n.trendBalanced,
      TrendCharacter.sluggish => l10n.trendSluggish,
    };
  }
}

/// The taste-level chart settings of a category, resolved.
///
/// One object rather than one parameter per setting: the charts take it as a
/// whole, so a setting added here reaches them without touching a signature.
/// The defaults are what an unconfigured category is drawn with.
class ChartSettings {
  /// Windows the moving average may be computed over, in days.
  static const averageWindows = [7, 14, 30];

  /// Window the numbers derived from the average use when the line is off
  static const fallbackWindow = 7;

  final TrendCharacter trend;

  /// Window the moving average covers, in days, null when the user turned the
  /// average line off
  final int? averageWindow;

  const ChartSettings({
    this.trend = TrendCharacter.balanced,
    this.averageWindow = 7,
  });

  /// Reads the settings out of a stored `chart_config`.
  ///
  /// A value this release does not know, and a missing object, fall back to
  /// the default, the same rule an unfitting [ChartType] follows.
  factory ChartSettings.fromConfig(Map<String, dynamic>? config) {
    final window = config?['average_window'];

    return ChartSettings(
      trend: TrendCharacter.fromWire(config?['trend']),
      averageWindow: window == chartLineOff
          ? null
          : window is int && averageWindows.contains(window)
          ? window
          : averageWindows.first,
    );
  }
}

extension MeasurementChartTypeL10n on ChartType {
  /// Localized human-readable label for the picker.
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      ChartType.auto => l10n.chartTypeAuto,
      ChartType.line => l10n.chartTypeLine,
      ChartType.bar => l10n.chartTypeBar,
      ChartType.heatmap => l10n.chartTypeHeatmap,
      ChartType.delta => l10n.chartTypeDelta,
      ChartType.distribution => l10n.chartTypeDistribution,
    };
  }
}

/// The wire values mirror the Django API field names (e.g., 'body_weight', 'heart_rate'),
enum MetricType {
  custom('custom'),
  bodyWeight('body_weight'),
  bodyFat('body_fat'),
  leanBodyMass('lean_body_mass'),
  height('height'),
  bloodPressure('blood_pressure'),
  bloodPressureSystolic('blood_pressure_systolic'),
  bloodPressureDiastolic('blood_pressure_diastolic'),
  heartRate('heart_rate'),
  restingHeartRate('resting_heart_rate'),
  bloodOxygen('blood_oxygen'),
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

  /// The chart a category of this type is drawn as when the user picked none.
  ///
  /// Summed types are one value per day and are drawn as that day's bar,
  /// everything else is a series of samples and gets the line chart. A group
  /// has no default here: its chart follows from what its components are to
  /// each other, see buildGroupChart.
  ChartType get defaultChartType => isSummedPerDay ? ChartType.bar : ChartType.line;

  /// The chart types a category of this type may be drawn as, i.e. what the
  /// picker offers on top of [ChartType.auto].
  ///
  /// The alternatives fit every leaf type: the heatmap answers how regularly
  /// rather than how much, and is the only chart of the set where a missing
  /// day is visible instead of being spanned by a line; the delta chart
  /// answers which way it is going, which a line only implies; the
  /// distribution answers what is normal and what is an outlier, which no
  /// chart over time shows. A group is left out, its chart is structural
  /// rather than a preference.
  List<ChartType> get availableChartTypes => isGroup
      ? const []
      : [defaultChartType, ChartType.heatmap, ChartType.delta, ChartType.distribution];

  /// The chart a category of this type is drawn as, given what the user picked.
  ///
  /// A pick that does not fit the type falls back to the derived default
  /// instead of being refused: the server stores the string without judging it,
  /// so this is also what keeps a category configured on a newer client from
  /// showing nothing here.
  ChartType resolveChartType(ChartType picked) =>
      availableChartTypes.contains(picked) ? picked : defaultChartType;

  /// `true` for metric types that are reserved for the official categories
  /// the server manages: users cannot create categories of these types.
  bool get isOfficial => switch (this) {
    MetricType.bodyWeight => true,
    _ => false,
  };

  /// The components of the multi-value metric types, in group order. Mirrors
  /// GROUP_COMPONENTS on the server.
  static const _groupComponents = <MetricType, List<MetricType>>{
    MetricType.bloodPressure: [
      MetricType.bloodPressureSystolic,
      MetricType.bloodPressureDiastolic,
    ],
    // The total is a component of its own because a group carries no
    // measurements. It is not the sum of the three stages below it: platforms
    // also report sleep without a stage breakdown, which counts towards the
    // total and has no stage category to live in
    MetricType.sleep: [
      MetricType.sleepTotal,
      MetricType.sleepLight,
      MetricType.sleepDeep,
      MetricType.sleepRem,
      MetricType.sleepAwake,
    ],
  };

  /// `true` for a container type whose readings live in its components, e.g.
  /// blood pressure. A group category never carries entries of its own.
  bool get isGroup => _groupComponents.containsKey(this);

  /// `true` for one component of a group, e.g. systolic. Components exist
  /// only as children of their group and are not offered when creating a
  /// category.
  bool get isComponent => _groupComponents.values.any((c) => c.contains(this));

  /// The components of this group, in group order; empty for every other type
  List<MetricType> get components => _groupComponents[this] ?? const [];

  /// `true` for the types a user can pick when creating a category. Body
  /// weight is the server's, a component comes with its group, and a custom
  /// category is not picked but described.
  bool get isPickable => !isOfficial && !isComponent && this != MetricType.custom;

  /// Stable, non-localized name the category of this type is created under.
  ///
  /// Users see [localized] instead, this is what ends up in the database. Both
  /// the server and the health importer create their categories under the same
  /// names, so whoever gets there first, the row looks the same.
  String get canonicalName => switch (this) {
    MetricType.custom => '',
    MetricType.bodyWeight => 'Weight',
    MetricType.bodyFat => 'Body fat',
    MetricType.leanBodyMass => 'Lean body mass',
    MetricType.height => 'Height',
    MetricType.bloodPressure => 'Blood pressure',
    MetricType.bloodPressureSystolic => 'Systolic',
    MetricType.bloodPressureDiastolic => 'Diastolic',
    MetricType.heartRate => 'Heart rate',
    MetricType.restingHeartRate => 'Resting heart rate',
    MetricType.bloodOxygen => 'Blood oxygen',
    MetricType.steps => 'Steps',
    MetricType.distance => 'Distance',
    MetricType.energy => 'Energy',
    MetricType.sleep => 'Sleep',
    MetricType.sleepTotal => 'Total sleep',
    MetricType.sleepLight => 'Light sleep',
    MetricType.sleepDeep => 'Deep sleep',
    MetricType.sleepRem => 'REM sleep',
    MetricType.sleepAwake => 'Awake',
  };

  /// Unit the values of this type are stored in, empty for a free-form
  /// category, whose unit the user gives it.
  ///
  /// [limits] is keyed by type alone, so this is the unit those bounds mean.
  /// Body weight is the exception: it is also stored in lb, and its category
  /// follows the profile.
  String get defaultUnit => switch (this) {
    MetricType.custom => '',
    MetricType.bodyWeight || MetricType.leanBodyMass => 'kg',
    MetricType.bodyFat || MetricType.bloodOxygen => '%',
    MetricType.height => 'cm',
    MetricType.bloodPressure ||
    MetricType.bloodPressureSystolic ||
    MetricType.bloodPressureDiastolic => 'mmHg',
    MetricType.heartRate || MetricType.restingHeartRate => 'bpm',
    // A step count is a bare number, not a quantity in some unit
    MetricType.steps => '',
    MetricType.distance => 'km',
    MetricType.energy => 'kcal',
    MetricType.sleep ||
    MetricType.sleepTotal ||
    MetricType.sleepLight ||
    MetricType.sleepDeep ||
    MetricType.sleepRem ||
    MetricType.sleepAwake => durationUnit,
  };

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
    MetricType.bodyWeight ||
    MetricType.bodyFat ||
    MetricType.leanBodyMass ||
    MetricType.custom => true,
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
    // Always below the body weight it is part of, so the floor can sit lower
    MetricType.leanBodyMass => const MetricLimits(10, 250, 30, 90),
    MetricType.height => const MetricLimits(50, 250, 140, 210),
    MetricType.bloodPressureSystolic => const MetricLimits(50, 250, 90, 180),
    MetricType.bloodPressureDiastolic => const MetricLimits(30, 150, 50, 110),
    MetricType.heartRate => const MetricLimits(30, 250, 40, 200),
    MetricType.restingHeartRate => const MetricLimits(30, 120, 40, 100),
    // A saturation cannot exceed 100 %, and the floor is deliberately far
    // below what a pulse oximeter still displays
    MetricType.bloodOxygen => const MetricLimits(50, 100, 90, 100),
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

  /// Most decimals a value of this type is shown with at a glance: the tile
  /// hero, its chips and the group rows. Detail screens, forms and tooltips
  /// keep the stored value.
  ///
  /// Follows the resolution the metric is measured at, like [binWidth]: a
  /// pulse has no meaningful tenths, a body weight does, and a short walk
  /// needs its hundredths of a kilometre. Durations never ask, they are read
  /// as hours and minutes.
  int get displayDecimals => switch (this) {
    MetricType.bodyWeight ||
    MetricType.leanBodyMass ||
    MetricType.bodyFat ||
    MetricType.custom => 1,
    MetricType.distance => 2,
    _ => 0,
  };

  /// Width of one distribution-histogram bin, in the unit the type is stored
  /// in. Body weight is the only type that comes in more than one unit, so it
  /// is the only one [unit] matters for. Null for the types nothing is known
  /// about (free-form categories, and the groups, which are never drawn as a
  /// distribution): their width is derived from the data instead.
  ///
  /// Fixed per type rather than computed (Freedman-Diaconis and friends):
  /// a computed width changes with every range switch, which makes two looks
  /// at the same category incomparable, and it lands on edges like 0.73 kg
  /// where a maintained table lands on round ones.
  ///
  /// MUST stay identical to BIN_WIDTHS in react, or the same category bins
  /// differently per client.
  num? binWidth([String? unit]) => switch (this) {
    MetricType.bodyWeight => unit == 'lb' ? 1 : 0.5,
    MetricType.bodyFat => 0.5,
    MetricType.leanBodyMass => 0.5,
    MetricType.height => 1,
    MetricType.bloodPressureSystolic || MetricType.bloodPressureDiastolic => 5,
    MetricType.heartRate => 2,
    MetricType.restingHeartRate => 1,
    MetricType.bloodOxygen => 1,
    MetricType.steps => 1000,
    MetricType.distance => 1,
    MetricType.energy => 100,
    MetricType.sleepTotal => 30,
    MetricType.sleepLight ||
    MetricType.sleepDeep ||
    MetricType.sleepRem ||
    MetricType.sleepAwake => 15,
    _ => null,
  };
}

extension MeasurementMetricTypeL10n on MetricType {
  /// Localized human-readable label (e.g., "Body Weight", "Heart Rate").
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      MetricType.custom => l10n.metricCustom,
      MetricType.bodyWeight => l10n.weight,
      MetricType.bodyFat => l10n.metricBodyFat,
      MetricType.leanBodyMass => l10n.metricLeanBodyMass,
      MetricType.height => l10n.metricHeight,
      MetricType.bloodPressure => l10n.metricBloodPressure,
      MetricType.bloodPressureSystolic => l10n.metricBloodPressureSystolic,
      MetricType.bloodPressureDiastolic => l10n.metricBloodPressureDiastolic,
      MetricType.heartRate => l10n.metricHeartRate,
      MetricType.restingHeartRate => l10n.metricRestingHeartRate,
      MetricType.bloodOxygen => l10n.metricBloodOxygen,
      MetricType.steps => l10n.metricSteps,
      MetricType.distance => l10n.metricDistance,
      MetricType.energy => l10n.energy,
      MetricType.sleep => l10n.metricSleep,
      MetricType.sleepTotal => l10n.metricSleepTotal,
      MetricType.sleepLight => l10n.metricSleepLight,
      MetricType.sleepDeep => l10n.metricSleepDeep,
      MetricType.sleepRem => l10n.metricSleepRem,
      MetricType.sleepAwake => l10n.metricSleepAwake,
    };
  }
}

extension MeasurementCategoryDisplay on MeasurementCategory {
  /// Name to show the user.
  ///
  /// A typed category is created by the server or by the health importer and
  /// carries an English name ("Systolic", "Deep sleep"), while its metric type
  /// already has a translated label. Only a free-form category holds a name
  /// the user picked themselves.
  String displayName(BuildContext context) =>
      metricType == MetricType.custom ? name : metricType.localized(context);
}

/// The server's `dynamic_type` for a category the user fills themselves
const noDynamicType = 'NONE';

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

  /// Drives the health-platform mapping (and, later, default unit/aggregation/
  /// chart). [MetricType.custom] for plain user-created categories.
  @override
  final MetricType metricType;

  /// Chart the user picked for this category, [ChartType.auto] (the server's
  /// null) for the one derived from [metricType].
  @override
  final ChartType chartType;

  /// Taste-level chart settings, read through [chartSettings].
  ///
  /// Null for a category that configured none, which is also what a row synced
  /// before the column existed reads. Keys this release does not know are
  /// kept: another client may have written them, and a write from here
  /// replaces the whole object.
  @override
  final Map<String, dynamic>? chartConfig;

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

  /// What the server calculates the entries of this category from,
  /// [noDynamicType] for one the user fills themselves. Deliberately the raw
  /// string: a type added after this release still has to read as calculated,
  /// see [isCalculated].
  @override
  final String dynamicType;

  /// Configuration of the calculation, its keys depend on [dynamicType]. Null
  /// for a category the server does not calculate.
  @override
  final Map<String, dynamic>? dynamicParams;

  /// Child categories (components) of this group. Populated by the repository
  /// for display, never persisted directly.
  @override
  final List<MeasurementCategory> children;

  MeasurementCategory({
    this.id,
    this.name = '',
    this.unit = '',
    this.metricType = MetricType.custom,
    this.chartType = ChartType.auto,
    this.chartConfig,
    this.parentId,
    this.order = 0,
    this.isOfficial = false,
    this.dynamicType = noDynamicType,
    this.dynamicParams,
    this.children = const [],
  });

  /// The typed category of [metricType] for [userId]: the deterministic id
  /// the app and the server both derive, with the type's canonical name and
  /// unit. [parentId] and [order] place a component in its group.
  MeasurementCategory.forMetricType(
    String userId,
    MetricType metricType, {
    String? parentId,
    int order = 0,
  }) : this(
         id: deterministicCategoryId(userId, metricType),
         name: metricType.canonicalName,
         unit: metricType.defaultUnit,
         metricType: metricType,
         parentId: parentId,
         order: order,
       );

  /// Maps a row of the local database. Rows synced before the 2.7 schema
  /// change lack the new columns and read as NULL; they fall back to the
  /// defaults until the full re-sync replaces them.
  MeasurementCategory.fromDb({
    required String id,
    required String name,
    required String unit,
    required ChartType chartType,
    MetricType? metricType,
    Map<String, dynamic>? chartConfig,
    String? parentId,
    int? order,
    bool? isOfficial,
    String? dynamicType,
    Map<String, dynamic>? dynamicParams,
  }) : this(
         id: id,
         name: name,
         unit: unit,
         metricType: metricType ?? MetricType.custom,
         chartType: chartType,
         chartConfig: chartConfig,
         parentId: parentId,
         order: order ?? 0,
         isOfficial: isOfficial ?? false,
         dynamicType: dynamicType ?? noDynamicType,
         dynamicParams: dynamicParams,
       );

  /// How this category is drawn, beyond the chart type: see [ChartSettings].
  ChartSettings get chartSettings => ChartSettings.fromConfig(chartConfig);

  /// A copy with one chart setting changed, keeping the keys this release does
  /// not know: a write replaces the whole object.
  MeasurementCategory withChartSetting(String key, Object value) =>
      copyWith(chartConfig: {...?chartConfig, key: value});

  /// `true` for group parents (blood pressure etc.), which hold no entries of
  /// their own. Answers for this row: a group whose components have not synced
  /// yet has none, unlike the structural [MetricType.isGroup].
  bool get hasChildren => children.isNotEmpty;

  /// The user's body weight category. It has its own screens (weight feature)
  /// and is hidden from the general measurements UI.
  bool get isOfficialBodyWeight => isOfficial && metricType == MetricType.bodyWeight;

  /// Whether the server maintains the entries of this category. They are
  /// read-only, and adding one by hand is refused.
  bool get isCalculated => dynamicType != noDynamicType;

  /// Whether the category form has anything to offer for this category.
  ///
  /// A free-form one owns its name and unit, a typed leaf can still be drawn
  /// differently, and a group has neither: its name and unit come from the
  /// metric type and its chart from what its components are to each other.
  bool get isEditable =>
      metricType == MetricType.custom ||
      (!hasChildren && metricType.availableChartTypes.isNotEmpty);

  // Boilerplate
  MeasurementCategoryTableCompanion toCompanion() {
    return MeasurementCategoryTableCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      name: Value(name),
      unit: Value(unit),
      metricType: Value(metricType),
      chartType: Value(chartType),
      chartConfig: Value(chartConfig),
      parentId: Value(parentId),
      order: Value(order),
      isOfficial: Value(isOfficial),
      dynamicType: Value(dynamicType),
      dynamicParams: Value(dynamicParams),
    );
  }
}
