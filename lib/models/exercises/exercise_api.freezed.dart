// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
ExerciseApiData _$ExerciseApiDataFromJson(Map<String, dynamic> json) {
  return _ExerciseBaseData.fromJson(json);
}

/// @nodoc
mixin _$ExerciseApiData {
  int get id;
  String get uuid; // ignore: invalid_annotation_target
  @JsonKey(name: 'variations')
  int? get variationId; // ignore: invalid_annotation_target
  @JsonKey(name: 'created')
  DateTime get created; // ignore: invalid_annotation_target
  @JsonKey(name: 'last_update')
  DateTime get lastUpdate; // ignore: invalid_annotation_target
  @JsonKey(name: 'last_update_global')
  DateTime get lastUpdateGlobal;
  ExerciseCategory get category;
  List<Muscle> get muscles; // ignore: invalid_annotation_target
  @JsonKey(name: 'muscles_secondary')
  List<Muscle> get musclesSecondary; // ignore: invalid_annotation_target
  List<Equipment> get equipment; // ignore: invalid_annotation_target
  @JsonKey(name: 'translations', defaultValue: [])
  List<Translation> get translations;
  List<ExerciseImage> get images;
  List<Video> get videos; // ignore: invalid_annotation_target
  @JsonKey(name: 'author_history')
  List<String> get authors; // ignore: invalid_annotation_target
  @JsonKey(name: 'total_authors_history')
  List<String> get authorsGlobal;

  /// Create a copy of ExerciseApiData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseApiDataCopyWith<ExerciseApiData> get copyWith =>
      _$ExerciseApiDataCopyWithImpl<ExerciseApiData>(this as ExerciseApiData, _$identity);

  /// Serializes this ExerciseApiData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExerciseApiData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.variationId, variationId) || other.variationId == variationId) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.lastUpdate, lastUpdate) || other.lastUpdate == lastUpdate) &&
            (identical(other.lastUpdateGlobal, lastUpdateGlobal) ||
                other.lastUpdateGlobal == lastUpdateGlobal) &&
            (identical(other.category, category) || other.category == category) &&
            const DeepCollectionEquality().equals(other.muscles, muscles) &&
            const DeepCollectionEquality().equals(other.musclesSecondary, musclesSecondary) &&
            const DeepCollectionEquality().equals(other.equipment, equipment) &&
            const DeepCollectionEquality().equals(other.translations, translations) &&
            const DeepCollectionEquality().equals(other.images, images) &&
            const DeepCollectionEquality().equals(other.videos, videos) &&
            const DeepCollectionEquality().equals(other.authors, authors) &&
            const DeepCollectionEquality().equals(other.authorsGlobal, authorsGlobal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
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
      const DeepCollectionEquality().hash(muscles),
      const DeepCollectionEquality().hash(musclesSecondary),
      const DeepCollectionEquality().hash(equipment),
      const DeepCollectionEquality().hash(translations),
      const DeepCollectionEquality().hash(images),
      const DeepCollectionEquality().hash(videos),
      const DeepCollectionEquality().hash(authors),
      const DeepCollectionEquality().hash(authorsGlobal));

  @override
  String toString() {
    return 'ExerciseApiData(id: $id, uuid: $uuid, variationId: $variationId, created: $created, lastUpdate: $lastUpdate, lastUpdateGlobal: $lastUpdateGlobal, category: $category, muscles: $muscles, musclesSecondary: $musclesSecondary, equipment: $equipment, translations: $translations, images: $images, videos: $videos, authors: $authors, authorsGlobal: $authorsGlobal)';
  }
}

/// @nodoc
abstract mixin class $ExerciseApiDataCopyWith<$Res> {
  factory $ExerciseApiDataCopyWith(ExerciseApiData value, $Res Function(ExerciseApiData) _then) =
      _$ExerciseApiDataCopyWithImpl;
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
      @JsonKey(name: 'translations', defaultValue: []) List<Translation> translations,
      List<ExerciseImage> images,
      List<Video> videos,
      @JsonKey(name: 'author_history') List<String> authors,
      @JsonKey(name: 'total_authors_history') List<String> authorsGlobal});
}

/// @nodoc
class _$ExerciseApiDataCopyWithImpl<$Res> implements $ExerciseApiDataCopyWith<$Res> {
  _$ExerciseApiDataCopyWithImpl(this._self, this._then);

  final ExerciseApiData _self;
  final $Res Function(ExerciseApiData) _then;

