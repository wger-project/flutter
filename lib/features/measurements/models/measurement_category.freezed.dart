// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MeasurementCategory {


/// Create a copy of MeasurementCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementCategoryCopyWith<MeasurementCategory> get copyWith => _$MeasurementCategoryCopyWithImpl<MeasurementCategory>(this as MeasurementCategory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MeasurementCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementCategory&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.metricType, _this.metricType) || other.metricType == _this.metricType)&&(identical(other.chartType, _this.chartType) || other.chartType == _this.chartType)&&const DeepCollectionEquality().equals(other.chartConfig, _this.chartConfig)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.isOfficial, _this.isOfficial) || other.isOfficial == _this.isOfficial)&&(identical(other.dynamicType, _this.dynamicType) || other.dynamicType == _this.dynamicType)&&const DeepCollectionEquality().equals(other.dynamicParams, _this.dynamicParams)&&const DeepCollectionEquality().equals(other.children, _this.children));
}


@override
int get hashCode {
  final _this = this as MeasurementCategory;
  return Object.hash(runtimeType,_this.id,_this.name,_this.unit,_this.metricType,_this.chartType,const DeepCollectionEquality().hash(_this.chartConfig),_this.parentId,_this.order,_this.isOfficial,_this.dynamicType,const DeepCollectionEquality().hash(_this.dynamicParams),const DeepCollectionEquality().hash(_this.children));
}

@override
String toString() {
  final _this = this as MeasurementCategory;
  return 'MeasurementCategory(id: ${_this.id}, name: ${_this.name}, unit: ${_this.unit}, metricType: ${_this.metricType}, chartType: ${_this.chartType}, chartConfig: ${_this.chartConfig}, parentId: ${_this.parentId}, order: ${_this.order}, isOfficial: ${_this.isOfficial}, dynamicType: ${_this.dynamicType}, dynamicParams: ${_this.dynamicParams}, children: ${_this.children})';
}


}

/// @nodoc
abstract mixin class $MeasurementCategoryCopyWith<$Res>  {
  factory $MeasurementCategoryCopyWith(MeasurementCategory value, $Res Function(MeasurementCategory) _then) = _$MeasurementCategoryCopyWithImpl;
@useResult
$Res call({
 String? id, String name, String unit, MetricType metricType, ChartType chartType, Map<String, dynamic>? chartConfig, String? parentId, int order, bool isOfficial, String dynamicType, Map<String, dynamic>? dynamicParams, List<MeasurementCategory> children
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? unit = null,Object? metricType = null,Object? chartType = null,Object? chartConfig = freezed,Object? parentId = freezed,Object? order = null,Object? isOfficial = null,Object? dynamicType = null,Object? dynamicParams = freezed,Object? children = null,}) {
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
as bool,dynamicType: null == dynamicType ? _self.dynamicType : dynamicType // ignore: cast_nullable_to_non_nullable
as String,dynamicParams: freezed == dynamicParams ? _self.dynamicParams : dynamicParams // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
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
