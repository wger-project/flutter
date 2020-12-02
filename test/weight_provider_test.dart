import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/body_weight.dart';

// Create a MockClient
class MockClient extends Mock implements http.Client {}

// Test Auth provider
final Auth auth = Auth()
  ..token = 'FooBar'
  ..serverUrl = 'https://localhost';

void main() {
  group('fetchPost', () {
    test('Test that the weight entries are correctly loaded', () async {
      final client = MockClient();

      // Mock the server response
      when(client.get(
        'https://localhost/api/v2/weightentry/',
        headers: <String, String>{'Authorization': 'Token ${auth.token}'},
      )).thenAnswer((_) async => http.Response(
          '{"results": [{"id": 1, "date": "2021-01-01", "weight": "80.00"}, '
          '{"id": 2, "date": "2021-01-10", "weight": "99"},'
          '{"id": 3, "date": "2021-01-20", "weight": "100.01"}]}',
          200));

      // Load the entries
      BodyWeight provider = BodyWeight(auth, []);
      await provider.fetchAndSetEntries(client: client);

      // Check that everything is ok
      expect(provider.items, isA<List<WeightEntry>>());
      expect(provider.items.length, 3);
    });

    test('Test adding a new weight entry', () async {
      final client = MockClient();

      // Mock the server response
      when(client.post('https://localhost/api/v2/weightentry/',
              headers: {
                'Authorization': 'Token ${auth.token}',
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: '{"id":null,"weight":"80","date":"2021-01-01T00:00:00.000"}'))
          .thenAnswer(
              (_) async => http.Response('{"id": 25, "date": "2021-01-01", "weight": "80"}', 200));

      // POST the data to the server
      final WeightEntry weightEntry = WeightEntry(date: DateTime(2021, 1, 1), weight: 80);
      final BodyWeight provider = BodyWeight(auth, []);
      final WeightEntry weightEntryNew = await provider.addEntry(weightEntry, client: client);

      // Check that the server response is what we expect
      expect(weightEntryNew.id, 25);
      expect(weightEntryNew.date, DateTime(2021, 1, 1));
      expect(weightEntryNew.weight, 80);
    });

    test('Test deleting an existing weight entry', () async {
      final client = MockClient();

      // Mock the server response
      when(client.delete(
        'https://localhost/api/v2/weightentry/4/',
        headers: {'Authorization': 'Token ${auth.token}'},
      )).thenAnswer((_) async => http.Response('', 200));

      // DELETE the data from the server
      final BodyWeight provider = BodyWeight(auth, [
        WeightEntry(id: 4, weight: 80, date: DateTime(2021, 1, 1)),
        WeightEntry(id: 2, weight: 100, date: DateTime(2021, 2, 2)),
        WeightEntry(id: 5, weight: 60, date: DateTime(2021, 2, 2))
      ]);
      await provider.deleteEntry(4, client: client);

      // Check that the entry was removed from the entry list
      expect(provider.items.length, 2);
    });
  });
}
