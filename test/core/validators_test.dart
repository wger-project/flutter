import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import 'validators_test.mocks.dart';

@GenerateMocks([AppLocalizations])
void main() {
  MockAppLocalizations mockI18n = MockAppLocalizations();

  setUp(() {
    mockI18n = MockAppLocalizations();

    when(mockI18n.enterValue).thenReturn('Please enter a value');
    when(mockI18n.invalidUrl).thenReturn('Invalid URL');
  });

  test('Required field empty returns error', () {
    final result = validateUrl('', mockI18n, required: true);
    expect(result, isNotNull);
  });

  test('Optional field empty returns no error', () {
    final result = validateUrl('', mockI18n, required: false);
    expect(result, isNull);
  });

  test('Invalid URL without http/https returns error', () {
    final result = validateUrl('www.example.com', mockI18n);
    expect(result, isNotNull);
  });

  test('Invalid URL with wrong protocol returns error', () {
    final result = validateUrl('gopher://', mockI18n);
    expect(result, isNotNull);
  });

  test('Valid http URL returns no error', () {
    final result = validateUrl('http://example.com', mockI18n);
    expect(result, isNull);
  });

  test('Valid https URL returns no error', () {
    final result = validateUrl('https://example.com', mockI18n);
    expect(result, isNull);
  });

  test('Scheme-only URL with empty host returns error', () {
    // Uri.parse('http://') succeeds with an empty host; the validator must
    // still reject it.
    expect(validateUrl('http://', mockI18n), isNotNull);
    expect(validateUrl('https://', mockI18n), isNotNull);
  });

  group('validateDateRange', () {
    setUp(() {
      when(mockI18n.endBeforeStart).thenReturn('The end value cannot be before the start');
    });

    test('returns null when end is null', () {
      expect(validateDateRange(DateTime(2024, 1, 1), null, mockI18n), isNull);
    });

    test('returns null when end is after start', () {
      expect(validateDateRange(DateTime(2024, 1, 1), DateTime(2024, 2, 1), mockI18n), isNull);
    });

    test('returns null when end equals start', () {
      final date = DateTime(2024, 1, 1);
      expect(validateDateRange(date, date, mockI18n), isNull);
    });

    test('returns an error when end is before start', () {
      expect(validateDateRange(DateTime(2024, 2, 1), DateTime(2024, 1, 1), mockI18n), isNotNull);
    });
  });
}
