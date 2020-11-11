1. Add strings to locales.dart

2. Extract strings to arb files
   flutter pub pub run intl_translation:extract_to_arb --output-dir=lib\l10n lib\locale\locales.dart

3. Generate dart files (in linux you can do lib/l10n/intl_*.arb)
   flutter pub pub run intl_translation:generate_from_arb --output-dir=lib\l10n --no-use-deferred-loading lib/l10n/intl_en.arb lib/l10n/intl_de.arb lib/l10n/intl_messages.arb lib/locale/locales.dart