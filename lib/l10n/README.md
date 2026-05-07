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

## Android 13+ Per-App Language Support

When adding a new language (e.g. adding a new `app_<locale>.arb` file), please ensure that the new locale is also registered in:

`android/app/src/main/res/xml/locales_config.xml`

This is required so the new language appears in the Android system settings for per-app language preferences.