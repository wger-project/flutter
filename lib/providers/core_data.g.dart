// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LanguageNotifier)
const languageProvider = LanguageNotifierProvider._();

final class LanguageNotifierProvider
    extends $StreamNotifierProvider<LanguageNotifier, List<Language>> {
  const LanguageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languageNotifierHash();

  @$internal
  @override
  LanguageNotifier create() => LanguageNotifier();
}

String _$languageNotifierHash() => r'7945fdd6a4a80c381615b153209e4b70d9c81332';

abstract class _$LanguageNotifier extends $StreamNotifier<List<Language>> {
  Stream<List<Language>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Language>>, List<Language>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Language>>, List<Language>>,
              AsyncValue<List<Language>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
