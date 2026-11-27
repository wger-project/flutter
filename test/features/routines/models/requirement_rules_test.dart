import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/routines/models/requirement_rules.dart';

void main() {
  group('RequirementRuleParsing', () {
    test('apiValue round-trips every enum value', () {
      for (final rule in RequirementRule.values) {
        expect(RequirementRuleParsing.fromApiValue(rule.apiValue), rule);
      }
    });

    test('fromApiValue returns null for an unrecognized string', () {
      expect(RequirementRuleParsing.fromApiValue('some_future_rule'), isNull);
    });

    test('fromApiValue maps max_repetitions to RequirementRule.maxRepetitions', () {
      expect(
        RequirementRuleParsing.fromApiValue('max_repetitions'),
        RequirementRule.maxRepetitions,
      );
    });
  });

  group('ConfigRequirements.fromMap', () {
    test('returns null when requirements is null (plain ungated config)', () {
      expect(ConfigRequirements.fromMap(null), isNull);
    });

    test('parses an empty rules list as isEmpty', () {
      final result = ConfigRequirements.fromMap({'rules': <String>[]});

      expect(result, isNotNull);
      expect(result!.isEmpty, isTrue);
      expect(result.allSets, isFalse);
    });

    test('parses the double-progression payload', () {
      final result = ConfigRequirements.fromMap({
        'rules': ['max_repetitions'],
        'all_sets': true,
      });

      expect(result!.rules, [RequirementRule.maxRepetitions]);
      expect(result.allSets, isTrue);
      expect(result.gatesOnMaxRepetitions, isTrue);
      expect(result.gatesOnRepetitions, isFalse);
    });

    test('parses a simple gated-on-repetitions payload', () {
      final result = ConfigRequirements.fromMap({
        'rules': ['repetitions'],
      });

      expect(result!.gatesOnRepetitions, isTrue);
      expect(result.gatesOnMaxRepetitions, isFalse);
      expect(result.allSets, isFalse);
    });

    test('defaults all_sets to false when the key is missing', () {
      final result = ConfigRequirements.fromMap({
        'rules': ['max_repetitions'],
      });

      expect(result!.allSets, isFalse);
    });

    test('coerces a non-boolean all_sets value to false', () {
      final result = ConfigRequirements.fromMap({
        'rules': ['max_repetitions'],
        'all_sets': 'true',
      });

      expect(result!.allSets, isFalse);
    });

    test('drops unrecognized rule strings instead of throwing', () {
      final result = ConfigRequirements.fromMap({
        'rules': ['max_repetitions', 'unrecognized_rule'],
      });

      expect(result!.rules, [RequirementRule.maxRepetitions]);
    });

    test('ignores non-string entries in the rules list', () {
      final result = ConfigRequirements.fromMap({
        'rules': ['max_repetitions', 42, null],
      });

      expect(result!.rules, [RequirementRule.maxRepetitions]);
    });

    test('handles a missing rules key as an empty rule list', () {
      final result = ConfigRequirements.fromMap({'all_sets': true});

      expect(result!.rules, isEmpty);
      expect(result.isEmpty, isTrue);
      expect(result.allSets, isTrue);
    });
  });
}
