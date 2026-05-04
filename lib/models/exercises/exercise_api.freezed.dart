// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
ExerciseApiData _$ExerciseApiDataFromJson(
  Map<String, dynamic> json
) {
    return _ExerciseBaseData.fromJson(
      json
    );
}

/// @nodoc
mixin _$ExerciseApiData {

 int get id; String get uuid;// ignore: invalid_annotation_target
@JsonKey(name: 'variation_group') String? get variationGroup;// ignore: invalid_annotation_target
@JsonKey(name: 'created') DateTime get created;// ignore: invalid_annotation_target
@JsonKey(name: 'last_update') DateTime get lastUpdate;// ignore: invalid_annotation_target
@JsonKey(name: 'last_update_global') DateTime get lastUpdateGlobal; ExerciseCategory get category; List<Muscle> get muscles;// ignore: invalid_annotation_target
@JsonKey(name: 'muscles_secondary') List<Muscle> get musclesSecondary;// ignore: invalid_annotation_target
 List<Equipment> get equipment;// ignore: invalid_annotation_target
@JsonKey(name: 'translations', defaultValue: []) List<Translation> get translations; List<ExerciseImage> get images; List<Video> get videos;// ignore: invalid_annotation_target
@JsonKey(name: 'author_history') List<String> get authors;// ignore: invalid_annotation_target
@JsonKey(name: 'total_authors_history') List<String> get authorsGlobal;
/// Create a copy of ExerciseApiData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseApiDataCopyWith<ExerciseApiData> get copyWith => _$ExerciseApiDataCopyWithImpl<ExerciseApiData>(this as ExerciseApiData, _$identity);

  /// Serializes this ExerciseApiData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseApiData&&(identical(other.id, id) || other.id == id)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.variationGroup, variationGroup) || other.variationGroup == variationGroup)&&(identical(other.created, created) || other.created == created)&&(identical(other.lastUpdate, lastUpdate) || other.lastUpdate == lastUpdate)&&(identical(other.lastUpdateGlobal, lastUpdateGlobal) || other.lastUpdateGlobal == lastUpdateGlobal)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.muscles, muscles)&&const DeepCollectionEquality().equals(other.musclesSecondary, musclesSecondary)&&const DeepCollectionEquality().equals(other.equipment, equipment)&&const DeepCollectionEquality().equals(other.translations, translations)&&const DeepCollectionEquality().equals(other.images, images)&&const DeepCollectionEquality().equals(other.videos, videos)&&const DeepCollectionEquality().equals(other.authors, authors)&&const DeepCollectionEquality().equals(other.authorsGlobal, authorsGlobal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uuid,variationGroup,created,lastUpdate,lastUpdateGlobal,category,const DeepCollectionEquality().hash(muscles),const DeepCollectionEquality().hash(musclesSecondary),const DeepCollectionEquality().hash(equipment),const DeepCollectionEquality().hash(translations),const DeepCollectionEquality().hash(images),const DeepCollectionEquality().hash(videos),const DeepCollectionEquality().hash(authors),const DeepCollectionEquality().hash(authorsGlobal));

@override
String toString() {
  return 'ExerciseApiData(id: $id, uuid: $uuid, variationGroup: $variationGroup, created: $created, lastUpdate: $lastUpdate, lastUpdateGlobal: $lastUpdateGlobal, category: $category, muscles: $muscles, musclesSecondary: $musclesSecondary, equipment: $equipment, translations: $translations, images: $images, videos: $videos, authors: $authors, authorsGlobal: $authorsGlobal)';
}


}

