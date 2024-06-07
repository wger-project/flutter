import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TextPrompt extends StatelessWidget {
  const TextPrompt();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).textPromptTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(AppLocalizations.of(context).textPromptSubheading),
          ),
        ],
      ),
    );
  }
}
