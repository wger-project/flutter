// filepath: /Users/roland/Entwicklung/wger/flutter/lib/providers/wger_base_riverpod.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

/// Central provider that maps an existing [AuthProvider] (from the provider package)
/// to a [WgerBaseProvider] used by repositories.
///
/// Usage: ref.watch(wgerBaseProvider(authProvider))
final wgerBaseProvider = Provider.family<WgerBaseProvider, AuthProvider>(
  (ref, auth) => WgerBaseProvider(auth),
);
