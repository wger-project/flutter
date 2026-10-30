import 'package:material_ui/material_ui.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// The amount of characters an exercise description needs to have
const MIN_CHARS_DESCRIPTION = 120;

/// The amount of words an exercise description needs to have
const MIN_WORDS_DESCRIPTION = 15;

/// The amount of characters an exercise name needs to have
const MIN_CHARS_NAME = 5;
const MAX_CHARS_NAME = 40;

String? validateName(String? name, BuildContext context) {
  if (name!.isEmpty) {
    return AppLocalizations.of(context).enterValue;
  }

  if (name.length < MIN_CHARS_NAME || name.length > MAX_CHARS_NAME) {
    return AppLocalizations.of(
      context,
    ).enterCharacters(MIN_CHARS_NAME.toString(), MAX_CHARS_NAME.toString());
  }

  return null;
}

String? validateAuthorName(String? name, BuildContext context) {
  if (name!.isEmpty) {
    return AppLocalizations.of(context).enterValue;
  }

  return null;
}

String? validateExerciseDescription(String? name, BuildContext context) {
  if (name!.isEmpty) {
    return AppLocalizations.of(context).enterValue;
  }

  if (name.length < MIN_CHARS_DESCRIPTION) {
    return AppLocalizations.of(context).enterMinCharacters(MIN_CHARS_DESCRIPTION.toString());
  }

  // Words are tokens with at least one letter, so markdown list markers don't count
  final letter = RegExp(r'\p{L}', unicode: true);
  final words = name.split(RegExp(r'\s+')).where((token) => letter.hasMatch(token)).length;
  if (words < MIN_WORDS_DESCRIPTION) {
    return AppLocalizations.of(context).enterMinWords(MIN_WORDS_DESCRIPTION.toString());
  }

  return null;
}
