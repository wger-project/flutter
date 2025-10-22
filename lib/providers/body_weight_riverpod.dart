import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight_repository.dart';
import 'package:wger/providers/body_weight_state.dart';

final bodyWeightRepositoryProvider = Provider<BodyWeightRepository>(
  (ref) => BodyWeightRepository(),
);

final bodyWeightStateProvider = StateNotifierProvider<BodyWeightState, List<WeightEntry>>(
  (ref) {
    final repo = ref.watch(bodyWeightRepositoryProvider);
    return BodyWeightState(repo);
  },
);
