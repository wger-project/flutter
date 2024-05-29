// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseApiData _$ExerciseApiDataFromJson(Map<String, dynamic> json) {
  return _ExerciseBaseData.fromJson(json);
}

/// @nodoc
mixin _$ExerciseApiData {
  int get id => throw _privateConstructorUsedError;
  String get uuid =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'variations')
  int? get variationId =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'created')
  DateTime get created =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'last_update')
  DateTime get lastUpdate =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'last_update_global')
  DateTime get lastUpdateGlobal => throw _privateConstructorUsedError;
  ExerciseCategory get category => throw _privateConstructorUsedError;
  List<Muscle> get muscles =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'muscles_secondary')
  List<Muscle> get musclesSecondary =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  List<Equipment> get equipment =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'exercises')
  List<Translation> get translations => throw _privateConstructorUsedError;
  List<ExerciseImage> get images => throw _privateConstructorUsedError;
  List<Video> get videos =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'author_history')
  List<String> get authors =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'total_authors_history')
  List<String> get authorsGlobal => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseApiDataCopyWith<ExerciseApiData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseApiDataCopyWith<$Res> {
  factory $ExerciseApiDataCopyWith(
          ExerciseApiData value, $Res Function(ExerciseApiData) then) =
      _$ExerciseApiDataCopyWithImpl<$Res, ExerciseApiData>;
  @useResult
  $Res call(
      {int id,
      String uuid,
      @JsonKey(name: 'variations') int? variationId,
      @JsonKey(name: 'created') DateTime created,
      @JsonKey(name: 'last_update') DateTime lastUpdate,
      @JsonKey(name: 'last_update_global') DateTime lastUpdateGlobal,
      ExerciseCategory category,
      List<Muscle> muscles,
      @JsonKey(name: 'muscles_secondary') List<Muscle> musclesSecondary,
      List<Equipment> equipment,
      @JsonKey(name: 'exercises') List<Translation> translations,
      List<ExerciseImage> images,
      List<Video> videos,
      @JsonKey(name: 'author_history') List<String> authors,
      @JsonKey(name: 'total_authors_history') List<String> authorsGlobal});
}

/// @nodoc
class _$ExerciseApiDataCopyWithImpl<$Res, $Val extends ExerciseApiData>
    implements $ExerciseApiDataCopyWith<$Res> {
  _$ExerciseApiDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uuid = null,
    Object? variationId = freezed,
    Object? created = null,
    Object? lastUpdate = null,
    Object? lastUpdateGlobal = null,
    Object? category = null,
    Object? muscles = null,
    Object? musclesSecondary = null,
    Object? equipment = null,
    Object? translations = null,
    Object? images = null,
    Object? videos = null,
    Object? authors = null,
    Object? authorsGlobal = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      variationId: freezed == variationId
          ? _value.variationId
          : variationId // ignore: cast_nullable_to_non_nullable
              as int?,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdate: null == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdateGlobal: null == lastUpdateGlobal
          ? _value.lastUpdateGlobal
          : lastUpdateGlobal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ExerciseCategory,
      muscles: null == muscles
          ? _value.muscles
          : muscles // ignore: cast_nullable_to_non_nullable
              as List<Muscle>,
      musclesSecondary: null == musclesSecondary
          ? _value.musclesSecondary
          : musclesSecondary // ignore: cast_nullable_to_non_nullable
              as List<Muscle>,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<Equipment>,
      translations: null == translations
          ? _value.translations
          : translations // ignore: cast_nullable_to_non_nullable
              as List<Translation>,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ExerciseImage>,
      videos: null == videos
          ? _value.videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<Video>,
      authors: null == authors
          ? _value.authors
          : authors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      authorsGlobal: null == authorsGlobal
          ? _value.authorsGlobal
          : authorsGlobal // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseBaseDataImplCopyWith<$Res>
    implements $ExerciseApiDataCopyWith<$Res> {
  factory _$$ExerciseBaseDataImplCopyWith(_$ExerciseBaseDataImpl value,
          $Res Function(_$ExerciseBaseDataImpl) then) =
      __$$ExerciseBaseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String uuid,
      @JsonKey(name: 'variations') int? variationId,
      @JsonKey(name: 'created') DateTime created,
      @JsonKey(name: 'last_update') DateTime lastUpdate,
      @JsonKey(name: 'last_update_global') DateTime lastUpdateGlobal,
      ExerciseCategory category,
      List<Muscle> muscles,
      @JsonKey(name: 'muscles_secondary') List<Muscle> musclesSecondary,
      List<Equipment> equipment,
      @JsonKey(name: 'exercises') List<Translation> translations,
      List<ExerciseImage> images,
      List<Video> videos,
      @JsonKey(name: 'author_history') List<String> authors,
      @JsonKey(name: 'total_authors_history') List<String> authorsGlobal});
}

