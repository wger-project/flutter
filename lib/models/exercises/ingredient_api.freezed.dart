// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IngredientApiSearchDetails _$IngredientApiSearchDetailsFromJson(
    Map<String, dynamic> json) {
  return _IngredientApiSearchDetails.fromJson(json);
}

/// @nodoc
mixin _$IngredientApiSearchDetails {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get image =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'image_thumbnail')
  String? get imageThumbnail => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IngredientApiSearchDetailsCopyWith<IngredientApiSearchDetails>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientApiSearchDetailsCopyWith<$Res> {
  factory $IngredientApiSearchDetailsCopyWith(IngredientApiSearchDetails value,
          $Res Function(IngredientApiSearchDetails) then) =
      _$IngredientApiSearchDetailsCopyWithImpl<$Res,
          IngredientApiSearchDetails>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? image,
      @JsonKey(name: 'image_thumbnail') String? imageThumbnail});
}

/// @nodoc
class _$IngredientApiSearchDetailsCopyWithImpl<$Res,
        $Val extends IngredientApiSearchDetails>
    implements $IngredientApiSearchDetailsCopyWith<$Res> {
  _$IngredientApiSearchDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? image = freezed,
    Object? imageThumbnail = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
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
abstract class _$$IngredientApiSearchDetailsImplCopyWith<$Res>
    implements $IngredientApiSearchDetailsCopyWith<$Res> {
  factory _$$IngredientApiSearchDetailsImplCopyWith(
          _$IngredientApiSearchDetailsImpl value,
          $Res Function(_$IngredientApiSearchDetailsImpl) then) =
      __$$IngredientApiSearchDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? image,
      @JsonKey(name: 'image_thumbnail') String? imageThumbnail});
}

/// @nodoc
class __$$IngredientApiSearchDetailsImplCopyWithImpl<$Res>
    extends _$IngredientApiSearchDetailsCopyWithImpl<$Res,
        _$IngredientApiSearchDetailsImpl>
    implements _$$IngredientApiSearchDetailsImplCopyWith<$Res> {
  __$$IngredientApiSearchDetailsImplCopyWithImpl(
      _$IngredientApiSearchDetailsImpl _value,
      $Res Function(_$IngredientApiSearchDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? image = freezed,
    Object? imageThumbnail = freezed,
  }) {
    return _then(_$IngredientApiSearchDetailsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
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
class _$IngredientApiSearchDetailsImpl implements _IngredientApiSearchDetails {
  _$IngredientApiSearchDetailsImpl(
      {required this.id,
      required this.name,
      required this.image,
      @JsonKey(name: 'image_thumbnail') required this.imageThumbnail});

  factory _$IngredientApiSearchDetailsImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$IngredientApiSearchDetailsImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? image;
// ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'image_thumbnail')
  final String? imageThumbnail;

  @override
  String toString() {
    return 'IngredientApiSearchDetails(id: $id, name: $name, image: $image, imageThumbnail: $imageThumbnail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientApiSearchDetailsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.imageThumbnail, imageThumbnail) ||
                other.imageThumbnail == imageThumbnail));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, image, imageThumbnail);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientApiSearchDetailsImplCopyWith<_$IngredientApiSearchDetailsImpl>
      get copyWith => __$$IngredientApiSearchDetailsImplCopyWithImpl<
          _$IngredientApiSearchDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientApiSearchDetailsImplToJson(
      this,
    );
  }
}

