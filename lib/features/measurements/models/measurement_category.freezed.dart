// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MeasurementCategory {

/// Client-generated UUID, is `null` only before the first persist
 String? get id; String get name; String get unit;/// Drives the health-platform mapping (and, later, default unit/aggregation/
/// chart). [MetricType.custom] for plain user-created categories.
 MetricType get metricType;/// Chart the user picked for this category, [ChartType.auto] (the server's
/// null) for the one derived from [metricType].
 ChartType get chartType;/// Taste-level chart settings, read through [chartSettings].
///
/// Null for a category that configured none, which is also what a row synced
/// before the column existed reads. Keys this release does not know are
/// kept: another client may have written them, and a write from here
/// replaces the whole object.
 Map<String, dynamic>? get chartConfig;/// Multi-value groups (e.g. blood pressure): id of the parent category, one
/// child per component. Max. one level of nesting; only leaf categories
/// (no children) carry entries.
 String? get parentId;/// Position in the category list; for children, the position within the group
 int get order;/// Server-managed official category (max. one per metric type and user).
/// The app never creates official categories itself.
 bool get isOfficial;/// Child categories (components) of this group. Populated by the repository
/// for display, never persisted directly.
 List<MeasurementCategory> get children;
/// Create a copy of MeasurementCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementCategoryCopyWith<MeasurementCategory> get copyWith => _$MeasurementCategoryCopyWithImpl<MeasurementCategory>(this as MeasurementCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.chartType, chartType) || other.chartType == chartType)&&const DeepCollectionEquality().equals(other.chartConfig, chartConfig)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.order, order) || other.order == order)&&(identical(other.isOfficial, isOfficial) || other.isOfficial == isOfficial)&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,unit,metricType,chartType,const DeepCollectionEquality().hash(chartConfig),parentId,order,isOfficial,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'MeasurementCategory(id: $id, name: $name, unit: $unit, metricType: $metricType, chartType: $chartType, chartConfig: $chartConfig, parentId: $parentId, order: $order, isOfficial: $isOfficial, children: $children)';
}


}

/// @nodoc
abstract mixin class $MeasurementCategoryCopyWith<$Res>  {
  factory $MeasurementCategoryCopyWith(MeasurementCategory value, $Res Function(MeasurementCategory) _then) = _$MeasurementCategoryCopyWithImpl;
@useResult
$Res call({
 String? id, String name, String unit, MetricType metricType, ChartType chartType, Map<String, dynamic>? chartConfig, String? parentId, int order, bool isOfficial, List<MeasurementCategory> children
});




}
/// @nodoc
class _$MeasurementCategoryCopyWithImpl<$Res>
    implements $MeasurementCategoryCopyWith<$Res> {
  _$MeasurementCategoryCopyWithImpl(this._self, this._then);

  final MeasurementCategory _self;
  final $Res Function(MeasurementCategory) _then;

/// Create a copy of MeasurementCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? unit = null,Object? metricType = null,Object? chartType = null,Object? chartConfig = freezed,Object? parentId = freezed,Object? order = null,Object? isOfficial = null,Object? children = null,}) {
  return _then(MeasurementCategory(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as MetricType,chartType: null == chartType ? _self.chartType : chartType // ignore: cast_nullable_to_non_nullable
as ChartType,chartConfig: freezed == chartConfig ? _self.chartConfig : chartConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isOfficial: null == isOfficial ? _self.isOfficial : isOfficial // ignore: cast_nullable_to_non_nullable
as bool,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<MeasurementCategory>,
  ));
}

}


/// Adds pattern-matching-related methods to [MeasurementCategory].
extension MeasurementCategoryPatterns on MeasurementCategory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
