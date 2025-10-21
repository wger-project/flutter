import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/body_weight_repository.dart';
import 'package:wger/providers/body_weight_state.dart';
import 'package:wger/providers/wger_base_riverpod.dart';

/// Provides a [BodyWeightRepository] for a given [AuthProvider].
/// Usage: ref.watch(bodyWeightRepositoryProvider(authProvider))
final bodyWeightRepositoryProvider = Provider.family<BodyWeightRepository, AuthProvider>(
  (ref, auth) {
    final base = ref.watch(wgerBaseProvider(auth));
    return BodyWeightRepository(base);
  },
);

/// StateNotifier provider for the list of [WeightEntry]s keyed by [AuthProvider].
/// Usage: ref.watch(bodyWeightStateProvider(authProvider)) to get List<WeightEntry>
final bodyWeightStateProvider =
    StateNotifierProvider.family<BodyWeightState, List<WeightEntry>, AuthProvider>(
      (ref, auth) {
        final repo = ref.watch(bodyWeightRepositoryProvider(auth));
        return BodyWeightState(repo);
      },
    );
