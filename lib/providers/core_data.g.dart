// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(languages)
final languagesProvider = LanguagesProvider._();

final class LanguagesProvider
    extends $FunctionalProvider<AsyncValue<List<Language>>, List<Language>, Stream<List<Language>>>
    with $FutureModifier<List<Language>>, $StreamProvider<List<Language>> {
  LanguagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languagesHash();

  @$internal
  @override
  $StreamProviderElement<List<Language>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Language>> create(Ref ref) {
    return languages(ref);
  }
}

String _$languagesHash() => r'639c1518060a0fcc66fd686405142bf0239d7647';
