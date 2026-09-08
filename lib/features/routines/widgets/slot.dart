import 'package:flutter/material.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/routines/models/base_config.dart';
import 'package:wger/features/routines/models/requirement_rules.dart';
import 'package:wger/features/routines/models/slot_entry.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class ProgressionRulesInfoBox extends StatelessWidget {
  final Exercise exercise;
  final SlotEntry? entry;

  const ProgressionRulesInfoBox(this.exercise, {super.key, this.entry});

  ConfigRequirements? _findActiveRequirements(SlotEntry entry) {
    final allConfigLists = <List<BaseConfig>>[
      entry.weightConfigs,
      entry.maxWeightConfigs,
      entry.repetitionsConfigs,
      entry.maxRepetitionsConfigs,
      entry.nrOfSetsConfigs,
      entry.maxNrOfSetsConfigs,
      entry.rirConfigs,
      entry.maxRirConfigs,
      entry.restTimeConfigs,
      entry.maxRestTimeConfigs,
    ];

    for (final configs in allConfigLists) {
      for (final config in configs) {
        final parsed = ConfigRequirements.fromMap(config.requirements);
        if (parsed != null && !parsed.isEmpty) {
          return parsed;
        }
      }
    }

    return null;
  }

  String _describe(AppLocalizations i18n, ConfigRequirements? req) {
    if (req == null) {
      return i18n.progressionRules;
    }

    if (req.gatesOnMaxRepetitions && req.allSets) {
      return i18n.progressionRulesDoubleProgression;
    }

    if (req.gatesOnMaxRepetitions) {
      return i18n.progressionRulesGatedOnMaxReps;
    }

    if (req.gatesOnRepetitions) {
      return i18n.progressionRulesGatedOnReps;
    }

    return i18n.progressionRules;
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final i18n = AppLocalizations.of(context);

    final activeRequirements = entry != null ? _findActiveRequirements(entry!) : null;

    return Column(
      children: [
        ListTile(
          title: Text(
            exercise.getTranslation(languageCode).name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          tileColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(
            _describe(i18n, activeRequirements),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
