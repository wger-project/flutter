import 'package:logging/logging.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:wger/models/body_weight/weight_entry.dart';

/*
 * TODO: decide if we want to use the state or just handle a list of entries
 */
class BodyWeightState extends StateNotifier<List<WeightEntry>> {
  final _logger = Logger('BodyWeightState');

  BodyWeightState([super.initial = const []]);

  List<WeightEntry> get items => [...state];

  WeightEntry? getNewestEntry() => state.isNotEmpty ? state.first : null;

  WeightEntry? findById(String id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } on StateError {
      return null;
    }
  }

  WeightEntry? findByDate(DateTime date) {
    try {
      return state.firstWhere((e) => e.date == date);
    } on StateError {
      return null;
    }
  }

  void clear() => state = [];

  void setItems(List<WeightEntry> entries) {
    state = List<WeightEntry>.from(entries);
  }
}
