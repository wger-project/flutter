// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_base_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ExerciseBaseData _$ExerciseBaseDataFromJson(Map<String, dynamic> json) {
  return _ExerciseBaseData.fromJson(json);
}

/// @nodoc
mixin _$ExerciseBaseData {
  int get id => throw _privateConstructorUsedError;
  String get uuid => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'created')
  DateTime get created => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'last_update')
  DateTime get lastUpdate =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'last_update_global')
  DateTime get lastUpdateGlobal => throw _privateConstructorUsedError;
  ExerciseCategory get category => throw _privateConstructorUsedError;
  List<Muscle> get muscles =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'muscles_secondary')
  List<Muscle> get musclesSecondary => throw _privateConstructorUsedError;
  List<Equipment> get equipment => throw _privateConstructorUsedError;
  List<ExerciseData> get exercises => throw _privateConstructorUsedError;
  List<ExerciseImage> get images => throw _privateConstructorUsedError;
  List<Video> get videos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseBaseDataCopyWith<ExerciseBaseData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseBaseDataCopyWith<$Res> {
  factory $ExerciseBaseDataCopyWith(ExerciseBaseData value, $Res Function(ExerciseBaseData) then) =
      _$ExerciseBaseDataCopyWithImpl<$Res, ExerciseBaseData>;
  @useResult
  $Res call(
      {int id,
      String uuid,
      @JsonKey(name: 'created') DateTime created,
      @JsonKey(name: 'last_update') DateTime lastUpdate,
      @JsonKey(name: 'last_update_global') DateTime lastUpdateGlobal,
      ExerciseCategory category,
      List<Muscle> muscles,
      @JsonKey(name: 'muscles_secondary') List<Muscle> musclesSecondary,
      List<Equipment> equipment,
      List<ExerciseData> exercises,
      List<ExerciseImage> images,
      List<Video> videos});
}

/// @nodoc
class _$ExerciseBaseDataCopyWithImpl<$Res, $Val extends ExerciseBaseData>
    implements $ExerciseBaseDataCopyWith<$Res> {
  _$ExerciseBaseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uuid = null,
    Object? created = null,
    Object? lastUpdate = null,
    Object? lastUpdateGlobal = null,
    Object? category = null,
    Object? muscles = null,
    Object? musclesSecondary = null,
    Object? equipment = null,
    Object? exercises = null,
    Object? images = null,
    Object? videos = null,
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
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseData>,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ExerciseImage>,
      videos: null == videos
          ? _value.videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<Video>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseBaseDataImplCopyWith<$Res> implements $ExerciseBaseDataCopyWith<$Res> {
  factory _$$ExerciseBaseDataImplCopyWith(
          _$ExerciseBaseDataImpl value, $Res Function(_$ExerciseBaseDataImpl) then) =
      __$$ExerciseBaseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String uuid,
      @JsonKey(name: 'created') DateTime created,
      @JsonKey(name: 'last_update') DateTime lastUpdate,
      @JsonKey(name: 'last_update_global') DateTime lastUpdateGlobal,
      ExerciseCategory category,
      List<Muscle> muscles,
      @JsonKey(name: 'muscles_secondary') List<Muscle> musclesSecondary,
      List<Equipment> equipment,
      List<ExerciseData> exercises,
      List<ExerciseImage> images,
      List<Video> videos});
}

