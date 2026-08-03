# Plan: Material You dynamic color support

Status: **PLANNED - not implemented**

Context: this plan was produced to be picked up in a fresh opencode session.
Read this file, follow the steps in order, then delete this file (or move it to
`docs/archived/`) once the implementation and tests are merged.

---

## 1. Goal

Let users opt in to Material You dynamic colors (Android 12+, API 31+) so the
app palette follows the system wallpaper instead of the fixed wger seed colors.
When the platform does not support dynamic color (or the user opts out), keep
the existing wger themes unchanged.

## 2. Current state

- Themes are built in `lib/theme/theme.dart` from fixed seeds via
  `SeedColorScheme.fromSeeds` + `FlexThemeData.light/dark` (`wgerLightTheme`,
  `wgerDarkTheme`, `wgerLightThemeHc`, `wgerDarkThemeHc`).
- `MaterialApp` in `lib/main.dart:204` wires `theme`, `darkTheme`,
  `highContrastTheme`, `highContrastDarkTheme`, and `themeMode` (system/light/
  dark) from `AppSettings.themeMode`.
- The only theme setting UI is `lib/features/account/widgets/settings/theme.dart`
  (a `ThemeMode` dropdown).
- `AppSettings` is a freezed class in `lib/core/app_settings_notifier.dart`;
  persisted via `SharedPreferencesAsync` with keys in `lib/core/consts.dart`.
- No `dynamic_color` package, no `DynamicColorBuilder`, no dynamic scheme usage
  anywhere. Grep confirmed zero matches for `dynamicColor`/`dynamicScheme`.

## 3. Approach