  /// Create a copy of ExerciseApiData
  /// with the given fields replaced by the non-null parameter values.
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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      variationId: freezed == variationId
          ? _self.variationId
          : variationId // ignore: cast_nullable_to_non_nullable
              as int?,
      created: null == created
          ? _self.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdate: null == lastUpdate
          ? _self.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdateGlobal: null == lastUpdateGlobal
          ? _self.lastUpdateGlobal
          : lastUpdateGlobal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as ExerciseCategory,
      muscles: null == muscles
          ? _self.muscles
          : muscles // ignore: cast_nullable_to_non_nullable
              as List<Muscle>,
      musclesSecondary: null == musclesSecondary
          ? _self.musclesSecondary
          : musclesSecondary // ignore: cast_nullable_to_non_nullable
              as List<Muscle>,
      equipment: null == equipment
          ? _self.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<Equipment>,
      translations: null == translations
          ? _self.translations
          : translations // ignore: cast_nullable_to_non_nullable
              as List<Translation>,
      images: null == images
          ? _self.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ExerciseImage>,
      videos: null == videos
          ? _self.videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<Video>,
      authors: null == authors
          ? _self.authors
          : authors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      authorsGlobal: null == authorsGlobal
          ? _self.authorsGlobal
          : authorsGlobal // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ExerciseBaseData implements ExerciseApiData {
  _ExerciseBaseData(
      {required this.id,
      required this.uuid,
      @JsonKey(name: 'variations') this.variationId = null,
      @JsonKey(name: 'created') required this.created,
      @JsonKey(name: 'last_update') required this.lastUpdate,
      @JsonKey(name: 'last_update_global') required this.lastUpdateGlobal,
      required this.category,
      required final List<Muscle> muscles,
      @JsonKey(name: 'muscles_secondary') required final List<Muscle> musclesSecondary,
      required final List<Equipment> equipment,
      @JsonKey(name: 'translations', defaultValue: [])
      required final List<Translation> translations,
      required final List<ExerciseImage> images,
      required final List<Video> videos,
      @JsonKey(name: 'author_history') required final List<String> authors,
      @JsonKey(name: 'total_authors_history') required final List<String> authorsGlobal})
      : _muscles = muscles,
        _musclesSecondary = musclesSecondary,
        _equipment = equipment,
        _translations = translations,
        _images = images,
        _videos = videos,
        _authors = authors,
        _authorsGlobal = authorsGlobal;
  factory _ExerciseBaseData.fromJson(Map<String, dynamic> json) => _$ExerciseBaseDataFromJson(json);

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
    if (_musclesSecondary is EqualUnmodifiableListView) return _musclesSecondary;
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
  @JsonKey(name: 'translations', defaultValue: [])
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

  /// Create a copy of ExerciseApiData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseBaseDataCopyWith<_ExerciseBaseData> get copyWith =>
      __$ExerciseBaseDataCopyWithImpl<_ExerciseBaseData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseBaseDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExerciseBaseData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.variationId, variationId) || other.variationId == variationId) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.lastUpdate, lastUpdate) || other.lastUpdate == lastUpdate) &&
            (identical(other.lastUpdateGlobal, lastUpdateGlobal) ||
                other.lastUpdateGlobal == lastUpdateGlobal) &&
            (identical(other.category, category) || other.category == category) &&
            const DeepCollectionEquality().equals(other._muscles, _muscles) &&
            const DeepCollectionEquality().equals(other._musclesSecondary, _musclesSecondary) &&
            const DeepCollectionEquality().equals(other._equipment, _equipment) &&
            const DeepCollectionEquality().equals(other._translations, _translations) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._videos, _videos) &&
            const DeepCollectionEquality().equals(other._authors, _authors) &&
            const DeepCollectionEquality().equals(other._authorsGlobal, _authorsGlobal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  @override
  String toString() {
    return 'ExerciseApiData(id: $id, uuid: $uuid, variationId: $variationId, created: $created, lastUpdate: $lastUpdate, lastUpdateGlobal: $lastUpdateGlobal, category: $category, muscles: $muscles, musclesSecondary: $musclesSecondary, equipment: $equipment, translations: $translations, images: $images, videos: $videos, authors: $authors, authorsGlobal: $authorsGlobal)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseBaseDataCopyWith<$Res> implements $ExerciseApiDataCopyWith<$Res> {
  factory _$ExerciseBaseDataCopyWith(
          _ExerciseBaseData value, $Res Function(_ExerciseBaseData) _then) =
      __$ExerciseBaseDataCopyWithImpl;
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
      @JsonKey(name: 'translations', defaultValue: []) List<Translation> translations,
      List<ExerciseImage> images,
      List<Video> videos,
      @JsonKey(name: 'author_history') List<String> authors,
      @JsonKey(name: 'total_authors_history') List<String> authorsGlobal});
}