/// @nodoc
abstract mixin class $ExerciseApiDataCopyWith<$Res>  {
  factory $ExerciseApiDataCopyWith(ExerciseApiData value, $Res Function(ExerciseApiData) _then) = _$ExerciseApiDataCopyWithImpl;
@useResult
$Res call({
 int id, String uuid,@JsonKey(name: 'variation_group') String? variationGroup,@JsonKey(name: 'created') DateTime created,@JsonKey(name: 'last_update') DateTime lastUpdate,@JsonKey(name: 'last_update_global') DateTime lastUpdateGlobal, ExerciseCategory category, List<Muscle> muscles,@JsonKey(name: 'muscles_secondary') List<Muscle> musclesSecondary, List<Equipment> equipment,@JsonKey(name: 'translations', defaultValue: []) List<Translation> translations, List<ExerciseImage> images, List<Video> videos,@JsonKey(name: 'author_history') List<String> authors,@JsonKey(name: 'total_authors_history') List<String> authorsGlobal
});




}
/// @nodoc
class _$ExerciseApiDataCopyWithImpl<$Res>
    implements $ExerciseApiDataCopyWith<$Res> {
  _$ExerciseApiDataCopyWithImpl(this._self, this._then);

  final ExerciseApiData _self;
  final $Res Function(ExerciseApiData) _then;

/// Create a copy of ExerciseApiData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uuid = null,Object? variationGroup = freezed,Object? created = null,Object? lastUpdate = null,Object? lastUpdateGlobal = null,Object? category = null,Object? muscles = null,Object? musclesSecondary = null,Object? equipment = null,Object? translations = null,Object? images = null,Object? videos = null,Object? authors = null,Object? authorsGlobal = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,variationGroup: freezed == variationGroup ? _self.variationGroup : variationGroup // ignore: cast_nullable_to_non_nullable
as String?,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdate: null == lastUpdate ? _self.lastUpdate : lastUpdate // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdateGlobal: null == lastUpdateGlobal ? _self.lastUpdateGlobal : lastUpdateGlobal // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,muscles: null == muscles ? _self.muscles : muscles // ignore: cast_nullable_to_non_nullable
as List<Muscle>,musclesSecondary: null == musclesSecondary ? _self.musclesSecondary : musclesSecondary // ignore: cast_nullable_to_non_nullable
as List<Muscle>,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<Equipment>,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as List<Translation>,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ExerciseImage>,videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<Video>,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,authorsGlobal: null == authorsGlobal ? _self.authorsGlobal : authorsGlobal // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseApiData].
extension ExerciseApiDataPatterns on ExerciseApiData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseBaseData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseBaseData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseBaseData value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseBaseData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseBaseData value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseBaseData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String uuid, @JsonKey(name: 'variation_group')  String? variationGroup, @JsonKey(name: 'created')  DateTime created, @JsonKey(name: 'last_update')  DateTime lastUpdate, @JsonKey(name: 'last_update_global')  DateTime lastUpdateGlobal,  ExerciseCategory category,  List<Muscle> muscles, @JsonKey(name: 'muscles_secondary')  List<Muscle> musclesSecondary,  List<Equipment> equipment, @JsonKey(name: 'translations', defaultValue: [])  List<Translation> translations,  List<ExerciseImage> images,  List<Video> videos, @JsonKey(name: 'author_history')  List<String> authors, @JsonKey(name: 'total_authors_history')  List<String> authorsGlobal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseBaseData() when $default != null:
return $default(_that.id,_that.uuid,_that.variationGroup,_that.created,_that.lastUpdate,_that.lastUpdateGlobal,_that.category,_that.muscles,_that.musclesSecondary,_that.equipment,_that.translations,_that.images,_that.videos,_that.authors,_that.authorsGlobal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String uuid, @JsonKey(name: 'variation_group')  String? variationGroup, @JsonKey(name: 'created')  DateTime created, @JsonKey(name: 'last_update')  DateTime lastUpdate, @JsonKey(name: 'last_update_global')  DateTime lastUpdateGlobal,  ExerciseCategory category,  List<Muscle> muscles, @JsonKey(name: 'muscles_secondary')  List<Muscle> musclesSecondary,  List<Equipment> equipment, @JsonKey(name: 'translations', defaultValue: [])  List<Translation> translations,  List<ExerciseImage> images,  List<Video> videos, @JsonKey(name: 'author_history')  List<String> authors, @JsonKey(name: 'total_authors_history')  List<String> authorsGlobal)  $default,) {final _that = this;
switch (_that) {
case _ExerciseBaseData():
return $default(_that.id,_that.uuid,_that.variationGroup,_that.created,_that.lastUpdate,_that.lastUpdateGlobal,_that.category,_that.muscles,_that.musclesSecondary,_that.equipment,_that.translations,_that.images,_that.videos,_that.authors,_that.authorsGlobal);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String uuid, @JsonKey(name: 'variation_group')  String? variationGroup, @JsonKey(name: 'created')  DateTime created, @JsonKey(name: 'last_update')  DateTime lastUpdate, @JsonKey(name: 'last_update_global')  DateTime lastUpdateGlobal,  ExerciseCategory category,  List<Muscle> muscles, @JsonKey(name: 'muscles_secondary')  List<Muscle> musclesSecondary,  List<Equipment> equipment, @JsonKey(name: 'translations', defaultValue: [])  List<Translation> translations,  List<ExerciseImage> images,  List<Video> videos, @JsonKey(name: 'author_history')  List<String> authors, @JsonKey(name: 'total_authors_history')  List<String> authorsGlobal)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseBaseData() when $default != null:
return $default(_that.id,_that.uuid,_that.variationGroup,_that.created,_that.lastUpdate,_that.lastUpdateGlobal,_that.category,_that.muscles,_that.musclesSecondary,_that.equipment,_that.translations,_that.images,_that.videos,_that.authors,_that.authorsGlobal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseBaseData implements ExerciseApiData {
   _ExerciseBaseData({required this.id, required this.uuid, @JsonKey(name: 'variation_group') this.variationGroup = null, @JsonKey(name: 'created') required this.created, @JsonKey(name: 'last_update') required this.lastUpdate, @JsonKey(name: 'last_update_global') required this.lastUpdateGlobal, required this.category, required final  List<Muscle> muscles, @JsonKey(name: 'muscles_secondary') required final  List<Muscle> musclesSecondary, required final  List<Equipment> equipment, @JsonKey(name: 'translations', defaultValue: []) required final  List<Translation> translations, required final  List<ExerciseImage> images, required final  List<Video> videos, @JsonKey(name: 'author_history') required final  List<String> authors, @JsonKey(name: 'total_authors_history') required final  List<String> authorsGlobal}): _muscles = muscles,_musclesSecondary = musclesSecondary,_equipment = equipment,_translations = translations,_images = images,_videos = videos,_authors = authors,_authorsGlobal = authorsGlobal;
  factory _ExerciseBaseData.fromJson(Map<String, dynamic> json) => _$ExerciseBaseDataFromJson(json);

@override final  int id;
@override final  String uuid;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'variation_group') final  String? variationGroup;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'created') final  DateTime created;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'last_update') final  DateTime lastUpdate;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'last_update_global') final  DateTime lastUpdateGlobal;
@override final  ExerciseCategory category;
 final  List<Muscle> _muscles;