/// @nodoc
class __$$ExerciseBaseDataImplCopyWithImpl<$Res>
    extends _$ExerciseBaseDataCopyWithImpl<$Res, _$ExerciseBaseDataImpl>
    implements _$$ExerciseBaseDataImplCopyWith<$Res> {
  __$$ExerciseBaseDataImplCopyWithImpl(
      _$ExerciseBaseDataImpl _value, $Res Function(_$ExerciseBaseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uuid = null,
    Object? created = null,
    Object? lastUpdate = null,
    Object? lastUpdateGlobal = null,
    Object? category = null,
    Object? muscles = null,
    Object? musclesSecondary = null,
    Object? equipment = null,
    Object? exercises = null,
    Object? images = null,
    Object? videos = null,
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
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseData>,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ExerciseImage>,
      videos: null == videos
          ? _value._videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<Video>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseBaseDataImpl implements _ExerciseBaseData {
  _$ExerciseBaseDataImpl(
      {required this.id,
      required this.uuid,
      @JsonKey(name: 'created') required this.created,
      @JsonKey(name: 'last_update') required this.lastUpdate,
      @JsonKey(name: 'last_update_global') required this.lastUpdateGlobal,
      required this.category,
      required final List<Muscle> muscles,
      @JsonKey(name: 'muscles_secondary') required final List<Muscle> musclesSecondary,
      required final List<Equipment> equipment,
      required final List<ExerciseData> exercises,
      required final List<ExerciseImage> images,
      required final List<Video> videos})
      : _muscles = muscles,
        _musclesSecondary = musclesSecondary,
        _equipment = equipment,
        _exercises = exercises,
        _images = images,
        _videos = videos;

  factory _$ExerciseBaseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseBaseDataImplFromJson(json);

  @override
  final int id;
  @override
  final String uuid;
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

  final List<Equipment> _equipment;
  @override
  List<Equipment> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  final List<ExerciseData> _exercises;
  @override
  List<ExerciseData> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
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

  @override
  String toString() {
    return 'ExerciseBaseData(id: $id, uuid: $uuid, created: $created, lastUpdate: $lastUpdate, lastUpdateGlobal: $lastUpdateGlobal, category: $category, muscles: $muscles, musclesSecondary: $musclesSecondary, equipment: $equipment, exercises: $exercises, images: $images, videos: $videos)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseBaseDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.lastUpdate, lastUpdate) || other.lastUpdate == lastUpdate) &&
            (identical(other.lastUpdateGlobal, lastUpdateGlobal) ||
                other.lastUpdateGlobal == lastUpdateGlobal) &&
            (identical(other.category, category) || other.category == category) &&
            const DeepCollectionEquality().equals(other._muscles, _muscles) &&
            const DeepCollectionEquality().equals(other._musclesSecondary, _musclesSecondary) &&
            const DeepCollectionEquality().equals(other._equipment, _equipment) &&
            const DeepCollectionEquality().equals(other._exercises, _exercises) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._videos, _videos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      uuid,
      created,
      lastUpdate,
      lastUpdateGlobal,
      category,
      const DeepCollectionEquality().hash(_muscles),
      const DeepCollectionEquality().hash(_musclesSecondary),
      const DeepCollectionEquality().hash(_equipment),
      const DeepCollectionEquality().hash(_exercises),
      const DeepCollectionEquality().hash(_images),
      const DeepCollectionEquality().hash(_videos));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseBaseDataImplCopyWith<_$ExerciseBaseDataImpl> get copyWith =>
      __$$ExerciseBaseDataImplCopyWithImpl<_$ExerciseBaseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseBaseDataImplToJson(
      this,
    );
  }
}

abstract class _ExerciseBaseData implements ExerciseBaseData {
  factory _ExerciseBaseData(
      {required final int id,
      required final String uuid,
      @JsonKey(name: 'created') required final DateTime created,
      @JsonKey(name: 'last_update') required final DateTime lastUpdate,
      @JsonKey(name: 'last_update_global') required final DateTime lastUpdateGlobal,
      required final ExerciseCategory category,
      required final List<Muscle> muscles,
      @JsonKey(name: 'muscles_secondary') required final List<Muscle> musclesSecondary,
      required final List<Equipment> equipment,
      required final List<ExerciseData> exercises,
      required final List<ExerciseImage> images,
      required final List<Video> videos}) = _$ExerciseBaseDataImpl;

  factory _ExerciseBaseData.fromJson(Map<String, dynamic> json) = _$ExerciseBaseDataImpl.fromJson;

  @override
  int get id;
  @override
  String get uuid;
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
  @override
  List<Equipment> get equipment;
  @override
  List<ExerciseData> get exercises;
  @override
  List<ExerciseImage> get images;
  @override
  List<Video> get videos;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseBaseDataImplCopyWith<_$ExerciseBaseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
