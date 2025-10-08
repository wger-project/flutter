import 'package:wger/l10n/generated/app_localizations.dart';

String? validateUrl(String? value, AppLocalizations i18n, {bool required = true}) {
  // Required?
  if (required && (value == null || value.trim().isEmpty)) {
    return i18n.enterValue;
  }

  if (!required && (value == null || value.trim().isEmpty)) {
    return null;
  }
  value = value!.trim();

  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    return i18n.invalidUrl;
  }

  // Try to parse as URI
  try {
    final uri = Uri.parse(value);
    if (!uri.hasScheme || !uri.hasAuthority) {
      return i18n.invalidUrl;
    }
  } catch (e) {
    return i18n.invalidUrl;
  }

  return null;
}
