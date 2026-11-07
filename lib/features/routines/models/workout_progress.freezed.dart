// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutProgress {

 int get dayId; int get iteration; String get currentPageKey; DateTime get workoutStart; DateTime get validUntil; Map<String, StoredPageProgress> get pages;
/// Create a copy of WorkoutProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutProgressCopyWith<WorkoutProgress> get copyWith => _$WorkoutProgressCopyWithImpl<WorkoutProgress>(this as WorkoutProgress, _$identity);

  /// Serializes this WorkoutProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkoutProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutProgress&&(identical(other.dayId, _this.dayId) || other.dayId == _this.dayId)&&(identical(other.iteration, _this.iteration) || other.iteration == _this.iteration)&&(identical(other.currentPageKey, _this.currentPageKey) || other.currentPageKey == _this.currentPageKey)&&(identical(other.workoutStart, _this.workoutStart) || other.workoutStart == _this.workoutStart)&&(identical(other.validUntil, _this.validUntil) || other.validUntil == _this.validUntil)&&const DeepCollectionEquality().equals(other.pages, _this.pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkoutProgress;
  return Object.hash(runtimeType,_this.dayId,_this.iteration,_this.currentPageKey,_this.workoutStart,_this.validUntil,const DeepCollectionEquality().hash(_this.pages));
}

@override
String toString() {
  final _this = this as WorkoutProgress;
  return 'WorkoutProgress(dayId: ${_this.dayId}, iteration: ${_this.iteration}, currentPageKey: ${_this.currentPageKey}, workoutStart: ${_this.workoutStart}, validUntil: ${_this.validUntil}, pages: ${_this.pages})';
}


}

