// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_submission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseAliasSubmissionApi {
  String get alias;

  /// Create a copy of ExerciseAliasSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseAliasSubmissionApiCopyWith<ExerciseAliasSubmissionApi> get copyWith =>
      _$ExerciseAliasSubmissionApiCopyWithImpl<ExerciseAliasSubmissionApi>(
          this as ExerciseAliasSubmissionApi, _$identity);

  /// Serializes this ExerciseAliasSubmissionApi to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExerciseAliasSubmissionApi &&
            (identical(other.alias, alias) || other.alias == alias));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, alias);

  @override
  String toString() {
    return 'ExerciseAliasSubmissionApi(alias: $alias)';
  }
}

/// @nodoc
abstract mixin class $ExerciseAliasSubmissionApiCopyWith<$Res> {
  factory $ExerciseAliasSubmissionApiCopyWith(
          ExerciseAliasSubmissionApi value, $Res Function(ExerciseAliasSubmissionApi) _then) =
      _$ExerciseAliasSubmissionApiCopyWithImpl;

  @useResult
  $Res call({String alias});
}

/// @nodoc
class _$ExerciseAliasSubmissionApiCopyWithImpl<$Res>
    implements $ExerciseAliasSubmissionApiCopyWith<$Res> {
  _$ExerciseAliasSubmissionApiCopyWithImpl(this._self, this._then);

  final ExerciseAliasSubmissionApi _self;
  final $Res Function(ExerciseAliasSubmissionApi) _then;

  /// Create a copy of ExerciseAliasSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alias = null,
  }) {
    return _then(_self.copyWith(
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ExerciseAliasSubmissionApi].
extension ExerciseAliasSubmissionApiPatterns on ExerciseAliasSubmissionApi {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ExerciseAliasSubmissionApi value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseAliasSubmissionApi() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ExerciseAliasSubmissionApi value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseAliasSubmissionApi():
        return $default(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ExerciseAliasSubmissionApi value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseAliasSubmissionApi() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String alias)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseAliasSubmissionApi() when $default != null:
        return $default(_that.alias);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String alias) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseAliasSubmissionApi():
        return $default(_that.alias);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String alias)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseAliasSubmissionApi() when $default != null:
        return $default(_that.alias);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ExerciseAliasSubmissionApi implements ExerciseAliasSubmissionApi {
  const _ExerciseAliasSubmissionApi({required this.alias});

  factory _ExerciseAliasSubmissionApi.fromJson(Map<String, dynamic> json) =>
      _$ExerciseAliasSubmissionApiFromJson(json);

  @override
  final String alias;

  /// Create a copy of ExerciseAliasSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseAliasSubmissionApiCopyWith<_ExerciseAliasSubmissionApi> get copyWith =>
      __$ExerciseAliasSubmissionApiCopyWithImpl<_ExerciseAliasSubmissionApi>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseAliasSubmissionApiToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExerciseAliasSubmissionApi &&
            (identical(other.alias, alias) || other.alias == alias));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, alias);

  @override
  String toString() {
    return 'ExerciseAliasSubmissionApi(alias: $alias)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseAliasSubmissionApiCopyWith<$Res>
    implements $ExerciseAliasSubmissionApiCopyWith<$Res> {
  factory _$ExerciseAliasSubmissionApiCopyWith(
          _ExerciseAliasSubmissionApi value, $Res Function(_ExerciseAliasSubmissionApi) _then) =
      __$ExerciseAliasSubmissionApiCopyWithImpl;

  @override
  @useResult
  $Res call({String alias});
}

/// @nodoc
class __$ExerciseAliasSubmissionApiCopyWithImpl<$Res>
    implements _$ExerciseAliasSubmissionApiCopyWith<$Res> {
  __$ExerciseAliasSubmissionApiCopyWithImpl(this._self, this._then);

  final _ExerciseAliasSubmissionApi _self;
  final $Res Function(_ExerciseAliasSubmissionApi) _then;

  /// Create a copy of ExerciseAliasSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? alias = null,
  }) {
    return _then(_ExerciseAliasSubmissionApi(
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ExerciseCommentSubmissionApi {
  String get alias;

  /// Create a copy of ExerciseCommentSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseCommentSubmissionApiCopyWith<ExerciseCommentSubmissionApi> get copyWith =>
      _$ExerciseCommentSubmissionApiCopyWithImpl<ExerciseCommentSubmissionApi>(
          this as ExerciseCommentSubmissionApi, _$identity);

  /// Serializes this ExerciseCommentSubmissionApi to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExerciseCommentSubmissionApi &&
            (identical(other.alias, alias) || other.alias == alias));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, alias);

  @override
  String toString() {
    return 'ExerciseCommentSubmissionApi(alias: $alias)';
  }
}

/// @nodoc
abstract mixin class $ExerciseCommentSubmissionApiCopyWith<$Res> {
  factory $ExerciseCommentSubmissionApiCopyWith(
          ExerciseCommentSubmissionApi value, $Res Function(ExerciseCommentSubmissionApi) _then) =
      _$ExerciseCommentSubmissionApiCopyWithImpl;

  @useResult
  $Res call({String alias});
}

/// @nodoc
class _$ExerciseCommentSubmissionApiCopyWithImpl<$Res>
    implements $ExerciseCommentSubmissionApiCopyWith<$Res> {
  _$ExerciseCommentSubmissionApiCopyWithImpl(this._self, this._then);

  final ExerciseCommentSubmissionApi _self;
  final $Res Function(ExerciseCommentSubmissionApi) _then;

  /// Create a copy of ExerciseCommentSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alias = null,
  }) {
    return _then(_self.copyWith(
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ExerciseCommentSubmissionApi].
extension ExerciseCommentSubmissionApiPatterns on ExerciseCommentSubmissionApi {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ExerciseCommentSubmissionApi value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseCommentSubmissionApi() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ExerciseCommentSubmissionApi value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseCommentSubmissionApi():
        return $default(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ExerciseCommentSubmissionApi value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseCommentSubmissionApi() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String alias)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseCommentSubmissionApi() when $default != null:
        return $default(_that.alias);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String alias) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseCommentSubmissionApi():
        return $default(_that.alias);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String alias)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseCommentSubmissionApi() when $default != null:
        return $default(_that.alias);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ExerciseCommentSubmissionApi implements ExerciseCommentSubmissionApi {
  const _ExerciseCommentSubmissionApi({required this.alias});

  factory _ExerciseCommentSubmissionApi.fromJson(Map<String, dynamic> json) =>
      _$ExerciseCommentSubmissionApiFromJson(json);

  @override
  final String alias;

  /// Create a copy of ExerciseCommentSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseCommentSubmissionApiCopyWith<_ExerciseCommentSubmissionApi> get copyWith =>
      __$ExerciseCommentSubmissionApiCopyWithImpl<_ExerciseCommentSubmissionApi>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseCommentSubmissionApiToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExerciseCommentSubmissionApi &&
            (identical(other.alias, alias) || other.alias == alias));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, alias);

  @override
  String toString() {
    return 'ExerciseCommentSubmissionApi(alias: $alias)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseCommentSubmissionApiCopyWith<$Res>
    implements $ExerciseCommentSubmissionApiCopyWith<$Res> {
  factory _$ExerciseCommentSubmissionApiCopyWith(
          _ExerciseCommentSubmissionApi value, $Res Function(_ExerciseCommentSubmissionApi) _then) =
      __$ExerciseCommentSubmissionApiCopyWithImpl;

  @override
  @useResult
  $Res call({String alias});
}

/// @nodoc
class __$ExerciseCommentSubmissionApiCopyWithImpl<$Res>
    implements _$ExerciseCommentSubmissionApiCopyWith<$Res> {
  __$ExerciseCommentSubmissionApiCopyWithImpl(this._self, this._then);

  final _ExerciseCommentSubmissionApi _self;
  final $Res Function(_ExerciseCommentSubmissionApi) _then;

  /// Create a copy of ExerciseCommentSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? alias = null,
  }) {
    return _then(_ExerciseCommentSubmissionApi(
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ExerciseTranslationSubmissionApi {
  String get name;

  String get description;

  int get language;

  @JsonKey(name: 'license_author')
  String get author;

  List<ExerciseAliasSubmissionApi> get aliases;

  List<ExerciseCommentSubmissionApi> get comments;

  /// Create a copy of ExerciseTranslationSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseTranslationSubmissionApiCopyWith<ExerciseTranslationSubmissionApi> get copyWith =>
      _$ExerciseTranslationSubmissionApiCopyWithImpl<ExerciseTranslationSubmissionApi>(
          this as ExerciseTranslationSubmissionApi, _$identity);

  /// Serializes this ExerciseTranslationSubmissionApi to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExerciseTranslationSubmissionApi &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) || other.description == description) &&
            (identical(other.language, language) || other.language == language) &&
            (identical(other.author, author) || other.author == author) &&
            const DeepCollectionEquality().equals(other.aliases, aliases) &&
            const DeepCollectionEquality().equals(other.comments, comments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, description, language, author,
      const DeepCollectionEquality().hash(aliases), const DeepCollectionEquality().hash(comments));

  @override
  String toString() {
    return 'ExerciseTranslationSubmissionApi(name: $name, description: $description, language: $language, author: $author, aliases: $aliases, comments: $comments)';
  }
}

/// @nodoc
abstract mixin class $ExerciseTranslationSubmissionApiCopyWith<$Res> {
  factory $ExerciseTranslationSubmissionApiCopyWith(ExerciseTranslationSubmissionApi value,
          $Res Function(ExerciseTranslationSubmissionApi) _then) =
      _$ExerciseTranslationSubmissionApiCopyWithImpl;

  @useResult
  $Res call(
      {String name,
      String description,
      int language,
      @JsonKey(name: 'license_author') String author,
      List<ExerciseAliasSubmissionApi> aliases,
      List<ExerciseCommentSubmissionApi> comments});
}

/// @nodoc
class _$ExerciseTranslationSubmissionApiCopyWithImpl<$Res>
    implements $ExerciseTranslationSubmissionApiCopyWith<$Res> {
  _$ExerciseTranslationSubmissionApiCopyWithImpl(this._self, this._then);

  final ExerciseTranslationSubmissionApi _self;
  final $Res Function(ExerciseTranslationSubmissionApi) _then;

  /// Create a copy of ExerciseTranslationSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? language = null,
    Object? author = null,
    Object? aliases = null,
    Object? comments = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as int,
      author: null == author
          ? _self.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      aliases: null == aliases
          ? _self.aliases
          : aliases // ignore: cast_nullable_to_non_nullable
              as List<ExerciseAliasSubmissionApi>,
      comments: null == comments
          ? _self.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<ExerciseCommentSubmissionApi>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ExerciseTranslationSubmissionApi].
extension ExerciseTranslationSubmissionApiPatterns on ExerciseTranslationSubmissionApi {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ExerciseTranslationSubmissionApi value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseTranslationSubmissionApi() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ExerciseTranslationSubmissionApi value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseTranslationSubmissionApi():
        return $default(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ExerciseTranslationSubmissionApi value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseTranslationSubmissionApi() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String name,
            String description,
            int language,
            @JsonKey(name: 'license_author') String author,
            List<ExerciseAliasSubmissionApi> aliases,
            List<ExerciseCommentSubmissionApi> comments)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseTranslationSubmissionApi() when $default != null:
        return $default(_that.name, _that.description, _that.language, _that.author, _that.aliases,
            _that.comments);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String name,
            String description,
            int language,
            @JsonKey(name: 'license_author') String author,
            List<ExerciseAliasSubmissionApi> aliases,
            List<ExerciseCommentSubmissionApi> comments)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseTranslationSubmissionApi():
        return $default(_that.name, _that.description, _that.language, _that.author, _that.aliases,
            _that.comments);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String name,
            String description,
            int language,
            @JsonKey(name: 'license_author') String author,
            List<ExerciseAliasSubmissionApi> aliases,
            List<ExerciseCommentSubmissionApi> comments)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseTranslationSubmissionApi() when $default != null:
        return $default(_that.name, _that.description, _that.language, _that.author, _that.aliases,
            _that.comments);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ExerciseTranslationSubmissionApi implements ExerciseTranslationSubmissionApi {
  const _ExerciseTranslationSubmissionApi(
      {required this.name,
      required this.description,
      required this.language,
      @JsonKey(name: 'license_author') required this.author,
      final List<ExerciseAliasSubmissionApi> aliases = const [],
      final List<ExerciseCommentSubmissionApi> comments = const []})
      : _aliases = aliases,
        _comments = comments;

  factory _ExerciseTranslationSubmissionApi.fromJson(Map<String, dynamic> json) =>
      _$ExerciseTranslationSubmissionApiFromJson(json);

  @override
  final String name;
  @override
  final String description;
  @override
  final int language;
  @override
  @JsonKey(name: 'license_author')
  final String author;
  final List<ExerciseAliasSubmissionApi> _aliases;

  @override
  @JsonKey()
  List<ExerciseAliasSubmissionApi> get aliases {
    if (_aliases is EqualUnmodifiableListView) return _aliases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aliases);
  }

  final List<ExerciseCommentSubmissionApi> _comments;

  @override
  @JsonKey()
  List<ExerciseCommentSubmissionApi> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  /// Create a copy of ExerciseTranslationSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseTranslationSubmissionApiCopyWith<_ExerciseTranslationSubmissionApi> get copyWith =>
      __$ExerciseTranslationSubmissionApiCopyWithImpl<_ExerciseTranslationSubmissionApi>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseTranslationSubmissionApiToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExerciseTranslationSubmissionApi &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) || other.description == description) &&
            (identical(other.language, language) || other.language == language) &&
            (identical(other.author, author) || other.author == author) &&
            const DeepCollectionEquality().equals(other._aliases, _aliases) &&
            const DeepCollectionEquality().equals(other._comments, _comments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      language,
      author,
      const DeepCollectionEquality().hash(_aliases),
      const DeepCollectionEquality().hash(_comments));

  @override
  String toString() {
    return 'ExerciseTranslationSubmissionApi(name: $name, description: $description, language: $language, author: $author, aliases: $aliases, comments: $comments)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseTranslationSubmissionApiCopyWith<$Res>
    implements $ExerciseTranslationSubmissionApiCopyWith<$Res> {
  factory _$ExerciseTranslationSubmissionApiCopyWith(_ExerciseTranslationSubmissionApi value,
          $Res Function(_ExerciseTranslationSubmissionApi) _then) =
      __$ExerciseTranslationSubmissionApiCopyWithImpl;

  @override
  @useResult
  $Res call(
      {String name,
      String description,
      int language,
      @JsonKey(name: 'license_author') String author,
      List<ExerciseAliasSubmissionApi> aliases,
      List<ExerciseCommentSubmissionApi> comments});
}

/// @nodoc
class __$ExerciseTranslationSubmissionApiCopyWithImpl<$Res>
    implements _$ExerciseTranslationSubmissionApiCopyWith<$Res> {
  __$ExerciseTranslationSubmissionApiCopyWithImpl(this._self, this._then);

  final _ExerciseTranslationSubmissionApi _self;
  final $Res Function(_ExerciseTranslationSubmissionApi) _then;

  /// Create a copy of ExerciseTranslationSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? language = null,
    Object? author = null,
    Object? aliases = null,
    Object? comments = null,
  }) {
    return _then(_ExerciseTranslationSubmissionApi(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as int,
      author: null == author
          ? _self.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      aliases: null == aliases
          ? _self._aliases
          : aliases // ignore: cast_nullable_to_non_nullable
              as List<ExerciseAliasSubmissionApi>,
      comments: null == comments
          ? _self._comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<ExerciseCommentSubmissionApi>,
    ));
  }
}

