// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream of all locally-synced ingredients, ordered by name. Only those
/// ingredients used in a nutritional plan or log are synced for offline use.

@ProviderFor(allLocalIngredients)
final allLocalIngredientsProvider = AllLocalIngredientsProvider._();

/// Stream of all locally-synced ingredients, ordered by name. Only those
/// ingredients used in a nutritional plan or log are synced for offline use.

final class AllLocalIngredientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ingredient>>,
          List<Ingredient>,
          Stream<List<Ingredient>>
        >
    with $FutureModifier<List<Ingredient>>, $StreamProvider<List<Ingredient>> {
  /// Stream of all locally-synced ingredients, ordered by name. Only those
  /// ingredients used in a nutritional plan or log are synced for offline use.
  AllLocalIngredientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allLocalIngredientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allLocalIngredientsHash();

  @$internal
  @override
  $StreamProviderElement<List<Ingredient>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Ingredient>> create(Ref ref) {
    return allLocalIngredients(ref);
  }
}

String _$allLocalIngredientsHash() => r'fbc70303db57527d9b64540145f52bf5ffbd6808';

/// Per-id lookup for a single ingredient from the local Drift database.
/// Riverpod caches per `id` while listeners exist and disposes otherwise,
/// and concurrent reads of the same id share the same future automatically.

@ProviderFor(ingredientById)
final ingredientByIdProvider = IngredientByIdFamily._();

/// Per-id lookup for a single ingredient from the local Drift database.
/// Riverpod caches per `id` while listeners exist and disposes otherwise,
/// and concurrent reads of the same id share the same future automatically.

final class IngredientByIdProvider
    extends $FunctionalProvider<AsyncValue<Ingredient?>, Ingredient?, FutureOr<Ingredient?>>
    with $FutureModifier<Ingredient?>, $FutureProvider<Ingredient?> {
  /// Per-id lookup for a single ingredient from the local Drift database.
  /// Riverpod caches per `id` while listeners exist and disposes otherwise,
  /// and concurrent reads of the same id share the same future automatically.
  IngredientByIdProvider._({
    required IngredientByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'ingredientByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ingredientByIdHash();

  @override
  String toString() {
    return r'ingredientByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Ingredient?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Ingredient?> create(Ref ref) {
    final argument = this.argument as int;
    return ingredientById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IngredientByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ingredientByIdHash() => r'9b385632124a966070ea4f05660dfc485632f6b4';

/// Per-id lookup for a single ingredient from the local Drift database.
/// Riverpod caches per `id` while listeners exist and disposes otherwise,
/// and concurrent reads of the same id share the same future automatically.

final class IngredientByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Ingredient?>, int> {
  IngredientByIdFamily._()
    : super(
        retry: null,
        name: r'ingredientByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Per-id lookup for a single ingredient from the local Drift database.
  /// Riverpod caches per `id` while listeners exist and disposes otherwise,
  /// and concurrent reads of the same id share the same future automatically.

  IngredientByIdProvider call(int id) => IngredientByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'ingredientByIdProvider';
}

/// Reactive per-id watch for a single ingredient. Re-emits whenever the
/// ingredient row, its image or any of its weight units changes locally
/// (e.g. PowerSync just pulled an update). Emits `null` if no row with
/// that id exists yet.

@ProviderFor(ingredientByIdStream)
final ingredientByIdStreamProvider = IngredientByIdStreamFamily._();

/// Reactive per-id watch for a single ingredient. Re-emits whenever the
/// ingredient row, its image or any of its weight units changes locally
/// (e.g. PowerSync just pulled an update). Emits `null` if no row with
/// that id exists yet.

final class IngredientByIdStreamProvider
    extends $FunctionalProvider<AsyncValue<Ingredient?>, Ingredient?, Stream<Ingredient?>>
    with $FutureModifier<Ingredient?>, $StreamProvider<Ingredient?> {
  /// Reactive per-id watch for a single ingredient. Re-emits whenever the
  /// ingredient row, its image or any of its weight units changes locally
  /// (e.g. PowerSync just pulled an update). Emits `null` if no row with
  /// that id exists yet.
  IngredientByIdStreamProvider._({
    required IngredientByIdStreamFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'ingredientByIdStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ingredientByIdStreamHash();

  @override
  String toString() {
    return r'ingredientByIdStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Ingredient?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Ingredient?> create(Ref ref) {
    final argument = this.argument as int;
    return ingredientByIdStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IngredientByIdStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ingredientByIdStreamHash() => r'c98e915be80c4592803fd4d8ff70b89f79f02137';

/// Reactive per-id watch for a single ingredient. Re-emits whenever the
/// ingredient row, its image or any of its weight units changes locally
/// (e.g. PowerSync just pulled an update). Emits `null` if no row with
/// that id exists yet.

final class IngredientByIdStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Ingredient?>, int> {
  IngredientByIdStreamFamily._()
    : super(
        retry: null,
        name: r'ingredientByIdStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Reactive per-id watch for a single ingredient. Re-emits whenever the
  /// ingredient row, its image or any of its weight units changes locally
  /// (e.g. PowerSync just pulled an update). Emits `null` if no row with
  /// that id exists yet.

  IngredientByIdStreamProvider call(int id) =>
      IngredientByIdStreamProvider._(argument: id, from: this);

  @override
  String toString() => r'ingredientByIdStreamProvider';
}

/// Triggers an ingredient search whenever the filter state changes, debounced
/// to avoid one server request per keystroke. Routes to the REST API when
/// online, to the local-DB subset when offline.

@ProviderFor(searchedIngredients)
final searchedIngredientsProvider = SearchedIngredientsProvider._();

/// Triggers an ingredient search whenever the filter state changes, debounced
/// to avoid one server request per keystroke. Routes to the REST API when
/// online, to the local-DB subset when offline.

final class SearchedIngredientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ingredient>>,
          List<Ingredient>,
          FutureOr<List<Ingredient>>
        >
    with $FutureModifier<List<Ingredient>>, $FutureProvider<List<Ingredient>> {
  /// Triggers an ingredient search whenever the filter state changes, debounced
  /// to avoid one server request per keystroke. Routes to the REST API when
  /// online, to the local-DB subset when offline.
  SearchedIngredientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchedIngredientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchedIngredientsHash();

  @$internal
  @override
  $FutureProviderElement<List<Ingredient>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Ingredient>> create(Ref ref) {
    return searchedIngredients(ref);
  }
}

String _$searchedIngredientsHash() => r'a1a40b390d806d95e6aa23a2e81eeb066d226a91';
