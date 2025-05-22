# Translations for the app

These files are usually edited on weblate, and not directly in the repo:

<https://hosted.weblate.org/engage/wger/>

## Maintenance

Find keys that are not used in the code anymore:

```bash
flutter pub add --dev translations_cleaner
flutter pub run translations_cleaner list-unused-terms
```

Remove unused keys from the arb files (this removes both `key` as well as `@key`):

```bash
cd lib/l10n
dart remove_keys.dart arbKey1 anotherArbKey
```