/// @nodoc
mixin _$ExerciseSubmissionApi {
  int get category;

  List<int> get muscles;

  @JsonKey(name: 'muscles_secondary')
  List<int> get musclesSecondary;

  List<int> get equipment;

  @JsonKey(name: 'license_author')
  String get author;

  @JsonKey(includeToJson: false)
  int? get variation;

  List<ExerciseTranslationSubmissionApi> get translations;

  /// Create a copy of ExerciseSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseSubmissionApiCopyWith<ExerciseSubmissionApi> get copyWith =>
      _$ExerciseSubmissionApiCopyWithImpl<ExerciseSubmissionApi>(
          this as ExerciseSubmissionApi, _$identity);

  /// Serializes this ExerciseSubmissionApi to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExerciseSubmissionApi &&
            (identical(other.category, category) || other.category == category) &&
            const DeepCollectionEquality().equals(other.muscles, muscles) &&
            const DeepCollectionEquality().equals(other.musclesSecondary, musclesSecondary) &&
            const DeepCollectionEquality().equals(other.equipment, equipment) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.variation, variation) || other.variation == variation) &&
            const DeepCollectionEquality().equals(other.translations, translations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      category,
      const DeepCollectionEquality().hash(muscles),
      const DeepCollectionEquality().hash(musclesSecondary),
      const DeepCollectionEquality().hash(equipment),
      author,
      variation,
      const DeepCollectionEquality().hash(translations));

  @override
  String toString() {
    return 'ExerciseSubmissionApi(category: $category, muscles: $muscles, musclesSecondary: $musclesSecondary, equipment: $equipment, author: $author, variation: $variation, translations: $translations)';
  }
}

