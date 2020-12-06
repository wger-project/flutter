import 'package:flutter_test/flutter_test.dart';
import 'package:wger/models/body_weight/weight_entry.dart';

void main() {
  group('fetchPost', () {
    test('Test that the weight entries are correctly converted to json', () async {
      WeightEntry weightEntry = WeightEntry(id: 1, weight: 80, date: DateTime(2020, 12, 31));
      expect(weightEntry.toJson(), {'id': 1, 'weight': '80', 'date': '2020-12-31'});

      weightEntry = WeightEntry(id: 2, weight: 70.2, date: DateTime(2020, 12, 01));
      expect(weightEntry.toJson(), {'id': 2, 'weight': '70.2', 'date': '2020-12-01'});
    });

    test('Test that the weight entries are correctly converted from json', () async {
      WeightEntry weightEntryObj = WeightEntry(id: 1, weight: 80, date: DateTime(2020, 12, 31));
      WeightEntry weightEntry = WeightEntry.fromJson({
        'id': 1,
        'weight': '80',
        'date': '2020-12-31',
      });
      expect(weightEntry.id, weightEntryObj.id);
      expect(weightEntry.weight, weightEntryObj.weight);
      expect(weightEntry.date, weightEntryObj.date);
    });
  });
}
