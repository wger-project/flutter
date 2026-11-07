// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PageProgress {


/// Create a copy of PageProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageProgressCopyWith<PageProgress> get copyWith => _$PageProgressCopyWithImpl<PageProgress>(this as PageProgress, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PageProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageProgress&&(identical(other.done, _this.done) || other.done == _this.done)&&(identical(other.loggedEntry, _this.loggedEntry) || other.loggedEntry == _this.loggedEntry)&&(identical(other.timerStartedAt, _this.timerStartedAt) || other.timerStartedAt == _this.timerStartedAt));
}


@override
int get hashCode {
  final _this = this as PageProgress;
  return Object.hash(runtimeType,_this.done,_this.loggedEntry,_this.timerStartedAt);
}

@override
String toString() {
  final _this = this as PageProgress;
  return 'PageProgress(done: ${_this.done}, loggedEntry: ${_this.loggedEntry}, timerStartedAt: ${_this.timerStartedAt})';
}


}

/// @nodoc
abstract mixin class $PageProgressCopyWith<$Res>  {
  factory $PageProgressCopyWith(PageProgress value, $Res Function(PageProgress) _then) = _$PageProgressCopyWithImpl;
@useResult
$Res call({
 bool done, Log? loggedEntry, DateTime? timerStartedAt
});




}
/// @nodoc
class _$PageProgressCopyWithImpl<$Res>
    implements $PageProgressCopyWith<$Res> {
  _$PageProgressCopyWithImpl(this._self, this._then);

  final PageProgress _self;
  final $Res Function(PageProgress) _then;

/// Create a copy of PageProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? done = null,Object? loggedEntry = freezed,Object? timerStartedAt = freezed,}) {
  return _then(PageProgress(
done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,loggedEntry: freezed == loggedEntry ? _self.loggedEntry : loggedEntry // ignore: cast_nullable_to_non_nullable
as Log?,timerStartedAt: freezed == timerStartedAt ? _self.timerStartedAt : timerStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PageProgress].
extension PageProgressPatterns on PageProgress {
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