/// @nodoc
abstract mixin class $ExerciseSubmissionApiCopyWith<$Res> {
  factory $ExerciseSubmissionApiCopyWith(
          ExerciseSubmissionApi value, $Res Function(ExerciseSubmissionApi) _then) =
      _$ExerciseSubmissionApiCopyWithImpl;

  @useResult
  $Res call(
      {int category,
      List<int> muscles,
      @JsonKey(name: 'muscles_secondary') List<int> musclesSecondary,
      List<int> equipment,
      @JsonKey(name: 'license_author') String author,
      @JsonKey(includeToJson: false) int? variation,
      List<ExerciseTranslationSubmissionApi> translations});
}

/// @nodoc
class _$ExerciseSubmissionApiCopyWithImpl<$Res> implements $ExerciseSubmissionApiCopyWith<$Res> {
  _$ExerciseSubmissionApiCopyWithImpl(this._self, this._then);

  final ExerciseSubmissionApi _self;
  final $Res Function(ExerciseSubmissionApi) _then;

  /// Create a copy of ExerciseSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? muscles = null,
    Object? musclesSecondary = null,
    Object? equipment = null,
    Object? author = null,
    Object? variation = freezed,
    Object? translations = null,
  }) {
    return _then(_self.copyWith(
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      muscles: null == muscles
          ? _self.muscles
          : muscles // ignore: cast_nullable_to_non_nullable
              as List<int>,
      musclesSecondary: null == musclesSecondary
          ? _self.musclesSecondary
          : musclesSecondary // ignore: cast_nullable_to_non_nullable
              as List<int>,
      equipment: null == equipment
          ? _self.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<int>,
      author: null == author
          ? _self.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      variation: freezed == variation
          ? _self.variation
          : variation // ignore: cast_nullable_to_non_nullable
              as int?,
      translations: null == translations
          ? _self.translations
          : translations // ignore: cast_nullable_to_non_nullable
              as List<ExerciseTranslationSubmissionApi>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ExerciseSubmissionApi].
extension ExerciseSubmissionApiPatterns on ExerciseSubmissionApi {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ExerciseSubmissionApi value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseSubmissionApi() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ExerciseSubmissionApi value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseSubmissionApi():
        return $default(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ExerciseSubmissionApi value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseSubmissionApi() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int category,
            List<int> muscles,
            @JsonKey(name: 'muscles_secondary') List<int> musclesSecondary,
            List<int> equipment,
            @JsonKey(name: 'license_author') String author,
            @JsonKey(includeToJson: false) int? variation,
            List<ExerciseTranslationSubmissionApi> translations)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseSubmissionApi() when $default != null:
        return $default(_that.category, _that.muscles, _that.musclesSecondary, _that.equipment,
            _that.author, _that.variation, _that.translations);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int category,
            List<int> muscles,
            @JsonKey(name: 'muscles_secondary') List<int> musclesSecondary,
            List<int> equipment,
            @JsonKey(name: 'license_author') String author,
            @JsonKey(includeToJson: false) int? variation,
            List<ExerciseTranslationSubmissionApi> translations)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseSubmissionApi():
        return $default(_that.category, _that.muscles, _that.musclesSecondary, _that.equipment,
            _that.author, _that.variation, _that.translations);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int category,
            List<int> muscles,
            @JsonKey(name: 'muscles_secondary') List<int> musclesSecondary,
            List<int> equipment,
            @JsonKey(name: 'license_author') String author,
            @JsonKey(includeToJson: false) int? variation,
            List<ExerciseTranslationSubmissionApi> translations)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseSubmissionApi() when $default != null:
        return $default(_that.category, _that.muscles, _that.musclesSecondary, _that.equipment,
            _that.author, _that.variation, _that.translations);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ExerciseSubmissionApi implements ExerciseSubmissionApi {
  const _ExerciseSubmissionApi(
      {required this.category,
      required final List<int> muscles,
      @JsonKey(name: 'muscles_secondary') required final List<int> musclesSecondary,
      required final List<int> equipment,
      @JsonKey(name: 'license_author') required this.author,
      @JsonKey(includeToJson: false) this.variation,
      required final List<ExerciseTranslationSubmissionApi> translations})
      : _muscles = muscles,
        _musclesSecondary = musclesSecondary,
        _equipment = equipment,
        _translations = translations;

  factory _ExerciseSubmissionApi.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSubmissionApiFromJson(json);

  @override
  final int category;
  final List<int> _muscles;

  @override
  List<int> get muscles {
    if (_muscles is EqualUnmodifiableListView) return _muscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_muscles);
  }

  final List<int> _musclesSecondary;

  @override
  @JsonKey(name: 'muscles_secondary')
  List<int> get musclesSecondary {
    if (_musclesSecondary is EqualUnmodifiableListView) return _musclesSecondary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_musclesSecondary);
  }

  final List<int> _equipment;

  @override
  List<int> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  @override
  @JsonKey(name: 'license_author')
  final String author;
  @override
  @JsonKey(includeToJson: false)
  final int? variation;
  final List<ExerciseTranslationSubmissionApi> _translations;

  @override
  List<ExerciseTranslationSubmissionApi> get translations {
    if (_translations is EqualUnmodifiableListView) return _translations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_translations);
  }

  /// Create a copy of ExerciseSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseSubmissionApiCopyWith<_ExerciseSubmissionApi> get copyWith =>
      __$ExerciseSubmissionApiCopyWithImpl<_ExerciseSubmissionApi>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseSubmissionApiToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExerciseSubmissionApi &&
            (identical(other.category, category) || other.category == category) &&
            const DeepCollectionEquality().equals(other._muscles, _muscles) &&
            const DeepCollectionEquality().equals(other._musclesSecondary, _musclesSecondary) &&
            const DeepCollectionEquality().equals(other._equipment, _equipment) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.variation, variation) || other.variation == variation) &&
            const DeepCollectionEquality().equals(other._translations, _translations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      category,
      const DeepCollectionEquality().hash(_muscles),
      const DeepCollectionEquality().hash(_musclesSecondary),
      const DeepCollectionEquality().hash(_equipment),
      author,
      variation,
      const DeepCollectionEquality().hash(_translations));

  @override
  String toString() {
    return 'ExerciseSubmissionApi(category: $category, muscles: $muscles, musclesSecondary: $musclesSecondary, equipment: $equipment, author: $author, variation: $variation, translations: $translations)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseSubmissionApiCopyWith<$Res>
    implements $ExerciseSubmissionApiCopyWith<$Res> {
  factory _$ExerciseSubmissionApiCopyWith(
          _ExerciseSubmissionApi value, $Res Function(_ExerciseSubmissionApi) _then) =
      __$ExerciseSubmissionApiCopyWithImpl;

  @override
  @useResult
  $Res call(
      {int category,
      List<int> muscles,
      @JsonKey(name: 'muscles_secondary') List<int> musclesSecondary,
      List<int> equipment,
      @JsonKey(name: 'license_author') String author,
      @JsonKey(includeToJson: false) int? variation,
      List<ExerciseTranslationSubmissionApi> translations});
}

/// @nodoc
class __$ExerciseSubmissionApiCopyWithImpl<$Res> implements _$ExerciseSubmissionApiCopyWith<$Res> {
  __$ExerciseSubmissionApiCopyWithImpl(this._self, this._then);

  final _ExerciseSubmissionApi _self;
  final $Res Function(_ExerciseSubmissionApi) _then;

  /// Create a copy of ExerciseSubmissionApi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? category = null,
    Object? muscles = null,
    Object? musclesSecondary = null,
    Object? equipment = null,
    Object? author = null,
    Object? variation = freezed,
    Object? translations = null,
  }) {
    return _then(_ExerciseSubmissionApi(
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      muscles: null == muscles
          ? _self._muscles
          : muscles // ignore: cast_nullable_to_non_nullable
              as List<int>,
      musclesSecondary: null == musclesSecondary
          ? _self._musclesSecondary
          : musclesSecondary // ignore: cast_nullable_to_non_nullable
              as List<int>,
      equipment: null == equipment
          ? _self._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<int>,
      author: null == author
          ? _self.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      variation: freezed == variation
          ? _self.variation
          : variation // ignore: cast_nullable_to_non_nullable
              as int?,
      translations: null == translations
          ? _self._translations
          : translations // ignore: cast_nullable_to_non_nullable
              as List<ExerciseTranslationSubmissionApi>,
    ));
  }
}

// dart format on