/// @nodoc
class __$$ExerciseBaseDataImplCopyWithImpl<$Res>
    extends _$ExerciseApiDataCopyWithImpl<$Res, _$ExerciseBaseDataImpl>
    implements _$$ExerciseBaseDataImplCopyWith<$Res> {
  __$$ExerciseBaseDataImplCopyWithImpl(_$ExerciseBaseDataImpl _value,
      $Res Function(_$ExerciseBaseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uuid = null,
    Object? variationId = freezed,
    Object? created = null,
    Object? lastUpdate = null,
    Object? lastUpdateGlobal = null,
    Object? category = null,
    Object? muscles = null,
    Object? musclesSecondary = null,
    Object? equipment = null,
    Object? translations = null,
    Object? images = null,
    Object? videos = null,
    Object? authors = null,
    Object? authorsGlobal = null,
  }) {
    return _then(_$ExerciseBaseDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      variationId: freezed == variationId
          ? _value.variationId
          : variationId // ignore: cast_nullable_to_non_nullable
              as int?,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdate: null == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdateGlobal: null == lastUpdateGlobal
          ? _value.lastUpdateGlobal
          : lastUpdateGlobal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ExerciseCategory,
      muscles: null == muscles
          ? _value._muscles
          : muscles // ignore: cast_nullable_to_non_nullable
              as List<Muscle>,
      musclesSecondary: null == musclesSecondary
          ? _value._musclesSecondary
          : musclesSecondary // ignore: cast_nullable_to_non_nullable
              as List<Muscle>,
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<Equipment>,
      translations: null == translations
          ? _value._translations
          : translations // ignore: cast_nullable_to_non_nullable
              as List<Translation>,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ExerciseImage>,
      videos: null == videos
          ? _value._videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<Video>,
      authors: null == authors
          ? _value._authors
          : authors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      authorsGlobal: null == authorsGlobal
          ? _value._authorsGlobal
          : authorsGlobal // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseBaseDataImpl implements _ExerciseBaseData {
  _$ExerciseBaseDataImpl(
      {required this.id,
      required this.uuid,
      @JsonKey(name: 'variations') this.variationId = null,
      @JsonKey(name: 'created') required this.created,
      @JsonKey(name: 'last_update') required this.lastUpdate,
      @JsonKey(name: 'last_update_global') required this.lastUpdateGlobal,
      required this.category,
      required final List<Muscle> muscles,
      @JsonKey(name: 'muscles_secondary')
      required final List<Muscle> musclesSecondary,
      required final List<Equipment> equipment,
      @JsonKey(name: 'exercises') required final List<Translation> translations,
      required final List<ExerciseImage> images,
      required final List<Video> videos,
      @JsonKey(name: 'author_history') required final List<String> authors,
      @JsonKey(name: 'total_authors_history')
      required final List<String> authorsGlobal})
      : _muscles = muscles,
        _musclesSecondary = musclesSecondary,
        _equipment = equipment,
        _translations = translations,
        _images = images,
        _videos = videos,
        _authors = authors,
        _authorsGlobal = authorsGlobal;

  factory _$ExerciseBaseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseBaseDataImplFromJson(json);

  @override
  final int id;
  @override
  final String uuid;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'variations')
  final int? variationId;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'created')
  final DateTime created;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'last_update')
  final DateTime lastUpdate;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'last_update_global')
  final DateTime lastUpdateGlobal;
  @override
  final ExerciseCategory category;
  final List<Muscle> _muscles;
  @override
  List<Muscle> get muscles {
    if (_muscles is EqualUnmodifiableListView) return _muscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_muscles);
  }