/// @nodoc
class __$ExerciseBaseDataCopyWithImpl<$Res> implements _$ExerciseBaseDataCopyWith<$Res> {
  __$ExerciseBaseDataCopyWithImpl(this._self, this._then);

  final _ExerciseBaseData _self;
  final $Res Function(_ExerciseBaseData) _then;

  /// Create a copy of ExerciseApiData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_ExerciseBaseData(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      variationId: freezed == variationId
          ? _self.variationId
          : variationId // ignore: cast_nullable_to_non_nullable
              as int?,
      created: null == created
          ? _self.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdate: null == lastUpdate
          ? _self.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdateGlobal: null == lastUpdateGlobal
          ? _self.lastUpdateGlobal
          : lastUpdateGlobal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as ExerciseCategory,
      muscles: null == muscles
          ? _self._muscles
          : muscles // ignore: cast_nullable_to_non_nullable
              as List<Muscle>,
      musclesSecondary: null == musclesSecondary
          ? _self._musclesSecondary
          : musclesSecondary // ignore: cast_nullable_to_non_nullable
              as List<Muscle>,
      equipment: null == equipment
          ? _self._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<Equipment>,
      translations: null == translations
          ? _self._translations
          : translations // ignore: cast_nullable_to_non_nullable
              as List<Translation>,
      images: null == images
          ? _self._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ExerciseImage>,
      videos: null == videos
          ? _self._videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<Video>,
      authors: null == authors
          ? _self._authors
          : authors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      authorsGlobal: null == authorsGlobal
          ? _self._authorsGlobal
          : authorsGlobal // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
mixin _$ExerciseSearchDetails {
// ignore: invalid_annotation_target
  @JsonKey(name: 'id')
  int get translationId; // ignore: invalid_annotation_target
  @JsonKey(name: 'base_id')
  int get exerciseId;
  String get name;
  String get category;
  String? get image; // ignore: invalid_annotation_target
  @JsonKey(name: 'image_thumbnail')
  String? get imageThumbnail;

  /// Create a copy of ExerciseSearchDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseSearchDetailsCopyWith<ExerciseSearchDetails> get copyWith =>
      _$ExerciseSearchDetailsCopyWithImpl<ExerciseSearchDetails>(
          this as ExerciseSearchDetails, _$identity);

  /// Serializes this ExerciseSearchDetails to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExerciseSearchDetails &&
            (identical(other.translationId, translationId) ||
                other.translationId == translationId) &&
            (identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) || other.category == category) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.imageThumbnail, imageThumbnail) ||
                other.imageThumbnail == imageThumbnail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, translationId, exerciseId, name, category, image, imageThumbnail);

  @override
  String toString() {
    return 'ExerciseSearchDetails(translationId: $translationId, exerciseId: $exerciseId, name: $name, category: $category, image: $image, imageThumbnail: $imageThumbnail)';
  }
}

