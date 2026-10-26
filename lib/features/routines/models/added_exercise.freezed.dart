// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'added_exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddedExercise {


/// Create a copy of AddedExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddedExerciseCopyWith<AddedExercise> get copyWith => _$AddedExerciseCopyWithImpl<AddedExercise>(this as AddedExercise, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddedExercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddedExercise&&(identical(other.afterPageKey, _this.afterPageKey) || other.afterPageKey == _this.afterPageKey)&&(identical(other.exercise, _this.exercise) || other.exercise == _this.exercise)&&(identical(other.slotEntryId, _this.slotEntryId) || other.slotEntryId == _this.slotEntryId)&&(identical(other.weightUnit, _this.weightUnit) || other.weightUnit == _this.weightUnit));
}


@override
int get hashCode {
  final _this = this as AddedExercise;
  return Object.hash(runtimeType,_this.afterPageKey,_this.exercise,_this.slotEntryId,_this.weightUnit);
}

@override
String toString() {
  final _this = this as AddedExercise;
  return 'AddedExercise(afterPageKey: ${_this.afterPageKey}, exercise: ${_this.exercise}, slotEntryId: ${_this.slotEntryId}, weightUnit: ${_this.weightUnit})';
}


}

/// @nodoc
abstract mixin class $AddedExerciseCopyWith<$Res>  {
  factory $AddedExerciseCopyWith(AddedExercise value, $Res Function(AddedExercise) _then) = _$AddedExerciseCopyWithImpl;
@useResult
$Res call({
 String afterPageKey, Exercise exercise, int slotEntryId, WeightUnit? weightUnit
});




}
/// @nodoc
class _$AddedExerciseCopyWithImpl<$Res>
    implements $AddedExerciseCopyWith<$Res> {
  _$AddedExerciseCopyWithImpl(this._self, this._then);

  final AddedExercise _self;
  final $Res Function(AddedExercise) _then;

/// Create a copy of AddedExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? afterPageKey = null,Object? exercise = null,Object? slotEntryId = null,Object? weightUnit = freezed,}) {
  return _then(AddedExercise(
afterPageKey: null == afterPageKey ? _self.afterPageKey : afterPageKey // ignore: cast_nullable_to_non_nullable
as String,exercise: null == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise,slotEntryId: null == slotEntryId ? _self.slotEntryId : slotEntryId // ignore: cast_nullable_to_non_nullable
as int,weightUnit: freezed == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as WeightUnit?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddedExercise].
extension AddedExercisePatterns on AddedExercise {
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