@override List<Muscle> get muscles {
  if (_muscles is EqualUnmodifiableListView) return _muscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_muscles);
}

// ignore: invalid_annotation_target
 final  List<Muscle> _musclesSecondary;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'muscles_secondary') List<Muscle> get musclesSecondary {
  if (_musclesSecondary is EqualUnmodifiableListView) return _musclesSecondary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_musclesSecondary);
}

// ignore: invalid_annotation_target
 final  List<Equipment> _equipment;
// ignore: invalid_annotation_target
@override List<Equipment> get equipment {
  if (_equipment is EqualUnmodifiableListView) return _equipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_equipment);
}

// ignore: invalid_annotation_target
 final  List<Translation> _translations;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'translations', defaultValue: []) List<Translation> get translations {
  if (_translations is EqualUnmodifiableListView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_translations);
}

 final  List<ExerciseImage> _images;
@override List<ExerciseImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

 final  List<Video> _videos;
@override List<Video> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

// ignore: invalid_annotation_target
 final  List<String> _authors;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'author_history') List<String> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

// ignore: invalid_annotation_target
 final  List<String> _authorsGlobal;
// ignore: invalid_annotation_target
@override@JsonKey(name: 'total_authors_history') List<String> get authorsGlobal {
  if (_authorsGlobal is EqualUnmodifiableListView) return _authorsGlobal;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authorsGlobal);
}