/// @nodoc
abstract mixin class $ExerciseSearchDetailsCopyWith<$Res> {
  factory $ExerciseSearchDetailsCopyWith(
          ExerciseSearchDetails value, $Res Function(ExerciseSearchDetails) _then) =
      _$ExerciseSearchDetailsCopyWithImpl;
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
class _$ExerciseSearchDetailsCopyWithImpl<$Res> implements $ExerciseSearchDetailsCopyWith<$Res> {
  _$ExerciseSearchDetailsCopyWithImpl(this._self, this._then);

  final ExerciseSearchDetails _self;
  final $Res Function(ExerciseSearchDetails) _then;

  /// Create a copy of ExerciseSearchDetails
  /// with the given fields replaced by the non-null parameter values.
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
    return _then(_self.copyWith(
      translationId: null == translationId
          ? _self.translationId
          : translationId // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _self.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      image: freezed == image
          ? _self.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      imageThumbnail: freezed == imageThumbnail
          ? _self.imageThumbnail
          : imageThumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ExerciseSearchDetails implements ExerciseSearchDetails {
  _ExerciseSearchDetails(
      {@JsonKey(name: 'id') required this.translationId,
      @JsonKey(name: 'base_id') required this.exerciseId,
      required this.name,
      required this.category,
      required this.image,
      @JsonKey(name: 'image_thumbnail') required this.imageThumbnail});
  factory _ExerciseSearchDetails.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSearchDetailsFromJson(json);

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

  /// Create a copy of ExerciseSearchDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseSearchDetailsCopyWith<_ExerciseSearchDetails> get copyWith =>
      __$ExerciseSearchDetailsCopyWithImpl<_ExerciseSearchDetails>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseSearchDetailsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExerciseSearchDetails &&
            (identical(other.translationId, translationId) ||
                other.translationId == translationId) &&
            (identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) || other.category == category) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.imageThumbnail, imageThumbnail) ||
                other.imageThumbnail == imageThumbnail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, translationId, exerciseId, name, category, image, imageThumbnail);

  @override
  String toString() {
    return 'ExerciseSearchDetails(translationId: $translationId, exerciseId: $exerciseId, name: $name, category: $category, image: $image, imageThumbnail: $imageThumbnail)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseSearchDetailsCopyWith<$Res>
    implements $ExerciseSearchDetailsCopyWith<$Res> {
  factory _$ExerciseSearchDetailsCopyWith(
          _ExerciseSearchDetails value, $Res Function(_ExerciseSearchDetails) _then) =
      __$ExerciseSearchDetailsCopyWithImpl;
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
class __$ExerciseSearchDetailsCopyWithImpl<$Res> implements _$ExerciseSearchDetailsCopyWith<$Res> {
  __$ExerciseSearchDetailsCopyWithImpl(this._self, this._then);

  final _ExerciseSearchDetails _self;
  final $Res Function(_ExerciseSearchDetails) _then;

  /// Create a copy of ExerciseSearchDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? translationId = null,
    Object? exerciseId = null,
    Object? name = null,
    Object? category = null,
    Object? image = freezed,
    Object? imageThumbnail = freezed,
  }) {
    return _then(_ExerciseSearchDetails(
      translationId: null == translationId
          ? _self.translationId
          : translationId // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _self.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      image: freezed == image
          ? _self.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      imageThumbnail: freezed == imageThumbnail
          ? _self.imageThumbnail
          : imageThumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$ExerciseSearchEntry {
  String get value;
  ExerciseSearchDetails get data;

  /// Create a copy of ExerciseSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseSearchEntryCopyWith<ExerciseSearchEntry> get copyWith =>
      _$ExerciseSearchEntryCopyWithImpl<ExerciseSearchEntry>(
          this as ExerciseSearchEntry, _$identity);

  /// Serializes this ExerciseSearchEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExerciseSearchEntry &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, data);

  @override
  String toString() {
    return 'ExerciseSearchEntry(value: $value, data: $data)';
  }
}

/// @nodoc
abstract mixin class $ExerciseSearchEntryCopyWith<$Res> {
  factory $ExerciseSearchEntryCopyWith(
          ExerciseSearchEntry value, $Res Function(ExerciseSearchEntry) _then) =
      _$ExerciseSearchEntryCopyWithImpl;
  @useResult
  $Res call({String value, ExerciseSearchDetails data});

  $ExerciseSearchDetailsCopyWith<$Res> get data;
}

/// @nodoc
class _$ExerciseSearchEntryCopyWithImpl<$Res> implements $ExerciseSearchEntryCopyWith<$Res> {
  _$ExerciseSearchEntryCopyWithImpl(this._self, this._then);

  final ExerciseSearchEntry _self;
  final $Res Function(ExerciseSearchEntry) _then;

  /// Create a copy of ExerciseSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? data = null,
  }) {
    return _then(_self.copyWith(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as ExerciseSearchDetails,
    ));
  }

  /// Create a copy of ExerciseSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExerciseSearchDetailsCopyWith<$Res> get data {
    return $ExerciseSearchDetailsCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _ExerciseSearchEntry implements ExerciseSearchEntry {
  _ExerciseSearchEntry({required this.value, required this.data});
  factory _ExerciseSearchEntry.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSearchEntryFromJson(json);

  @override
  final String value;
  @override
  final ExerciseSearchDetails data;

  /// Create a copy of ExerciseSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseSearchEntryCopyWith<_ExerciseSearchEntry> get copyWith =>
      __$ExerciseSearchEntryCopyWithImpl<_ExerciseSearchEntry>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseSearchEntryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExerciseSearchEntry &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, data);

  @override
  String toString() {
    return 'ExerciseSearchEntry(value: $value, data: $data)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseSearchEntryCopyWith<$Res>
    implements $ExerciseSearchEntryCopyWith<$Res> {
  factory _$ExerciseSearchEntryCopyWith(
          _ExerciseSearchEntry value, $Res Function(_ExerciseSearchEntry) _then) =
      __$ExerciseSearchEntryCopyWithImpl;
  @override
  @useResult
  $Res call({String value, ExerciseSearchDetails data});

  @override
  $ExerciseSearchDetailsCopyWith<$Res> get data;
}

/// @nodoc
class __$ExerciseSearchEntryCopyWithImpl<$Res> implements _$ExerciseSearchEntryCopyWith<$Res> {
  __$ExerciseSearchEntryCopyWithImpl(this._self, this._then);

  final _ExerciseSearchEntry _self;
  final $Res Function(_ExerciseSearchEntry) _then;

  /// Create a copy of ExerciseSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
    Object? data = null,
  }) {
    return _then(_ExerciseSearchEntry(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as ExerciseSearchDetails,
    ));
  }

  /// Create a copy of ExerciseSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExerciseSearchDetailsCopyWith<$Res> get data {
    return $ExerciseSearchDetailsCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc
mixin _$ExerciseApiSearch {
  List<ExerciseSearchEntry> get suggestions;

  /// Create a copy of ExerciseApiSearch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseApiSearchCopyWith<ExerciseApiSearch> get copyWith =>
      _$ExerciseApiSearchCopyWithImpl<ExerciseApiSearch>(this as ExerciseApiSearch, _$identity);

  /// Serializes this ExerciseApiSearch to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExerciseApiSearch &&
            const DeepCollectionEquality().equals(other.suggestions, suggestions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(suggestions));

  @override
  String toString() {
    return 'ExerciseApiSearch(suggestions: $suggestions)';
  }
}

/// @nodoc
abstract mixin class $ExerciseApiSearchCopyWith<$Res> {
  factory $ExerciseApiSearchCopyWith(
          ExerciseApiSearch value, $Res Function(ExerciseApiSearch) _then) =
      _$ExerciseApiSearchCopyWithImpl;
  @useResult
  $Res call({List<ExerciseSearchEntry> suggestions});
}

/// @nodoc
class _$ExerciseApiSearchCopyWithImpl<$Res> implements $ExerciseApiSearchCopyWith<$Res> {
  _$ExerciseApiSearchCopyWithImpl(this._self, this._then);

  final ExerciseApiSearch _self;
  final $Res Function(ExerciseApiSearch) _then;

  /// Create a copy of ExerciseApiSearch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestions = null,
  }) {
    return _then(_self.copyWith(
      suggestions: null == suggestions
          ? _self.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSearchEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ExerciseApiSearch implements ExerciseApiSearch {
  _ExerciseApiSearch({required final List<ExerciseSearchEntry> suggestions})
      : _suggestions = suggestions;
  factory _ExerciseApiSearch.fromJson(Map<String, dynamic> json) =>
      _$ExerciseApiSearchFromJson(json);

  final List<ExerciseSearchEntry> _suggestions;
  @override
  List<ExerciseSearchEntry> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  /// Create a copy of ExerciseApiSearch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseApiSearchCopyWith<_ExerciseApiSearch> get copyWith =>
      __$ExerciseApiSearchCopyWithImpl<_ExerciseApiSearch>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseApiSearchToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExerciseApiSearch &&
            const DeepCollectionEquality().equals(other._suggestions, _suggestions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(_suggestions));

  @override
  String toString() {
    return 'ExerciseApiSearch(suggestions: $suggestions)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseApiSearchCopyWith<$Res> implements $ExerciseApiSearchCopyWith<$Res> {
  factory _$ExerciseApiSearchCopyWith(
          _ExerciseApiSearch value, $Res Function(_ExerciseApiSearch) _then) =
      __$ExerciseApiSearchCopyWithImpl;
  @override
  @useResult
  $Res call({List<ExerciseSearchEntry> suggestions});
}

/// @nodoc
class __$ExerciseApiSearchCopyWithImpl<$Res> implements _$ExerciseApiSearchCopyWith<$Res> {
  __$ExerciseApiSearchCopyWithImpl(this._self, this._then);

  final _ExerciseApiSearch _self;
  final $Res Function(_ExerciseApiSearch) _then;

  /// Create a copy of ExerciseApiSearch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? suggestions = null,
  }) {
    return _then(_ExerciseApiSearch(
      suggestions: null == suggestions
          ? _self._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSearchEntry>,
    ));
  }
}

// dart format on
