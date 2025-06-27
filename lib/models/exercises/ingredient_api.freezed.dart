// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IngredientApiSearchDetails {
  int get id;
  String get name;
  String? get image; // ignore: invalid_annotation_target
  @JsonKey(name: 'image_thumbnail')
  String? get imageThumbnail;

  /// Create a copy of IngredientApiSearchDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IngredientApiSearchDetailsCopyWith<IngredientApiSearchDetails>
      get copyWith =>
          _$IngredientApiSearchDetailsCopyWithImpl<IngredientApiSearchDetails>(
              this as IngredientApiSearchDetails, _$identity);

  /// Serializes this IngredientApiSearchDetails to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IngredientApiSearchDetails &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.imageThumbnail, imageThumbnail) ||
                other.imageThumbnail == imageThumbnail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, image, imageThumbnail);

  @override
  String toString() {
    return 'IngredientApiSearchDetails(id: $id, name: $name, image: $image, imageThumbnail: $imageThumbnail)';
  }
}

/// @nodoc
abstract mixin class $IngredientApiSearchDetailsCopyWith<$Res> {
  factory $IngredientApiSearchDetailsCopyWith(IngredientApiSearchDetails value,
          $Res Function(IngredientApiSearchDetails) _then) =
      _$IngredientApiSearchDetailsCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String name,
      String? image,
      @JsonKey(name: 'image_thumbnail') String? imageThumbnail});
}

/// @nodoc
class _$IngredientApiSearchDetailsCopyWithImpl<$Res>
    implements $IngredientApiSearchDetailsCopyWith<$Res> {
  _$IngredientApiSearchDetailsCopyWithImpl(this._self, this._then);

  final IngredientApiSearchDetails _self;
  final $Res Function(IngredientApiSearchDetails) _then;

  /// Create a copy of IngredientApiSearchDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? image = freezed,
    Object? imageThumbnail = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
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
class _IngredientApiSearchDetails implements IngredientApiSearchDetails {
  _IngredientApiSearchDetails(
      {required this.id,
      required this.name,
      required this.image,
      @JsonKey(name: 'image_thumbnail') required this.imageThumbnail});
  factory _IngredientApiSearchDetails.fromJson(Map<String, dynamic> json) =>
      _$IngredientApiSearchDetailsFromJson(json);

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

  /// Create a copy of IngredientApiSearchDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$IngredientApiSearchDetailsCopyWith<_IngredientApiSearchDetails>
      get copyWith => __$IngredientApiSearchDetailsCopyWithImpl<
          _IngredientApiSearchDetails>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$IngredientApiSearchDetailsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _IngredientApiSearchDetails &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.imageThumbnail, imageThumbnail) ||
                other.imageThumbnail == imageThumbnail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, image, imageThumbnail);

  @override
  String toString() {
    return 'IngredientApiSearchDetails(id: $id, name: $name, image: $image, imageThumbnail: $imageThumbnail)';
  }
}

/// @nodoc
abstract mixin class _$IngredientApiSearchDetailsCopyWith<$Res>
    implements $IngredientApiSearchDetailsCopyWith<$Res> {
  factory _$IngredientApiSearchDetailsCopyWith(
          _IngredientApiSearchDetails value,
          $Res Function(_IngredientApiSearchDetails) _then) =
      __$IngredientApiSearchDetailsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? image,
      @JsonKey(name: 'image_thumbnail') String? imageThumbnail});
}

/// @nodoc
class __$IngredientApiSearchDetailsCopyWithImpl<$Res>
    implements _$IngredientApiSearchDetailsCopyWith<$Res> {
  __$IngredientApiSearchDetailsCopyWithImpl(this._self, this._then);

  final _IngredientApiSearchDetails _self;
  final $Res Function(_IngredientApiSearchDetails) _then;

  /// Create a copy of IngredientApiSearchDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? image = freezed,
    Object? imageThumbnail = freezed,
  }) {
    return _then(_IngredientApiSearchDetails(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
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
mixin _$IngredientApiSearchEntry {
  String get value;
  IngredientApiSearchDetails get data;

  /// Create a copy of IngredientApiSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IngredientApiSearchEntryCopyWith<IngredientApiSearchEntry> get copyWith =>
      _$IngredientApiSearchEntryCopyWithImpl<IngredientApiSearchEntry>(
          this as IngredientApiSearchEntry, _$identity);

  /// Serializes this IngredientApiSearchEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IngredientApiSearchEntry &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, data);

  @override
  String toString() {
    return 'IngredientApiSearchEntry(value: $value, data: $data)';
  }
}

/// @nodoc
abstract mixin class $IngredientApiSearchEntryCopyWith<$Res> {
  factory $IngredientApiSearchEntryCopyWith(IngredientApiSearchEntry value,
          $Res Function(IngredientApiSearchEntry) _then) =
      _$IngredientApiSearchEntryCopyWithImpl;
  @useResult
  $Res call({String value, IngredientApiSearchDetails data});

  $IngredientApiSearchDetailsCopyWith<$Res> get data;
}

/// @nodoc
class _$IngredientApiSearchEntryCopyWithImpl<$Res>
    implements $IngredientApiSearchEntryCopyWith<$Res> {
  _$IngredientApiSearchEntryCopyWithImpl(this._self, this._then);

  final IngredientApiSearchEntry _self;
  final $Res Function(IngredientApiSearchEntry) _then;

  /// Create a copy of IngredientApiSearchEntry
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
              as IngredientApiSearchDetails,
    ));
  }

  /// Create a copy of IngredientApiSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IngredientApiSearchDetailsCopyWith<$Res> get data {
    return $IngredientApiSearchDetailsCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _IngredientApiSearchEntry implements IngredientApiSearchEntry {
  _IngredientApiSearchEntry({required this.value, required this.data});
  factory _IngredientApiSearchEntry.fromJson(Map<String, dynamic> json) =>
      _$IngredientApiSearchEntryFromJson(json);

  @override
  final String value;
  @override
  final IngredientApiSearchDetails data;

  /// Create a copy of IngredientApiSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$IngredientApiSearchEntryCopyWith<_IngredientApiSearchEntry> get copyWith =>
      __$IngredientApiSearchEntryCopyWithImpl<_IngredientApiSearchEntry>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$IngredientApiSearchEntryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _IngredientApiSearchEntry &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, data);

  @override
  String toString() {
    return 'IngredientApiSearchEntry(value: $value, data: $data)';
  }
}

