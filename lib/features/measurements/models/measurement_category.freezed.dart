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
 String? get id; String get name; String get unit; List<MeasurementEntry> get entries;/// Drives the health-platform mapping (and, later, default unit/aggregation/
/// chart). [MetricType.custom] for plain user-created categories.
 MetricType get metricType;/// Multi-value groups (e.g. blood pressure): id of the parent category, one
/// child per component. Max. one level of nesting; only leaf categories
/// (no children) carry entries.
 String? get parentId;/// Position in the category list; for children, the position within the group
 int get order;/// Child categories (components) of this group. Populated by the repository
/// for display, never persisted directly.
 List<MeasurementCategory> get children;
/// Create a copy of MeasurementCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementCategoryCopyWith<MeasurementCategory> get copyWith => _$MeasurementCategoryCopyWithImpl<MeasurementCategory>(this as MeasurementCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other.children, children));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,unit,const DeepCollectionEquality().hash(entries),metricType,parentId,order,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'MeasurementCategory(id: $id, name: $name, unit: $unit, entries: $entries, metricType: $metricType, parentId: $parentId, order: $order, children: $children)';
}


}

/// @nodoc
abstract mixin class $MeasurementCategoryCopyWith<$Res>  {
  factory $MeasurementCategoryCopyWith(MeasurementCategory value, $Res Function(MeasurementCategory) _then) = _$MeasurementCategoryCopyWithImpl;
@useResult
$Res call({
 String? id, String name, String unit, List<MeasurementEntry> entries, MetricType metricType, String? parentId, int order, List<MeasurementCategory> children
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? unit = null,Object? entries = null,Object? metricType = null,Object? parentId = freezed,Object? order = null,Object? children = null,}) {
  return _then(MeasurementCategory(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<MeasurementEntry>,metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as MetricType,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
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