/// Create a copy of ExerciseApiData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseBaseDataCopyWith<_ExerciseBaseData> get copyWith => __$ExerciseBaseDataCopyWithImpl<_ExerciseBaseData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseBaseDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseBaseData&&(identical(other.id, id) || other.id == id)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.variationGroup, variationGroup) || other.variationGroup == variationGroup)&&(identical(other.created, created) || other.created == created)&&(identical(other.lastUpdate, lastUpdate) || other.lastUpdate == lastUpdate)&&(identical(other.lastUpdateGlobal, lastUpdateGlobal) || other.lastUpdateGlobal == lastUpdateGlobal)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._muscles, _muscles)&&const DeepCollectionEquality().equals(other._musclesSecondary, _musclesSecondary)&&const DeepCollectionEquality().equals(other._equipment, _equipment)&&const DeepCollectionEquality().equals(other._translations, _translations)&&const DeepCollectionEquality().equals(other._images, _images)&&const DeepCollectionEquality().equals(other._videos, _videos)&&const DeepCollectionEquality().equals(other._authors, _authors)&&const DeepCollectionEquality().equals(other._authorsGlobal, _authorsGlobal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uuid,variationGroup,created,lastUpdate,lastUpdateGlobal,category,const DeepCollectionEquality().hash(_muscles),const DeepCollectionEquality().hash(_musclesSecondary),const DeepCollectionEquality().hash(_equipment),const DeepCollectionEquality().hash(_translations),const DeepCollectionEquality().hash(_images),const DeepCollectionEquality().hash(_videos),const DeepCollectionEquality().hash(_authors),const DeepCollectionEquality().hash(_authorsGlobal));

@override
String toString() {
  return 'ExerciseApiData(id: $id, uuid: $uuid, variationGroup: $variationGroup, created: $created, lastUpdate: $lastUpdate, lastUpdateGlobal: $lastUpdateGlobal, category: $category, muscles: $muscles, musclesSecondary: $musclesSecondary, equipment: $equipment, translations: $translations, images: $images, videos: $videos, authors: $authors, authorsGlobal: $authorsGlobal)';
}


}

/// @nodoc
abstract mixin class _$ExerciseBaseDataCopyWith<$Res> implements $ExerciseApiDataCopyWith<$Res> {
  factory _$ExerciseBaseDataCopyWith(_ExerciseBaseData value, $Res Function(_ExerciseBaseData) _then) = __$ExerciseBaseDataCopyWithImpl;
@override @useResult
$Res call({
 int id, String uuid,@JsonKey(name: 'variation_group') String? variationGroup,@JsonKey(name: 'created') DateTime created,@JsonKey(name: 'last_update') DateTime lastUpdate,@JsonKey(name: 'last_update_global') DateTime lastUpdateGlobal, ExerciseCategory category, List<Muscle> muscles,@JsonKey(name: 'muscles_secondary') List<Muscle> musclesSecondary, List<Equipment> equipment,@JsonKey(name: 'translations', defaultValue: []) List<Translation> translations, List<ExerciseImage> images, List<Video> videos,@JsonKey(name: 'author_history') List<String> authors,@JsonKey(name: 'total_authors_history') List<String> authorsGlobal
});




}
/// @nodoc
class __$ExerciseBaseDataCopyWithImpl<$Res>
    implements _$ExerciseBaseDataCopyWith<$Res> {
  __$ExerciseBaseDataCopyWithImpl(this._self, this._then);

  final _ExerciseBaseData _self;
  final $Res Function(_ExerciseBaseData) _then;

/// Create a copy of ExerciseApiData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uuid = null,Object? variationGroup = freezed,Object? created = null,Object? lastUpdate = null,Object? lastUpdateGlobal = null,Object? category = null,Object? muscles = null,Object? musclesSecondary = null,Object? equipment = null,Object? translations = null,Object? images = null,Object? videos = null,Object? authors = null,Object? authorsGlobal = null,}) {
  return _then(_ExerciseBaseData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,variationGroup: freezed == variationGroup ? _self.variationGroup : variationGroup // ignore: cast_nullable_to_non_nullable
as String?,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdate: null == lastUpdate ? _self.lastUpdate : lastUpdate // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdateGlobal: null == lastUpdateGlobal ? _self.lastUpdateGlobal : lastUpdateGlobal // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,muscles: null == muscles ? _self._muscles : muscles // ignore: cast_nullable_to_non_nullable
as List<Muscle>,musclesSecondary: null == musclesSecondary ? _self._musclesSecondary : musclesSecondary // ignore: cast_nullable_to_non_nullable
as List<Muscle>,equipment: null == equipment ? _self._equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<Equipment>,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as List<Translation>,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ExerciseImage>,videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<Video>,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,authorsGlobal: null == authorsGlobal ? _self._authorsGlobal : authorsGlobal // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