/// @nodoc
abstract mixin class _$IngredientApiSearchEntryCopyWith<$Res>
    implements $IngredientApiSearchEntryCopyWith<$Res> {
  factory _$IngredientApiSearchEntryCopyWith(_IngredientApiSearchEntry value,
          $Res Function(_IngredientApiSearchEntry) _then) =
      __$IngredientApiSearchEntryCopyWithImpl;
  @override
  @useResult
  $Res call({String value, IngredientApiSearchDetails data});

  @override
  $IngredientApiSearchDetailsCopyWith<$Res> get data;
}

/// @nodoc
class __$IngredientApiSearchEntryCopyWithImpl<$Res>
    implements _$IngredientApiSearchEntryCopyWith<$Res> {
  __$IngredientApiSearchEntryCopyWithImpl(this._self, this._then);

  final _IngredientApiSearchEntry _self;
  final $Res Function(_IngredientApiSearchEntry) _then;

  /// Create a copy of IngredientApiSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
    Object? data = null,
  }) {
    return _then(_IngredientApiSearchEntry(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as IngredientApiSearchDetails,
    ));
  }

  /// Create a copy of IngredientApiSearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IngredientApiSearchDetailsCopyWith<$Res> get data {
    return $IngredientApiSearchDetailsCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc
mixin _$IngredientApiSearch {
  List<IngredientApiSearchEntry> get suggestions;

  /// Create a copy of IngredientApiSearch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IngredientApiSearchCopyWith<IngredientApiSearch> get copyWith =>
      _$IngredientApiSearchCopyWithImpl<IngredientApiSearch>(
          this as IngredientApiSearch, _$identity);

  /// Serializes this IngredientApiSearch to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IngredientApiSearch &&
            const DeepCollectionEquality()
                .equals(other.suggestions, suggestions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(suggestions));

  @override
  String toString() {
    return 'IngredientApiSearch(suggestions: $suggestions)';
  }
}

/// @nodoc
abstract mixin class $IngredientApiSearchCopyWith<$Res> {
  factory $IngredientApiSearchCopyWith(
          IngredientApiSearch value, $Res Function(IngredientApiSearch) _then) =
      _$IngredientApiSearchCopyWithImpl;
  @useResult
  $Res call({List<IngredientApiSearchEntry> suggestions});
}

/// @nodoc
class _$IngredientApiSearchCopyWithImpl<$Res>
    implements $IngredientApiSearchCopyWith<$Res> {
  _$IngredientApiSearchCopyWithImpl(this._self, this._then);

  final IngredientApiSearch _self;
  final $Res Function(IngredientApiSearch) _then;

  /// Create a copy of IngredientApiSearch
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
              as List<IngredientApiSearchEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _IngredientApiSearch implements IngredientApiSearch {
  _IngredientApiSearch(
      {required final List<IngredientApiSearchEntry> suggestions})
      : _suggestions = suggestions;
  factory _IngredientApiSearch.fromJson(Map<String, dynamic> json) =>
      _$IngredientApiSearchFromJson(json);

  final List<IngredientApiSearchEntry> _suggestions;
  @override
  List<IngredientApiSearchEntry> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  /// Create a copy of IngredientApiSearch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$IngredientApiSearchCopyWith<_IngredientApiSearch> get copyWith =>
      __$IngredientApiSearchCopyWithImpl<_IngredientApiSearch>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$IngredientApiSearchToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _IngredientApiSearch &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_suggestions));

  @override
  String toString() {
    return 'IngredientApiSearch(suggestions: $suggestions)';
  }
}

/// @nodoc
abstract mixin class _$IngredientApiSearchCopyWith<$Res>
    implements $IngredientApiSearchCopyWith<$Res> {
  factory _$IngredientApiSearchCopyWith(_IngredientApiSearch value,
          $Res Function(_IngredientApiSearch) _then) =
      __$IngredientApiSearchCopyWithImpl;
  @override
  @useResult
  $Res call({List<IngredientApiSearchEntry> suggestions});
}

/// @nodoc
class __$IngredientApiSearchCopyWithImpl<$Res>
    implements _$IngredientApiSearchCopyWith<$Res> {
  __$IngredientApiSearchCopyWithImpl(this._self, this._then);

  final _IngredientApiSearch _self;
  final $Res Function(_IngredientApiSearch) _then;

  /// Create a copy of IngredientApiSearch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? suggestions = null,
  }) {
    return _then(_IngredientApiSearch(
      suggestions: null == suggestions
          ? _self._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<IngredientApiSearchEntry>,
    ));
  }
}

// dart format on
