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
}
