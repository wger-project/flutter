// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ExerciseData _$ExerciseDataFromJson(Map<String, dynamic> json) {
  return _ExerciseData.fromJson(json);
}

/// @nodoc
mixin _$ExerciseData {
  int get id => throw _privateConstructorUsedError;
  String get uuid => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'language')
  int get languageId => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(required: true, name: 'exercise_base')
  int get exerciseId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<Alias> get aliases => throw _privateConstructorUsedError;
  List<Comment> get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseDataCopyWith<ExerciseData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseDataCopyWith<$Res> {
  factory $ExerciseDataCopyWith(ExerciseData value, $Res Function(ExerciseData) then) =
      _$ExerciseDataCopyWithImpl<$Res, ExerciseData>;
  @useResult
  $Res call(
      {int id,
      String uuid,
      @JsonKey(name: 'language') int languageId,
      @JsonKey(required: true, name: 'exercise_base') int exerciseId,
      String description,
      String name,
      List<Alias> aliases,
      List<Comment> notes});
}

/// @nodoc
class _$ExerciseDataCopyWithImpl<$Res, $Val extends ExerciseData>
    implements $ExerciseDataCopyWith<$Res> {
  _$ExerciseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uuid = null,
    Object? languageId = null,
    Object? exerciseId = null,
    Object? description = null,
    Object? name = null,
    Object? aliases = null,
    Object? notes = null,
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
      languageId: null == languageId
          ? _value.languageId
          : languageId // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      aliases: null == aliases
          ? _value.aliases
          : aliases // ignore: cast_nullable_to_non_nullable
              as List<Alias>,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseDataImplCopyWith<$Res> implements $ExerciseDataCopyWith<$Res> {
  factory _$$ExerciseDataImplCopyWith(
          _$ExerciseDataImpl value, $Res Function(_$ExerciseDataImpl) then) =
      __$$ExerciseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String uuid,
      @JsonKey(name: 'language') int languageId,
      @JsonKey(required: true, name: 'exercise_base') int exerciseId,
      String description,
      String name,
      List<Alias> aliases,
      List<Comment> notes});
}

/// @nodoc
class __$$ExerciseDataImplCopyWithImpl<$Res>
    extends _$ExerciseDataCopyWithImpl<$Res, _$ExerciseDataImpl>
    implements _$$ExerciseDataImplCopyWith<$Res> {
  __$$ExerciseDataImplCopyWithImpl(
      _$ExerciseDataImpl _value, $Res Function(_$ExerciseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uuid = null,
    Object? languageId = null,
    Object? exerciseId = null,
    Object? description = null,
    Object? name = null,
    Object? aliases = null,
    Object? notes = null,
  }) {
    return _then(_$ExerciseDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      languageId: null == languageId
          ? _value.languageId
          : languageId // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      aliases: null == aliases
          ? _value._aliases
          : aliases // ignore: cast_nullable_to_non_nullable
              as List<Alias>,
      notes: null == notes
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseDataImpl implements _ExerciseData {
  _$ExerciseDataImpl(
      {required this.id,
      required this.uuid,
      @JsonKey(name: 'language') required this.languageId,
      @JsonKey(required: true, name: 'exercise_base') required this.exerciseId,
      required this.description,
      required this.name,
      required final List<Alias> aliases,
      required final List<Comment> notes})
      : _aliases = aliases,
        _notes = notes;

  factory _$ExerciseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseDataImplFromJson(json);

  @override
  final int id;
  @override
  final String uuid;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'language')
  final int languageId;
// ignore: invalid_annotation_target
  @override
  @JsonKey(required: true, name: 'exercise_base')
  final int exerciseId;
  @override
  final String description;
  @override
  final String name;
  final List<Alias> _aliases;
  @override
  List<Alias> get aliases {
    if (_aliases is EqualUnmodifiableListView) return _aliases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aliases);
  }

  final List<Comment> _notes;
  @override
  List<Comment> get notes {
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  @override
  String toString() {
    return 'ExerciseData(id: $id, uuid: $uuid, languageId: $languageId, exerciseId: $exerciseId, description: $description, name: $name, aliases: $aliases, notes: $notes)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.languageId, languageId) || other.languageId == languageId) &&
            (identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId) &&
            (identical(other.description, description) || other.description == description) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._aliases, _aliases) &&
            const DeepCollectionEquality().equals(other._notes, _notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, uuid, languageId, exerciseId, description, name,
      const DeepCollectionEquality().hash(_aliases), const DeepCollectionEquality().hash(_notes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseDataImplCopyWith<_$ExerciseDataImpl> get copyWith =>
      __$$ExerciseDataImplCopyWithImpl<_$ExerciseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseDataImplToJson(
      this,
    );
  }
}

abstract class _ExerciseData implements ExerciseData {
  factory _ExerciseData(
      {required final int id,
      required final String uuid,
      @JsonKey(name: 'language') required final int languageId,
      @JsonKey(required: true, name: 'exercise_base') required final int exerciseId,
      required final String description,
      required final String name,
      required final List<Alias> aliases,
      required final List<Comment> notes}) = _$ExerciseDataImpl;

  factory _ExerciseData.fromJson(Map<String, dynamic> json) = _$ExerciseDataImpl.fromJson;

  @override
  int get id;
  @override
  String get uuid;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'language')
  int get languageId;
  @override // ignore: invalid_annotation_target
  @JsonKey(required: true, name: 'exercise_base')
  int get exerciseId;
  @override
  String get description;
  @override
  String get name;
  @override
  List<Alias> get aliases;
  @override
  List<Comment> get notes;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseDataImplCopyWith<_$ExerciseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
