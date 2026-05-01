// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GalleryNotifier)
final galleryProvider = GalleryNotifierProvider._();

final class GalleryNotifierProvider
    extends $StreamNotifierProvider<GalleryNotifier, List<GalleryImage>> {
  GalleryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryNotifierHash();

  @$internal
  @override
  GalleryNotifier create() => GalleryNotifier();
}

String _$galleryNotifierHash() => r'c5012c07b5381f7bea275534b65967d0376611ed';

abstract class _$GalleryNotifier extends $StreamNotifier<List<GalleryImage>> {
  Stream<List<GalleryImage>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<GalleryImage>>, List<GalleryImage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<GalleryImage>>, List<GalleryImage>>,
              AsyncValue<List<GalleryImage>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
