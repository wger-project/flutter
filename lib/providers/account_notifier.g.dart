// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountNotifier)
final accountProvider = AccountNotifierProvider._();

final class AccountNotifierProvider extends $AsyncNotifierProvider<AccountNotifier, Account?> {
  AccountNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountNotifierHash();

  @$internal
  @override
  AccountNotifier create() => AccountNotifier();
}

String _$accountNotifierHash() => r'c7b8d7ff24bf27f3977f2796166a2f624f442159';

abstract class _$AccountNotifier extends $AsyncNotifier<Account?> {
  FutureOr<Account?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Account?>, Account?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Account?>, Account?>,
              AsyncValue<Account?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
