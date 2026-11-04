# Translations for the app

These files are usually edited on weblate, and not directly in the repo:

<https://hosted.weblate.org/engage/wger/>

## Maintenance

Use the numeric placeholder in grammatical plural branches, including `one`:
`{count, plural, one{{count} week} other{{count} weeks}}`. In some languages,
`one` also applies to numbers such as 21; it is not an exact match for 1.
Use exact selectors such as `=1` for wording that really is specific to that
number, for example `yesterday`. Keep existing exact selectors when editing
plural messages, and have translators review the changed source strings in Weblate.

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

## Adding a new language

When a new `app_<locale>.arb` file is added (usually by a Weblate PR), register the locale in:

- `android/app/src/main/res/xml/locales_config.xml`, so the language appears in the Android 13+
  per-app language settings (uses `pt-BR`, not `pt_BR`)
- `ios/Runner/Info.plist` under `CFBundleLocalizations`, so iOS offers the language for the app
- `lib/l10n/language_native_names.dart`, so the language picker in the settings shows its native
  name