Use the official Flutter `dynamic_color` package. Its `DynamicColorBuilder`
widget provides `ColorScheme? light` and `ColorScheme? dark` (null when the
platform doesn't support dynamic color). When enabled and non-null, feed these
schemes into `FlexThemeData.light/dark(colorScheme: ...)` so all existing
sub-themes, app-bar style, and typography keep working. Otherwise fall back to
the existing seed themes.

### Design decisions

1. **Opt-in setting** (default off). Keep the existing seed themes the default
   so existing users see no change. Expose a `useDynamicColor` boolean in
   `AppSettings`.
2. **DynamicColorBuilder wraps MaterialApp** (not `themeBuilder`). The builder
   gives both light and dark schemes in one place regardless of current
   brightness, so we can build both `theme:` and `darkTheme:` and let
   `ThemeMode` keep working as today.
3. **High contrast**: keep the existing seed HC themes as-is. Optionally map
   Android 13+ HC dynamic variants later; not in scope now (note it in the
   implementation as a TODO, do not build it).
4. **Fallback is automatic**: `dynamic_color` hands back null schemes on
   unsupported platforms; we then just use the seed themes, so enabling the
   setting is safe everywhere (Android < 12, iOS, desktop, web).

## 4. Implementation steps

### Step 1 - Dependency

- Add `dynamic_color: ^1.7.0` (check latest on pub.dev) to `dependencies` in
  `pubspec.yaml`.
- Run `dart pub get`.

### Step 2 - Theme builders in `lib/theme/theme.dart`

- Add a function that builds a `ThemeData` from a provided `ColorScheme`,
  mirroring the existing `FlexThemeData.light/dark` config:

  ```dart
  ThemeData wgerThemeFromScheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return (isDark ? FlexThemeData.dark : FlexThemeData.light)(
      colorScheme: scheme,
      useMaterial3: true,
      appBarStyle: isDark ? null : FlexAppBarStyle.primary, // keep parity with wgerLightTheme
      subThemesData: wgerSubThemeData,
      textTheme: wgerTextTheme,
    );
  }
  ```

- Refactor `wgerLightTheme`, `wgerDarkTheme`, `wgerLightThemeHc`,
  `wgerDarkThemeHc` to use this helper (optional but keeps config in one
  place). Existing final fields must keep their names and behavior.

### Step 3 - Setting + persistence

In `lib/core/app_settings_notifier.dart`:

- Add `@Default(false) bool useDynamicColor` to the `AppSettings` freezed
  factory.
- Add `_loadUseDynamicColor()` reading a new key, and `setUseDynamicColor(bool)`
  following the exact pattern of `setKeepDataOnLogout` (update state via
  `copyWith`, persist bool).
- In `build()`, load it and pass it into `AppSettings(...)`.
- Regenerate freezed code: `dart run build_runner build --delete-conflicting-outputs`
  (this updates `app_settings_notifier.freezed.dart`).

In `lib/core/consts.dart`:

- Add `const PREFS_USE_DYNAMIC_COLOR = 'useDynamicColor';`

### Step 4 - Wire in `lib/main.dart`

- Wrap the `MaterialApp` returned in the `data:` branch with
  `DynamicColorBuilder(builder: (lightScheme, darkScheme) { ... })`.
  (`loading:`/`error:` branches can stay as-is or use the same wrapper -
  keep them minimal.)
- Inside the builder, read `useDynamicColor` from
  `appSettingsProvider` (add a `select` for it, like `themeMode`).

  ```dart
  final useDynamic = ref.watch(
    appSettingsProvider.select((s) => s.value?.useDynamicColor ?? false),
  );
  final light = useDynamic && lightScheme != null
      ? wgerThemeFromScheme(lightScheme)
      : wgerLightTheme;
  final dark = useDynamic && darkScheme != null
      ? wgerThemeFromScheme(darkScheme)
      : wgerDarkTheme;
  ```

- Pass `theme: light`, `darkTheme: dark`; keep `themeMode`, `highContrastTheme`,
  `highContrastDarkTheme`, locale, routes, etc. unchanged.

### Step 5 - Settings UI

In `lib/features/account/widgets/settings/theme.dart`:

- Add a `SwitchListTile` (or `ListTile` + `Switch`) below the theme mode
  dropdown: title = new i18n string, value = `useDynamicColor`, onChanged calls
  `ref.read(appSettingsProvider.notifier).setUseDynamicColor(value)`.
- Give it a `ValueKey('useDynamicColorSwitch')` for tests (matches the
  `ValueKey('themeModeDropdown')` convention).

Localization:

- Add the new key to `lib/l10n/app_en.arb` (e.g. `"useDynamicColor": "Use
  dynamic color (system wallpaper)"` and maybe a description). The non-English
  `app_*.arb` files are translated via Weblate; only edit `app_en.arb`
  (see `lib/l10n/README.md`).
- Regenerate: `flutter gen-l10n` (l10n.yaml already configures output to
  `lib/l10n/generated`).

### Step 6 - Tests

Update/add in `test/`:

- `test/core/app_settings_notifier_test.dart`: follow the existing pattern
  (e.g. keep-data-on-logout tests) to assert `useDynamicColor` defaults to
  false, persists true/false, and is read back.
- `test/features/account/widgets/settings_test.dart`: toggle the new switch and
  assert the notifier state changes. Update any snapshot/full-widget builders
  that construct `AppSettings` directly (adding a field may break positional
  or `copyWith` calls - fix compiler errors).
- Consider a small `test/theme/theme_test.dart` asserting `wgerThemeFromScheme`
  returns a theme whose `colorScheme.primary` equals the passed scheme's primary
  for both brightnesses.
- If `lib/main.dart` widget test exists that pumps `MaterialApp`, keep it
  passing - `DynamicColorBuilder` renders child directly on non-Android.

## 5. Verification

- `dart run build_runner build --delete-conflicting-outputs`
- `dart format lib test`
- `dart analyze`
- `dart run flutter test` (or the repo's test command - check README /
  `flutter test` is the standard here)
- Manual: run on an Android 12+ emulator, enable the setting, verify palette
  follows wallpaper; disable and verify wger blue returns; run on desktop/web
  and verify the setting is a harmless no-op.

## 6. Out of scope / follow-ups

- iOS 18+ and macOS 26 dynamic color (package supports it; wire later if wanted).
- Mapping Android high-contrast dynamic variants into `highContrastTheme`.
- Making dynamic color the default instead of opt-in.

## 7. Files touched (summary)

| File | Change |
| --- | --- |
| `pubspec.yaml` | add `dynamic_color` |
| `lib/theme/theme.dart` | add `wgerThemeFromScheme`, optionally refactor existing themes |
| `lib/core/app_settings_notifier.dart` | new `useDynamicColor` field + loader/setter |
| `lib/core/app_settings_notifier.freezed.dart` | regenerated |
| `lib/core/consts.dart` | new prefs key |
| `lib/main.dart` | `DynamicColorBuilder` + dynamic themes |
| `lib/features/account/widgets/settings/theme.dart` | new switch |
| `lib/l10n/app_en.arb` | new string |
| `lib/l10n/generated/*` | regenerated |
| `test/core/app_settings_notifier_test.dart` | new tests |
| `test/features/account/widgets/settings_test.dart` | new test |
| `test/theme/theme_test.dart` | new (optional) |