/// @nodoc
abstract mixin class $WorkoutProgressCopyWith<$Res>  {
  factory $WorkoutProgressCopyWith(WorkoutProgress value, $Res Function(WorkoutProgress) _then) = _$WorkoutProgressCopyWithImpl;
@useResult
$Res call({
 int dayId, int iteration, String currentPageKey, DateTime workoutStart, DateTime validUntil, Map<String, StoredPageProgress> pages
});




}
/// @nodoc
class _$WorkoutProgressCopyWithImpl<$Res>
    implements $WorkoutProgressCopyWith<$Res> {
  _$WorkoutProgressCopyWithImpl(this._self, this._then);

  final WorkoutProgress _self;
  final $Res Function(WorkoutProgress) _then;

/// Create a copy of WorkoutProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayId = null,Object? iteration = null,Object? currentPageKey = null,Object? workoutStart = null,Object? validUntil = null,Object? pages = null,}) {
  return _then(WorkoutProgress(
dayId: null == dayId ? _self.dayId : dayId // ignore: cast_nullable_to_non_nullable
as int,iteration: null == iteration ? _self.iteration : iteration // ignore: cast_nullable_to_non_nullable
as int,currentPageKey: null == currentPageKey ? _self.currentPageKey : currentPageKey // ignore: cast_nullable_to_non_nullable
as String,workoutStart: null == workoutStart ? _self.workoutStart : workoutStart // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as Map<String, StoredPageProgress>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutProgress].
extension WorkoutProgressPatterns on WorkoutProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutProgress value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutProgress value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int dayId,  int iteration,  String currentPageKey,  DateTime workoutStart,  DateTime validUntil,  Map<String, StoredPageProgress> pages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutProgress() when $default != null:
return $default(_that.dayId,_that.iteration,_that.currentPageKey,_that.workoutStart,_that.validUntil,_that.pages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int dayId,  int iteration,  String currentPageKey,  DateTime workoutStart,  DateTime validUntil,  Map<String, StoredPageProgress> pages)  $default,) {final _that = this;
switch (_that) {
case _WorkoutProgress():
return $default(_that.dayId,_that.iteration,_that.currentPageKey,_that.workoutStart,_that.validUntil,_that.pages);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int dayId,  int iteration,  String currentPageKey,  DateTime workoutStart,  DateTime validUntil,  Map<String, StoredPageProgress> pages)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutProgress() when $default != null:
return $default(_that.dayId,_that.iteration,_that.currentPageKey,_that.workoutStart,_that.validUntil,_that.pages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutProgress implements WorkoutProgress {
  const _WorkoutProgress({required this.dayId, required this.iteration, required this.currentPageKey, required this.workoutStart, required this.validUntil,  Map<String, StoredPageProgress> pages = const {}}): _pages = pages;
  factory _WorkoutProgress.fromJson(Map<String, dynamic> json) => _$WorkoutProgressFromJson(json);

@override final  int dayId;
@override final  int iteration;
@override final  String currentPageKey;
@override final  DateTime workoutStart;
@override final  DateTime validUntil;
 final  Map<String, StoredPageProgress> _pages;
@override@JsonKey() Map<String, StoredPageProgress> get pages {
  if (_pages is EqualUnmodifiableMapView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pages);
}


/// Create a copy of WorkoutProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutProgressCopyWith<_WorkoutProgress> get copyWith => __$WorkoutProgressCopyWithImpl<_WorkoutProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutProgress&&(identical(other.dayId, dayId) || other.dayId == dayId)&&(identical(other.iteration, iteration) || other.iteration == iteration)&&(identical(other.currentPageKey, currentPageKey) || other.currentPageKey == currentPageKey)&&(identical(other.workoutStart, workoutStart) || other.workoutStart == workoutStart)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&const DeepCollectionEquality().equals(other.pages, _pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,dayId,iteration,currentPageKey,workoutStart,validUntil,const DeepCollectionEquality().hash(_pages));
}

@override
String toString() {
    return 'WorkoutProgress(dayId: $dayId, iteration: $iteration, currentPageKey: $currentPageKey, workoutStart: $workoutStart, validUntil: $validUntil, pages: $pages)';
}


}

/// @nodoc
abstract mixin class _$WorkoutProgressCopyWith<$Res> implements $WorkoutProgressCopyWith<$Res> {
  factory _$WorkoutProgressCopyWith(_WorkoutProgress value, $Res Function(_WorkoutProgress) _then) = __$WorkoutProgressCopyWithImpl;
@override @useResult
$Res call({
 int dayId, int iteration, String currentPageKey, DateTime workoutStart, DateTime validUntil, Map<String, StoredPageProgress> pages
});




}
/// @nodoc
class __$WorkoutProgressCopyWithImpl<$Res>
    implements _$WorkoutProgressCopyWith<$Res> {
  __$WorkoutProgressCopyWithImpl(this._self, this._then);

  final _WorkoutProgress _self;
  final $Res Function(_WorkoutProgress) _then;

/// Create a copy of WorkoutProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayId = null,Object? iteration = null,Object? currentPageKey = null,Object? workoutStart = null,Object? validUntil = null,Object? pages = null,}) {
  return _then(_WorkoutProgress(
dayId: null == dayId ? _self.dayId : dayId // ignore: cast_nullable_to_non_nullable
as int,iteration: null == iteration ? _self.iteration : iteration // ignore: cast_nullable_to_non_nullable
as int,currentPageKey: null == currentPageKey ? _self.currentPageKey : currentPageKey // ignore: cast_nullable_to_non_nullable
as String,workoutStart: null == workoutStart ? _self.workoutStart : workoutStart // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as Map<String, StoredPageProgress>,
  ));
}


}


/// @nodoc
mixin _$StoredPageProgress {

 bool get done; String? get logId; DateTime? get timerStartedAt;
/// Create a copy of StoredPageProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoredPageProgressCopyWith<StoredPageProgress> get copyWith => _$StoredPageProgressCopyWithImpl<StoredPageProgress>(this as StoredPageProgress, _$identity);

  /// Serializes this StoredPageProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StoredPageProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoredPageProgress&&(identical(other.done, _this.done) || other.done == _this.done)&&(identical(other.logId, _this.logId) || other.logId == _this.logId)&&(identical(other.timerStartedAt, _this.timerStartedAt) || other.timerStartedAt == _this.timerStartedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StoredPageProgress;
  return Object.hash(runtimeType,_this.done,_this.logId,_this.timerStartedAt);
}

@override
String toString() {
  final _this = this as StoredPageProgress;
  return 'StoredPageProgress(done: ${_this.done}, logId: ${_this.logId}, timerStartedAt: ${_this.timerStartedAt})';
}


}

/// @nodoc
abstract mixin class $StoredPageProgressCopyWith<$Res>  {
  factory $StoredPageProgressCopyWith(StoredPageProgress value, $Res Function(StoredPageProgress) _then) = _$StoredPageProgressCopyWithImpl;
@useResult
$Res call({
 bool done, String? logId, DateTime? timerStartedAt
});




}
/// @nodoc
class _$StoredPageProgressCopyWithImpl<$Res>
    implements $StoredPageProgressCopyWith<$Res> {
  _$StoredPageProgressCopyWithImpl(this._self, this._then);

  final StoredPageProgress _self;
  final $Res Function(StoredPageProgress) _then;

/// Create a copy of StoredPageProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? done = null,Object? logId = freezed,Object? timerStartedAt = freezed,}) {
  return _then(StoredPageProgress(
done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,logId: freezed == logId ? _self.logId : logId // ignore: cast_nullable_to_non_nullable
as String?,timerStartedAt: freezed == timerStartedAt ? _self.timerStartedAt : timerStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoredPageProgress].
extension StoredPageProgressPatterns on StoredPageProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoredPageProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoredPageProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoredPageProgress value)  $default,){
final _that = this;
switch (_that) {
case _StoredPageProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoredPageProgress value)?  $default,){
final _that = this;
switch (_that) {
case _StoredPageProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool done,  String? logId,  DateTime? timerStartedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoredPageProgress() when $default != null:
return $default(_that.done,_that.logId,_that.timerStartedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool done,  String? logId,  DateTime? timerStartedAt)  $default,) {final _that = this;
switch (_that) {
case _StoredPageProgress():
return $default(_that.done,_that.logId,_that.timerStartedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool done,  String? logId,  DateTime? timerStartedAt)?  $default,) {final _that = this;
switch (_that) {
case _StoredPageProgress() when $default != null:
return $default(_that.done,_that.logId,_that.timerStartedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoredPageProgress implements StoredPageProgress {
  const _StoredPageProgress({this.done = false, this.logId, this.timerStartedAt});
  factory _StoredPageProgress.fromJson(Map<String, dynamic> json) => _$StoredPageProgressFromJson(json);

@override@JsonKey() final  bool done;
@override final  String? logId;
@override final  DateTime? timerStartedAt;

/// Create a copy of StoredPageProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoredPageProgressCopyWith<_StoredPageProgress> get copyWith => __$StoredPageProgressCopyWithImpl<_StoredPageProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoredPageProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoredPageProgress&&(identical(other.done, done) || other.done == done)&&(identical(other.logId, logId) || other.logId == logId)&&(identical(other.timerStartedAt, timerStartedAt) || other.timerStartedAt == timerStartedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,done,logId,timerStartedAt);
}

@override
String toString() {
    return 'StoredPageProgress(done: $done, logId: $logId, timerStartedAt: $timerStartedAt)';
}


}

/// @nodoc
abstract mixin class _$StoredPageProgressCopyWith<$Res> implements $StoredPageProgressCopyWith<$Res> {
  factory _$StoredPageProgressCopyWith(_StoredPageProgress value, $Res Function(_StoredPageProgress) _then) = __$StoredPageProgressCopyWithImpl;
@override @useResult
$Res call({
 bool done, String? logId, DateTime? timerStartedAt
});




}
/// @nodoc
class __$StoredPageProgressCopyWithImpl<$Res>
    implements _$StoredPageProgressCopyWith<$Res> {
  __$StoredPageProgressCopyWithImpl(this._self, this._then);

  final _StoredPageProgress _self;
  final $Res Function(_StoredPageProgress) _then;

/// Create a copy of StoredPageProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? done = null,Object? logId = freezed,Object? timerStartedAt = freezed,}) {
  return _then(_StoredPageProgress(
done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,logId: freezed == logId ? _self.logId : logId // ignore: cast_nullable_to_non_nullable
as String?,timerStartedAt: freezed == timerStartedAt ? _self.timerStartedAt : timerStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