// ignore: invalid_annotation_target
  final List<Muscle> _musclesSecondary;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'muscles_secondary')
  List<Muscle> get musclesSecondary {
    if (_musclesSecondary is EqualUnmodifiableListView)
      return _musclesSecondary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_musclesSecondary);
  }

// ignore: invalid_annotation_target
  final List<Equipment> _equipment;
// ignore: invalid_annotation_target
  @override
  List<Equipment> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

// ignore: invalid_annotation_target
  final List<Translation> _translations;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'exercises')
  List<Translation> get translations {
    if (_translations is EqualUnmodifiableListView) return _translations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_translations);
  }

  final List<ExerciseImage> _images;
  @override
  List<ExerciseImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<Video> _videos;
  @override
  List<Video> get videos {
    if (_videos is EqualUnmodifiableListView) return _videos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_videos);
  }

// ignore: invalid_annotation_target
  final List<String> _authors;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'author_history')
  List<String> get authors {
    if (_authors is EqualUnmodifiableListView) return _authors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_authors);
  }

// ignore: invalid_annotation_target
  final List<String> _authorsGlobal;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'total_authors_history')
  List<String> get authorsGlobal {
    if (_authorsGlobal is EqualUnmodifiableListView) return _authorsGlobal;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_authorsGlobal);
  }

  @override
  String toString() {
    return 'ExerciseApiData(id: $id, uuid: $uuid, variationId: $variationId, created: $created, lastUpdate: $lastUpdate, lastUpdateGlobal: $lastUpdateGlobal, category: $category, muscles: $muscles, musclesSecondary: $musclesSecondary, equipment: $equipment, translations: $translations, images: $images, videos: $videos, authors: $authors, authorsGlobal: $authorsGlobal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseBaseDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.variationId, variationId) ||
                other.variationId == variationId) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate) &&
            (identical(other.lastUpdateGlobal, lastUpdateGlobal) ||
                other.lastUpdateGlobal == lastUpdateGlobal) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._muscles, _muscles) &&
            const DeepCollectionEquality()
                .equals(other._musclesSecondary, _musclesSecondary) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment) &&
            const DeepCollectionEquality()
                .equals(other._translations, _translations) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._videos, _videos) &&
            const DeepCollectionEquality().equals(other._authors, _authors) &&
            const DeepCollectionEquality()
                .equals(other._authorsGlobal, _authorsGlobal));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      uuid,
      variationId,
      created,
      lastUpdate,
      lastUpdateGlobal,
      category,
      const DeepCollectionEquality().hash(_muscles),
      const DeepCollectionEquality().hash(_musclesSecondary),
      const DeepCollectionEquality().hash(_equipment),
      const DeepCollectionEquality().hash(_translations),
      const DeepCollectionEquality().hash(_images),
      const DeepCollectionEquality().hash(_videos),
      const DeepCollectionEquality().hash(_authors),
      const DeepCollectionEquality().hash(_authorsGlobal));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseBaseDataImplCopyWith<_$ExerciseBaseDataImpl> get copyWith =>
      __$$ExerciseBaseDataImplCopyWithImpl<_$ExerciseBaseDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseBaseDataImplToJson(
      this,
    );
  }
}

abstract class _ExerciseBaseData implements ExerciseApiData {
  factory _ExerciseBaseData(
      {required final int id,
      required final String uuid,
      @JsonKey(name: 'variations') final int? variationId,
      @JsonKey(name: 'created') required final DateTime created,
      @JsonKey(name: 'last_update') required final DateTime lastUpdate,
      @JsonKey(name: 'last_update_global')
      required final DateTime lastUpdateGlobal,
      required final ExerciseCategory category,
      required final List<Muscle> muscles,
      @JsonKey(name: 'muscles_secondary')
      required final List<Muscle> musclesSecondary,
      required final List<Equipment> equipment,
      @JsonKey(name: 'exercises') required final List<Translation> translations,
      required final List<ExerciseImage> images,
      required final List<Video> videos,
      @JsonKey(name: 'author_history') required final List<String> authors,
      @JsonKey(name: 'total_authors_history')
      required final List<String> authorsGlobal}) = _$ExerciseBaseDataImpl;

  factory _ExerciseBaseData.fromJson(Map<String, dynamic> json) =
      _$ExerciseBaseDataImpl.fromJson;

