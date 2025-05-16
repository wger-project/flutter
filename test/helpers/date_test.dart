import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/date.dart';

void main() {
  group('getDateTimeFromDateAndTime', () {
    test('should correctly generate a DateTime', () {
      expect(
        getDateTimeFromDateAndTime('2025-05-16', '17:02'),
        DateTime(2025, 5, 16, 17, 2),
      );
    });
  });
}
