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
mixin _$AuthCredential {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthCredential);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthCredential()';
}


}

/// @nodoc
class $AuthCredentialCopyWith<$Res>  {
$AuthCredentialCopyWith(AuthCredential _, $Res Function(AuthCredential) __);
}


/// Adds pattern-matching-related methods to [AuthCredential].
extension AuthCredentialPatterns on AuthCredential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LegacyCredential value)?  legacy,TResult Function( JwtCredential value)?  jwt,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LegacyCredential() when legacy != null:
return legacy(_that);case JwtCredential() when jwt != null:
return jwt(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LegacyCredential value)  legacy,required TResult Function( JwtCredential value)  jwt,}){
final _that = this;
switch (_that) {
case LegacyCredential():
return legacy(_that);case JwtCredential():
return jwt(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LegacyCredential value)?  legacy,TResult? Function( JwtCredential value)?  jwt,}){
final _that = this;
switch (_that) {
case LegacyCredential() when legacy != null:
return legacy(_that);case JwtCredential() when jwt != null:
return jwt(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String token)?  legacy,TResult Function( String accessToken,  DateTime? expiresAt)?  jwt,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LegacyCredential() when legacy != null:
return legacy(_that.token);case JwtCredential() when jwt != null:
return jwt(_that.accessToken,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String token)  legacy,required TResult Function( String accessToken,  DateTime? expiresAt)  jwt,}) {final _that = this;
switch (_that) {
case LegacyCredential():
return legacy(_that.token);case JwtCredential():
return jwt(_that.accessToken,_that.expiresAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String token)?  legacy,TResult? Function( String accessToken,  DateTime? expiresAt)?  jwt,}) {final _that = this;
switch (_that) {
case LegacyCredential() when legacy != null:
return legacy(_that.token);case JwtCredential() when jwt != null:
return jwt(_that.accessToken,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class LegacyCredential extends AuthCredential {
  const LegacyCredential(this.token): super._();
  

 final  String token;

/// Create a copy of AuthCredential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LegacyCredentialCopyWith<LegacyCredential> get copyWith => _$LegacyCredentialCopyWithImpl<LegacyCredential>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LegacyCredential&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'AuthCredential.legacy(token: $token)';
}


}

/// @nodoc
abstract mixin class $LegacyCredentialCopyWith<$Res> implements $AuthCredentialCopyWith<$Res> {
  factory $LegacyCredentialCopyWith(LegacyCredential value, $Res Function(LegacyCredential) _then) = _$LegacyCredentialCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class _$LegacyCredentialCopyWithImpl<$Res>
    implements $LegacyCredentialCopyWith<$Res> {
  _$LegacyCredentialCopyWithImpl(this._self, this._then);

  final LegacyCredential _self;
  final $Res Function(LegacyCredential) _then;

/// Create a copy of AuthCredential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(LegacyCredential(
null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class JwtCredential extends AuthCredential {
  const JwtCredential({required this.accessToken, this.expiresAt}): super._();
  

 final  String accessToken;
 final  DateTime? expiresAt;

/// Create a copy of AuthCredential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JwtCredentialCopyWith<JwtCredential> get copyWith => _$JwtCredentialCopyWithImpl<JwtCredential>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JwtCredential&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,accessToken,expiresAt);

@override
String toString() {
  return 'AuthCredential.jwt(accessToken: $accessToken, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $JwtCredentialCopyWith<$Res> implements $AuthCredentialCopyWith<$Res> {
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

/// Create a copy of AuthCredential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? expiresAt = freezed,}) {
  return _then(JwtCredential(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
