// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_sync.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HealthSyncState {

 bool get isEnabled; bool get isSyncing; int get lastSyncCount;
/// Create a copy of HealthSyncState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthSyncStateCopyWith<HealthSyncState> get copyWith => _$HealthSyncStateCopyWithImpl<HealthSyncState>(this as HealthSyncState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthSyncState&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.isSyncing, isSyncing) || other.isSyncing == isSyncing)&&(identical(other.lastSyncCount, lastSyncCount) || other.lastSyncCount == lastSyncCount));
}


@override
int get hashCode => Object.hash(runtimeType,isEnabled,isSyncing,lastSyncCount);

@override
String toString() {
  return 'HealthSyncState(isEnabled: $isEnabled, isSyncing: $isSyncing, lastSyncCount: $lastSyncCount)';
}


}

/// @nodoc
abstract mixin class $HealthSyncStateCopyWith<$Res>  {
  factory $HealthSyncStateCopyWith(HealthSyncState value, $Res Function(HealthSyncState) _then) = _$HealthSyncStateCopyWithImpl;
@useResult
$Res call({
 bool isEnabled, bool isSyncing, int lastSyncCount
});




}
/// @nodoc
class _$HealthSyncStateCopyWithImpl<$Res>
    implements $HealthSyncStateCopyWith<$Res> {
  _$HealthSyncStateCopyWithImpl(this._self, this._then);

  final HealthSyncState _self;
  final $Res Function(HealthSyncState) _then;

/// Create a copy of HealthSyncState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isEnabled = null,Object? isSyncing = null,Object? lastSyncCount = null,}) {
  return _then(_self.copyWith(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,isSyncing: null == isSyncing ? _self.isSyncing : isSyncing // ignore: cast_nullable_to_non_nullable
as bool,lastSyncCount: null == lastSyncCount ? _self.lastSyncCount : lastSyncCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthSyncState].
extension HealthSyncStatePatterns on HealthSyncState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthSyncState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthSyncState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthSyncState value)  $default,){
final _that = this;
switch (_that) {
case _HealthSyncState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthSyncState value)?  $default,){
final _that = this;
switch (_that) {
case _HealthSyncState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isEnabled,  bool isSyncing,  int lastSyncCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthSyncState() when $default != null:
return $default(_that.isEnabled,_that.isSyncing,_that.lastSyncCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isEnabled,  bool isSyncing,  int lastSyncCount)  $default,) {final _that = this;
switch (_that) {
case _HealthSyncState():
return $default(_that.isEnabled,_that.isSyncing,_that.lastSyncCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isEnabled,  bool isSyncing,  int lastSyncCount)?  $default,) {final _that = this;
switch (_that) {
case _HealthSyncState() when $default != null:
return $default(_that.isEnabled,_that.isSyncing,_that.lastSyncCount);case _:
  return null;

}
}

}

/// @nodoc


class _HealthSyncState implements HealthSyncState {
  const _HealthSyncState({this.isEnabled = false, this.isSyncing = false, this.lastSyncCount = 0});
  

@override@JsonKey() final  bool isEnabled;
@override@JsonKey() final  bool isSyncing;
@override@JsonKey() final  int lastSyncCount;

/// Create a copy of HealthSyncState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthSyncStateCopyWith<_HealthSyncState> get copyWith => __$HealthSyncStateCopyWithImpl<_HealthSyncState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthSyncState&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.isSyncing, isSyncing) || other.isSyncing == isSyncing)&&(identical(other.lastSyncCount, lastSyncCount) || other.lastSyncCount == lastSyncCount));
}


@override
int get hashCode => Object.hash(runtimeType,isEnabled,isSyncing,lastSyncCount);

@override
String toString() {
  return 'HealthSyncState(isEnabled: $isEnabled, isSyncing: $isSyncing, lastSyncCount: $lastSyncCount)';
}


}

/// @nodoc
abstract mixin class _$HealthSyncStateCopyWith<$Res> implements $HealthSyncStateCopyWith<$Res> {
  factory _$HealthSyncStateCopyWith(_HealthSyncState value, $Res Function(_HealthSyncState) _then) = __$HealthSyncStateCopyWithImpl;
@override @useResult
$Res call({
 bool isEnabled, bool isSyncing, int lastSyncCount
});




}
/// @nodoc
class __$HealthSyncStateCopyWithImpl<$Res>
    implements _$HealthSyncStateCopyWith<$Res> {
  __$HealthSyncStateCopyWithImpl(this._self, this._then);

  final _HealthSyncState _self;
  final $Res Function(_HealthSyncState) _then;

/// Create a copy of HealthSyncState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isEnabled = null,Object? isSyncing = null,Object? lastSyncCount = null,}) {
  return _then(_HealthSyncState(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,isSyncing: null == isSyncing ? _self.isSyncing : isSyncing // ignore: cast_nullable_to_non_nullable
as bool,lastSyncCount: null == lastSyncCount ? _self.lastSyncCount : lastSyncCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