  @override
  int get id;
  @override
  String get uuid;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'variations')
  int? get variationId;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'created')
  DateTime get created;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'last_update')
  DateTime get lastUpdate;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'last_update_global')
  DateTime get lastUpdateGlobal;
  @override
  ExerciseCategory get category;
  @override
  List<Muscle> get muscles;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'muscles_secondary')
  List<Muscle> get musclesSecondary;
  @override // ignore: invalid_annotation_target
  List<Equipment> get equipment;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'exercises')
  List<Translation> get translations;
  @override
  List<ExerciseImage> get images;
  @override
  List<Video> get videos;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'author_history')
  List<String> get authors;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'total_authors_history')
  List<String> get authorsGlobal;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseBaseDataImplCopyWith<_$ExerciseBaseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExerciseSearchDetails _$ExerciseSearchDetailsFromJson(
    Map<String, dynamic> json) {
  return _ExerciseSearchDetails.fromJson(json);
}

/// @nodoc
mixin _$ExerciseSearchDetails {
// ignore: invalid_annotation_target
  @JsonKey(name: 'id')
  int get translationId =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'base_id')
  int get exerciseId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get image =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'image_thumbnail')
  String? get imageThumbnail => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseSearchDetailsCopyWith<ExerciseSearchDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseSearchDetailsCopyWith<$Res> {
  factory $ExerciseSearchDetailsCopyWith(ExerciseSearchDetails value,
          $Res Function(ExerciseSearchDetails) then) =
      _$ExerciseSearchDetailsCopyWithImpl<$Res, ExerciseSearchDetails>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int translationId,
      @JsonKey(name: 'base_id') int exerciseId,
      String name,
      String category,
      String? image,
      @JsonKey(name: 'image_thumbnail') String? imageThumbnail});
}

/// @nodoc
class _$ExerciseSearchDetailsCopyWithImpl<$Res,
        $Val extends ExerciseSearchDetails>
    implements $ExerciseSearchDetailsCopyWith<$Res> {
  _$ExerciseSearchDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? translationId = null,
    Object? exerciseId = null,
    Object? name = null,
    Object? category = null,
    Object? image = freezed,
    Object? imageThumbnail = freezed,
  }) {
    return _then(_value.copyWith(
      translationId: null == translationId
          ? _value.translationId
          : translationId // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      imageThumbnail: freezed == imageThumbnail
          ? _value.imageThumbnail
          : imageThumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseSearchDetailsImplCopyWith<$Res>
    implements $ExerciseSearchDetailsCopyWith<$Res> {
  factory _$$ExerciseSearchDetailsImplCopyWith(
          _$ExerciseSearchDetailsImpl value,
          $Res Function(_$ExerciseSearchDetailsImpl) then) =
      __$$ExerciseSearchDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int translationId,
      @JsonKey(name: 'base_id') int exerciseId,
      String name,
      String category,
      String? image,
      @JsonKey(name: 'image_thumbnail') String? imageThumbnail});
}

/// @nodoc
class __$$ExerciseSearchDetailsImplCopyWithImpl<$Res>
    extends _$ExerciseSearchDetailsCopyWithImpl<$Res,
        _$ExerciseSearchDetailsImpl>
    implements _$$ExerciseSearchDetailsImplCopyWith<$Res> {
  __$$ExerciseSearchDetailsImplCopyWithImpl(_$ExerciseSearchDetailsImpl _value,
      $Res Function(_$ExerciseSearchDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? translationId = null,
    Object? exerciseId = null,
    Object? name = null,
    Object? category = null,
    Object? image = freezed,
    Object? imageThumbnail = freezed,
  }) {
    return _then(_$ExerciseSearchDetailsImpl(
      translationId: null == translationId
          ? _value.translationId
          : translationId // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      imageThumbnail: freezed == imageThumbnail
          ? _value.imageThumbnail
          : imageThumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseSearchDetailsImpl implements _ExerciseSearchDetails {
  _$ExerciseSearchDetailsImpl(
      {@JsonKey(name: 'id') required this.translationId,
      @JsonKey(name: 'base_id') required this.exerciseId,
      required this.name,
      required this.category,
      required this.image,
      @JsonKey(name: 'image_thumbnail') required this.imageThumbnail});

  factory _$ExerciseSearchDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseSearchDetailsImplFromJson(json);

// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'id')
  final int translationId;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'base_id')
  final int exerciseId;
  @override
  final String name;
  @override
  final String category;
  @override
  final String? image;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'image_thumbnail')
  final String? imageThumbnail;

  @override
  String toString() {
    return 'ExerciseSearchDetails(translationId: $translationId, exerciseId: $exerciseId, name: $name, category: $category, image: $image, imageThumbnail: $imageThumbnail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseSearchDetailsImpl &&
            (identical(other.translationId, translationId) ||
                other.translationId == translationId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.imageThumbnail, imageThumbnail) ||
                other.imageThumbnail == imageThumbnail));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, translationId, exerciseId, name,
      category, image, imageThumbnail);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseSearchDetailsImplCopyWith<_$ExerciseSearchDetailsImpl>
      get copyWith => __$$ExerciseSearchDetailsImplCopyWithImpl<
          _$ExerciseSearchDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseSearchDetailsImplToJson(
      this,
    );
  }
}

