// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

 ThemeMode get themeMode; List<DashboardItem> get dashboardItems;/// Locale override. Null means the app follows the system locale.
 Locale? get userLocale;/// When true, a manual logout keeps the local database on disk instead
/// of wiping it, so the same user signing back in resumes incrementally.
 bool get keepDataOnLogout;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&const DeepCollectionEquality().equals(other.dashboardItems, dashboardItems)&&(identical(other.userLocale, userLocale) || other.userLocale == userLocale)&&(identical(other.keepDataOnLogout, keepDataOnLogout) || other.keepDataOnLogout == keepDataOnLogout));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,const DeepCollectionEquality().hash(dashboardItems),userLocale,keepDataOnLogout);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, dashboardItems: $dashboardItems, userLocale: $userLocale, keepDataOnLogout: $keepDataOnLogout)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 ThemeMode themeMode, List<DashboardItem> dashboardItems, Locale? userLocale, bool keepDataOnLogout
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? dashboardItems = null,Object? userLocale = freezed,Object? keepDataOnLogout = null,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,dashboardItems: null == dashboardItems ? _self.dashboardItems : dashboardItems // ignore: cast_nullable_to_non_nullable
as List<DashboardItem>,userLocale: freezed == userLocale ? _self.userLocale : userLocale // ignore: cast_nullable_to_non_nullable
as Locale?,keepDataOnLogout: null == keepDataOnLogout ? _self.keepDataOnLogout : keepDataOnLogout // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemeMode themeMode,  List<DashboardItem> dashboardItems,  Locale? userLocale,  bool keepDataOnLogout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.dashboardItems,_that.userLocale,_that.keepDataOnLogout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemeMode themeMode,  List<DashboardItem> dashboardItems,  Locale? userLocale,  bool keepDataOnLogout)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.themeMode,_that.dashboardItems,_that.userLocale,_that.keepDataOnLogout);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemeMode themeMode,  List<DashboardItem> dashboardItems,  Locale? userLocale,  bool keepDataOnLogout)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.dashboardItems,_that.userLocale,_that.keepDataOnLogout);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({this.themeMode = ThemeMode.system, final  List<DashboardItem> dashboardItems = const [], this.userLocale, this.keepDataOnLogout = KEEP_DATA_ON_LOGOUT_DEFAULT}): _dashboardItems = dashboardItems;
  

@override@JsonKey() final  ThemeMode themeMode;
 final  List<DashboardItem> _dashboardItems;
@override@JsonKey() List<DashboardItem> get dashboardItems {
  if (_dashboardItems is EqualUnmodifiableListView) return _dashboardItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dashboardItems);
}

/// Locale override. Null means the app follows the system locale.
@override final  Locale? userLocale;
/// When true, a manual logout keeps the local database on disk instead
/// of wiping it, so the same user signing back in resumes incrementally.
@override@JsonKey() final  bool keepDataOnLogout;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&const DeepCollectionEquality().equals(other._dashboardItems, _dashboardItems)&&(identical(other.userLocale, userLocale) || other.userLocale == userLocale)&&(identical(other.keepDataOnLogout, keepDataOnLogout) || other.keepDataOnLogout == keepDataOnLogout));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,const DeepCollectionEquality().hash(_dashboardItems),userLocale,keepDataOnLogout);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, dashboardItems: $dashboardItems, userLocale: $userLocale, keepDataOnLogout: $keepDataOnLogout)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 ThemeMode themeMode, List<DashboardItem> dashboardItems, Locale? userLocale, bool keepDataOnLogout
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? dashboardItems = null,Object? userLocale = freezed,Object? keepDataOnLogout = null,}) {
  return _then(_AppSettings(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,dashboardItems: null == dashboardItems ? _self._dashboardItems : dashboardItems // ignore: cast_nullable_to_non_nullable
as List<DashboardItem>,userLocale: freezed == userLocale ? _self.userLocale : userLocale // ignore: cast_nullable_to_non_nullable
as Locale?,keepDataOnLogout: null == keepDataOnLogout ? _self.keepDataOnLogout : keepDataOnLogout // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
