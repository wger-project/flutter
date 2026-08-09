// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JwtCredential {

 String get accessToken; DateTime? get expiresAt;
/// Create a copy of JwtCredential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JwtCredentialCopyWith<JwtCredential> get copyWith => _$JwtCredentialCopyWithImpl<JwtCredential>(this as JwtCredential, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JwtCredential&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,accessToken,expiresAt);

@override
String toString() {
  return 'JwtCredential(accessToken: $accessToken, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $JwtCredentialCopyWith<$Res>  {
  factory $JwtCredentialCopyWith(JwtCredential value, $Res Function(JwtCredential) _then) = _$JwtCredentialCopyWithImpl;
@useResult
$Res call({
 String accessToken, DateTime? expiresAt
});




}
/// @nodoc
class _$JwtCredentialCopyWithImpl<$Res>
    implements $JwtCredentialCopyWith<$Res> {
  _$JwtCredentialCopyWithImpl(this._self, this._then);

  final JwtCredential _self;
  final $Res Function(JwtCredential) _then;

/// Create a copy of JwtCredential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [JwtCredential].
extension JwtCredentialPatterns on JwtCredential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JwtCredential value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JwtCredential() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JwtCredential value)  $default,){
final _that = this;
switch (_that) {
case _JwtCredential():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JwtCredential value)?  $default,){
final _that = this;
switch (_that) {
case _JwtCredential() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JwtCredential() when $default != null:
return $default(_that.accessToken,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _JwtCredential():
return $default(_that.accessToken,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _JwtCredential() when $default != null:
return $default(_that.accessToken,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _JwtCredential extends JwtCredential {
  const _JwtCredential({required this.accessToken, this.expiresAt}): super._();
  

@override final  String accessToken;
@override final  DateTime? expiresAt;

/// Create a copy of JwtCredential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JwtCredentialCopyWith<_JwtCredential> get copyWith => __$JwtCredentialCopyWithImpl<_JwtCredential>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JwtCredential&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,accessToken,expiresAt);

@override
String toString() {
  return 'JwtCredential(accessToken: $accessToken, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$JwtCredentialCopyWith<$Res> implements $JwtCredentialCopyWith<$Res> {
  factory _$JwtCredentialCopyWith(_JwtCredential value, $Res Function(_JwtCredential) _then) = __$JwtCredentialCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, DateTime? expiresAt
});




}
/// @nodoc
class __$JwtCredentialCopyWithImpl<$Res>
    implements _$JwtCredentialCopyWith<$Res> {
  __$JwtCredentialCopyWithImpl(this._self, this._then);

  final _JwtCredential _self;
  final $Res Function(_JwtCredential) _then;

/// Create a copy of JwtCredential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? expiresAt = freezed,}) {
  return _then(_JwtCredential(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
