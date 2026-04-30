// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_url_prefix_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Detects and caches the absolute URL prefix for server-side media
/// files (e.g. `https://wger.de/media/`, or for CDN-fronted deployments
/// `https://cdn.example.com/bucket1/`).
///
/// On first build the value is loaded from SharedPreferences. If
/// nothing is cached and the user is logged in, a one-shot probe
/// against `/api/v2/exerciseimage/?limit=1` extracts the prefix from
/// the first result's `image` URL.
///
/// State semantics:
///   - `null` — not yet detected; consumers should fall back to the
///     default prefix
///   - non-null — full URL prefix
///
/// Cleared on logout.

@ProviderFor(MediaUrlPrefixNotifier)
final mediaUrlPrefixProvider = MediaUrlPrefixNotifierProvider._();

/// Detects and caches the absolute URL prefix for server-side media
/// files (e.g. `https://wger.de/media/`, or for CDN-fronted deployments
/// `https://cdn.example.com/bucket1/`).
///
/// On first build the value is loaded from SharedPreferences. If
/// nothing is cached and the user is logged in, a one-shot probe
/// against `/api/v2/exerciseimage/?limit=1` extracts the prefix from
/// the first result's `image` URL.
///
/// State semantics:
///   - `null` — not yet detected; consumers should fall back to the
///     default prefix
///   - non-null — full URL prefix
///
/// Cleared on logout.
final class MediaUrlPrefixNotifierProvider
    extends $AsyncNotifierProvider<MediaUrlPrefixNotifier, String?> {
  /// Detects and caches the absolute URL prefix for server-side media
  /// files (e.g. `https://wger.de/media/`, or for CDN-fronted deployments
  /// `https://cdn.example.com/bucket1/`).
  ///
  /// On first build the value is loaded from SharedPreferences. If
  /// nothing is cached and the user is logged in, a one-shot probe
  /// against `/api/v2/exerciseimage/?limit=1` extracts the prefix from
  /// the first result's `image` URL.
  ///
  /// State semantics:
  ///   - `null` — not yet detected; consumers should fall back to the
  ///     default prefix
  ///   - non-null — full URL prefix
  ///
  /// Cleared on logout.
  MediaUrlPrefixNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaUrlPrefixProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaUrlPrefixNotifierHash();

  @$internal
  @override
  MediaUrlPrefixNotifier create() => MediaUrlPrefixNotifier();
}

String _$mediaUrlPrefixNotifierHash() => r'ecf75672fed14eeba32b38928f040de573ff9c34';

/// Detects and caches the absolute URL prefix for server-side media
/// files (e.g. `https://wger.de/media/`, or for CDN-fronted deployments
/// `https://cdn.example.com/bucket1/`).
///
/// On first build the value is loaded from SharedPreferences. If
/// nothing is cached and the user is logged in, a one-shot probe
/// against `/api/v2/exerciseimage/?limit=1` extracts the prefix from
/// the first result's `image` URL.
///
/// State semantics:
///   - `null` — not yet detected; consumers should fall back to the
///     default prefix
///   - non-null — full URL prefix
///
/// Cleared on logout.

abstract class _$MediaUrlPrefixNotifier extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