abstract class _ExerciseSearchDetails implements ExerciseSearchDetails {
  factory _ExerciseSearchDetails(
      {@JsonKey(name: 'id') required final int translationId,
      @JsonKey(name: 'base_id') required final int exerciseId,
      required final String name,
      required final String category,
      required final String? image,
      @JsonKey(name: 'image_thumbnail')
      required final String? imageThumbnail}) = _$ExerciseSearchDetailsImpl;

  factory _ExerciseSearchDetails.fromJson(Map<String, dynamic> json) =
      _$ExerciseSearchDetailsImpl.fromJson;

  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'id')
  int get translationId;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'base_id')
  int get exerciseId;
  @override
  String get name;
  @override
  String get category;
  @override
  String? get image;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'image_thumbnail')
  String? get imageThumbnail;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseSearchDetailsImplCopyWith<_$ExerciseSearchDetailsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ExerciseSearchEntry _$ExerciseSearchEntryFromJson(Map<String, dynamic> json) {
  return _ExerciseSearchEntry.fromJson(json);
}

/// @nodoc
mixin _$ExerciseSearchEntry {
  String get value => throw _privateConstructorUsedError;
  ExerciseSearchDetails get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseSearchEntryCopyWith<ExerciseSearchEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseSearchEntryCopyWith<$Res> {
  factory $ExerciseSearchEntryCopyWith(
          ExerciseSearchEntry value, $Res Function(ExerciseSearchEntry) then) =
      _$ExerciseSearchEntryCopyWithImpl<$Res, ExerciseSearchEntry>;
  @useResult
  $Res call({String value, ExerciseSearchDetails data});

  $ExerciseSearchDetailsCopyWith<$Res> get data;
}

/// @nodoc
class _$ExerciseSearchEntryCopyWithImpl<$Res, $Val extends ExerciseSearchEntry>
    implements $ExerciseSearchEntryCopyWith<$Res> {
  _$ExerciseSearchEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as ExerciseSearchDetails,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ExerciseSearchDetailsCopyWith<$Res> get data {
    return $ExerciseSearchDetailsCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExerciseSearchEntryImplCopyWith<$Res>
    implements $ExerciseSearchEntryCopyWith<$Res> {
  factory _$$ExerciseSearchEntryImplCopyWith(_$ExerciseSearchEntryImpl value,
          $Res Function(_$ExerciseSearchEntryImpl) then) =
      __$$ExerciseSearchEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, ExerciseSearchDetails data});

  @override
  $ExerciseSearchDetailsCopyWith<$Res> get data;
}

/// @nodoc
class __$$ExerciseSearchEntryImplCopyWithImpl<$Res>
    extends _$ExerciseSearchEntryCopyWithImpl<$Res, _$ExerciseSearchEntryImpl>
    implements _$$ExerciseSearchEntryImplCopyWith<$Res> {
  __$$ExerciseSearchEntryImplCopyWithImpl(_$ExerciseSearchEntryImpl _value,
      $Res Function(_$ExerciseSearchEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? data = null,
  }) {
    return _then(_$ExerciseSearchEntryImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as ExerciseSearchDetails,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseSearchEntryImpl implements _ExerciseSearchEntry {
  _$ExerciseSearchEntryImpl({required this.value, required this.data});

  factory _$ExerciseSearchEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseSearchEntryImplFromJson(json);

  @override
  final String value;
  @override
  final ExerciseSearchDetails data;

  @override
  String toString() {
    return 'ExerciseSearchEntry(value: $value, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseSearchEntryImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, value, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseSearchEntryImplCopyWith<_$ExerciseSearchEntryImpl> get copyWith =>
      __$$ExerciseSearchEntryImplCopyWithImpl<_$ExerciseSearchEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseSearchEntryImplToJson(
      this,
    );
  }
}

abstract class _ExerciseSearchEntry implements ExerciseSearchEntry {
  factory _ExerciseSearchEntry(
      {required final String value,
      required final ExerciseSearchDetails data}) = _$ExerciseSearchEntryImpl;

  factory _ExerciseSearchEntry.fromJson(Map<String, dynamic> json) =
      _$ExerciseSearchEntryImpl.fromJson;

  @override
  String get value;
  @override
  ExerciseSearchDetails get data;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseSearchEntryImplCopyWith<_$ExerciseSearchEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExerciseApiSearch _$ExerciseApiSearchFromJson(Map<String, dynamic> json) {
  return _ExerciseApiSearch.fromJson(json);
}

/// @nodoc
mixin _$ExerciseApiSearch {
  List<ExerciseSearchEntry> get suggestions =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseApiSearchCopyWith<ExerciseApiSearch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseApiSearchCopyWith<$Res> {
  factory $ExerciseApiSearchCopyWith(
          ExerciseApiSearch value, $Res Function(ExerciseApiSearch) then) =
      _$ExerciseApiSearchCopyWithImpl<$Res, ExerciseApiSearch>;
  @useResult
  $Res call({List<ExerciseSearchEntry> suggestions});
}

/// @nodoc
class _$ExerciseApiSearchCopyWithImpl<$Res, $Val extends ExerciseApiSearch>
    implements $ExerciseApiSearchCopyWith<$Res> {
  _$ExerciseApiSearchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestions = null,
  }) {
    return _then(_value.copyWith(
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSearchEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseApiSearchImplCopyWith<$Res>
    implements $ExerciseApiSearchCopyWith<$Res> {
  factory _$$ExerciseApiSearchImplCopyWith(_$ExerciseApiSearchImpl value,
          $Res Function(_$ExerciseApiSearchImpl) then) =
      __$$ExerciseApiSearchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ExerciseSearchEntry> suggestions});
}

/// @nodoc
class __$$ExerciseApiSearchImplCopyWithImpl<$Res>
    extends _$ExerciseApiSearchCopyWithImpl<$Res, _$ExerciseApiSearchImpl>
    implements _$$ExerciseApiSearchImplCopyWith<$Res> {
  __$$ExerciseApiSearchImplCopyWithImpl(_$ExerciseApiSearchImpl _value,
      $Res Function(_$ExerciseApiSearchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestions = null,
  }) {
    return _then(_$ExerciseApiSearchImpl(
      suggestions: null == suggestions
          ? _value._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSearchEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseApiSearchImpl implements _ExerciseApiSearch {
  _$ExerciseApiSearchImpl(
      {required final List<ExerciseSearchEntry> suggestions})
      : _suggestions = suggestions;

  factory _$ExerciseApiSearchImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseApiSearchImplFromJson(json);

  final List<ExerciseSearchEntry> _suggestions;
  @override
  List<ExerciseSearchEntry> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  String toString() {
    return 'ExerciseApiSearch(suggestions: $suggestions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseApiSearchImpl &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_suggestions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseApiSearchImplCopyWith<_$ExerciseApiSearchImpl> get copyWith =>
      __$$ExerciseApiSearchImplCopyWithImpl<_$ExerciseApiSearchImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseApiSearchImplToJson(
      this,
    );
  }
}

abstract class _ExerciseApiSearch implements ExerciseApiSearch {
  factory _ExerciseApiSearch(
          {required final List<ExerciseSearchEntry> suggestions}) =
      _$ExerciseApiSearchImpl;

  factory _ExerciseApiSearch.fromJson(Map<String, dynamic> json) =
      _$ExerciseApiSearchImpl.fromJson;

  @override
  List<ExerciseSearchEntry> get suggestions;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseApiSearchImplCopyWith<_$ExerciseApiSearchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
