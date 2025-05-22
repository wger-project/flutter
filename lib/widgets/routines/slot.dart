import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';

class ProgressionRulesInfoBox extends StatelessWidget {
  final Exercise exercise;

  const ProgressionRulesInfoBox(this.exercise, {super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final i18n = AppLocalizations.of(context);

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
            i18n.progressionRules,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
