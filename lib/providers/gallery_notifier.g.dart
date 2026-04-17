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
    extends $AsyncNotifierProvider<GalleryNotifier, List<gallery.Image>> {
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

String _$galleryNotifierHash() => r'5d2d8a276165112068621001d674669ff67f4b33';

abstract class _$GalleryNotifier extends $AsyncNotifier<List<gallery.Image>> {
  FutureOr<List<gallery.Image>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<gallery.Image>>, List<gallery.Image>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<gallery.Image>>, List<gallery.Image>>,
              AsyncValue<List<gallery.Image>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