abstract class _IngredientApiSearchDetails
    implements IngredientApiSearchDetails {
  factory _IngredientApiSearchDetails(
          {required final int id,
          required final String name,
          required final String? image,
          @JsonKey(name: 'image_thumbnail')
          required final String? imageThumbnail}) =
      _$IngredientApiSearchDetailsImpl;

  factory _IngredientApiSearchDetails.fromJson(Map<String, dynamic> json) =
      _$IngredientApiSearchDetailsImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get image;
  @override // ignore: invalid_annotation_target
  @JsonKey(name: 'image_thumbnail')
  String? get imageThumbnail;
  @override
  @JsonKey(ignore: true)
  _$$IngredientApiSearchDetailsImplCopyWith<_$IngredientApiSearchDetailsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

IngredientApiSearchEntry _$IngredientApiSearchEntryFromJson(
    Map<String, dynamic> json) {
  return _IngredientApiSearchEntry.fromJson(json);
}

/// @nodoc
mixin _$IngredientApiSearchEntry {
  String get value => throw _privateConstructorUsedError;
  IngredientApiSearchDetails get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IngredientApiSearchEntryCopyWith<IngredientApiSearchEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientApiSearchEntryCopyWith<$Res> {
  factory $IngredientApiSearchEntryCopyWith(IngredientApiSearchEntry value,
          $Res Function(IngredientApiSearchEntry) then) =
      _$IngredientApiSearchEntryCopyWithImpl<$Res, IngredientApiSearchEntry>;
  @useResult
  $Res call({String value, IngredientApiSearchDetails data});

  $IngredientApiSearchDetailsCopyWith<$Res> get data;
}

/// @nodoc
class _$IngredientApiSearchEntryCopyWithImpl<$Res,
        $Val extends IngredientApiSearchEntry>
    implements $IngredientApiSearchEntryCopyWith<$Res> {
  _$IngredientApiSearchEntryCopyWithImpl(this._value, this._then);

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
              as IngredientApiSearchDetails,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $IngredientApiSearchDetailsCopyWith<$Res> get data {
    return $IngredientApiSearchDetailsCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$IngredientApiSearchEntryImplCopyWith<$Res>
    implements $IngredientApiSearchEntryCopyWith<$Res> {
  factory _$$IngredientApiSearchEntryImplCopyWith(
          _$IngredientApiSearchEntryImpl value,
          $Res Function(_$IngredientApiSearchEntryImpl) then) =
      __$$IngredientApiSearchEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, IngredientApiSearchDetails data});

  @override
  $IngredientApiSearchDetailsCopyWith<$Res> get data;
}

/// @nodoc
class __$$IngredientApiSearchEntryImplCopyWithImpl<$Res>
    extends _$IngredientApiSearchEntryCopyWithImpl<$Res,
        _$IngredientApiSearchEntryImpl>
    implements _$$IngredientApiSearchEntryImplCopyWith<$Res> {
  __$$IngredientApiSearchEntryImplCopyWithImpl(
      _$IngredientApiSearchEntryImpl _value,
      $Res Function(_$IngredientApiSearchEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? data = null,
  }) {
    return _then(_$IngredientApiSearchEntryImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as IngredientApiSearchDetails,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientApiSearchEntryImpl implements _IngredientApiSearchEntry {
  _$IngredientApiSearchEntryImpl({required this.value, required this.data});

  factory _$IngredientApiSearchEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientApiSearchEntryImplFromJson(json);

  @override
  final String value;
  @override
  final IngredientApiSearchDetails data;

  @override
  String toString() {
    return 'IngredientApiSearchEntry(value: $value, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientApiSearchEntryImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, value, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientApiSearchEntryImplCopyWith<_$IngredientApiSearchEntryImpl>
      get copyWith => __$$IngredientApiSearchEntryImplCopyWithImpl<
          _$IngredientApiSearchEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientApiSearchEntryImplToJson(
      this,
    );
  }
}

abstract class _IngredientApiSearchEntry implements IngredientApiSearchEntry {
  factory _IngredientApiSearchEntry(
          {required final String value,
          required final IngredientApiSearchDetails data}) =
      _$IngredientApiSearchEntryImpl;

  factory _IngredientApiSearchEntry.fromJson(Map<String, dynamic> json) =
      _$IngredientApiSearchEntryImpl.fromJson;

  @override
  String get value;
  @override
  IngredientApiSearchDetails get data;
  @override
  @JsonKey(ignore: true)
  _$$IngredientApiSearchEntryImplCopyWith<_$IngredientApiSearchEntryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

IngredientApiSearch _$IngredientApiSearchFromJson(Map<String, dynamic> json) {
  return _IngredientApiSearch.fromJson(json);
}

/// @nodoc
mixin _$IngredientApiSearch {
  List<IngredientApiSearchEntry> get suggestions =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IngredientApiSearchCopyWith<IngredientApiSearch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientApiSearchCopyWith<$Res> {
  factory $IngredientApiSearchCopyWith(
          IngredientApiSearch value, $Res Function(IngredientApiSearch) then) =
      _$IngredientApiSearchCopyWithImpl<$Res, IngredientApiSearch>;
  @useResult
  $Res call({List<IngredientApiSearchEntry> suggestions});
}

/// @nodoc
class _$IngredientApiSearchCopyWithImpl<$Res, $Val extends IngredientApiSearch>
    implements $IngredientApiSearchCopyWith<$Res> {
  _$IngredientApiSearchCopyWithImpl(this._value, this._then);

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
              as List<IngredientApiSearchEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IngredientApiSearchImplCopyWith<$Res>
    implements $IngredientApiSearchCopyWith<$Res> {
  factory _$$IngredientApiSearchImplCopyWith(_$IngredientApiSearchImpl value,
          $Res Function(_$IngredientApiSearchImpl) then) =
      __$$IngredientApiSearchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<IngredientApiSearchEntry> suggestions});
}

/// @nodoc
class __$$IngredientApiSearchImplCopyWithImpl<$Res>
    extends _$IngredientApiSearchCopyWithImpl<$Res, _$IngredientApiSearchImpl>
    implements _$$IngredientApiSearchImplCopyWith<$Res> {
  __$$IngredientApiSearchImplCopyWithImpl(_$IngredientApiSearchImpl _value,
      $Res Function(_$IngredientApiSearchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestions = null,
  }) {
    return _then(_$IngredientApiSearchImpl(
      suggestions: null == suggestions
          ? _value._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<IngredientApiSearchEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientApiSearchImpl implements _IngredientApiSearch {
  _$IngredientApiSearchImpl(
      {required final List<IngredientApiSearchEntry> suggestions})
      : _suggestions = suggestions;

  factory _$IngredientApiSearchImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientApiSearchImplFromJson(json);

  final List<IngredientApiSearchEntry> _suggestions;
  @override
  List<IngredientApiSearchEntry> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  String toString() {
    return 'IngredientApiSearch(suggestions: $suggestions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientApiSearchImpl &&
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
  _$$IngredientApiSearchImplCopyWith<_$IngredientApiSearchImpl> get copyWith =>
      __$$IngredientApiSearchImplCopyWithImpl<_$IngredientApiSearchImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientApiSearchImplToJson(
      this,
    );
  }
}

abstract class _IngredientApiSearch implements IngredientApiSearch {
  factory _IngredientApiSearch(
          {required final List<IngredientApiSearchEntry> suggestions}) =
      _$IngredientApiSearchImpl;

  factory _IngredientApiSearch.fromJson(Map<String, dynamic> json) =
      _$IngredientApiSearchImpl.fromJson;

  @override
  List<IngredientApiSearchEntry> get suggestions;
  @override
  @JsonKey(ignore: true)
  _$$IngredientApiSearchImplCopyWith<_$IngredientApiSearchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
