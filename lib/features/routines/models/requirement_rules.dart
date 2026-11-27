// keep this list in sync with the backend `manager/consts.py`
enum RequirementRule {
  weight,
  repetitions,
  rir,
  rest,
  maxWeight,
  maxRepetitions,
}

extension RequirementRuleParsing on RequirementRule {
  String get apiValue {
    switch (this) {
      case RequirementRule.weight:
        return 'weight';

      case RequirementRule.repetitions:
        return 'repetitions';

      case RequirementRule.rir:
        return 'rir';

      case RequirementRule.rest:
        return 'rest';

      case RequirementRule.maxWeight:
        return 'max_weight';

      case RequirementRule.maxRepetitions:
        return 'max_repetitions';
    }
  }

  static RequirementRule? fromApiValue(String value) {
    for (final rule in RequirementRule.values) {
      if (rule.apiValue == value) {
        return rule;
      }
    }
    return null;
  }
}

class ConfigRequirements {
  final List<RequirementRule> rules;
  final bool allSets;

  const ConfigRequirements({required this.rules, required this.allSets});

  static ConfigRequirements? fromMap(Map<String, dynamic>? requirements) {
    if (requirements == null) {
      return null;
    }
    final rawRules = (requirements['rules'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .map(RequirementRuleParsing.fromApiValue)
        .whereType<RequirementRule>()
        .toList();
    return ConfigRequirements(rules: rawRules, allSets: requirements['all_sets'] == true);
  }

  bool get isEmpty => rules.isEmpty;

  bool get gatesOnMaxRepetitions => rules.contains(RequirementRule.maxRepetitions);

  bool get gatesOnRepetitions => rules.contains(RequirementRule.repetitions);
}
