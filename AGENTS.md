# wger Flutter app

Flutter (SDK 3.10+) with flutter_riverpod v3, drift, freezed + json_serializable for codegen.

## Verify after edits

- `flutter analyze` — must be zero issues
- `flutter test` — or scope: `flutter test test/<feature>_test.dart`
- After touching anything with `@freezed` / `@JsonSerializable` / drift annotations: `dart run build_runner build --delete-conflicting-outputs`, then `dart format .`. A rebuild always rewrites the riverpod debug hashes in `app_settings_notifier.g.dart`, `auth_notifier.g.dart`, `powersync.g.dart` and `health_sync.g.dart`; revert those unless you touched their source.

## Layout

```
lib/
├── features/<feature>/   feature domains, named after the Django app in wger/server/wger/<app>/ (same names as wger-react)
├── core/                 cross-cutting infrastructure and the app shell
│   ├── network/            wger_base, base_provider, the whole session/token layer (auth_notifier, auth_http_client, ...)
│   ├── widgets/            generic widgets (DecimalInputWidget, FormSubmitButton, ConfirmDeleteDialog, ...)
│   ├── widgets/dashboard/  dashboard cards, composes every feature (dashboard is not a feature)
│   ├── formatting/, exceptions/
│   └── *.dart              helpers (date, validators, snackbar, ...) and shell screens (home_tabs, splash, update_*)
├── database/             the single Drift AppDatabase, can't be split per feature
│   ├── powersync/tables/   one file per domain, row classes via @UseRowClass
│   └── converters/         UtcDateTimeConverter, DateOnlyTextConverter, ...
├── powersync/            sync schema, upload connector, diagnostics
├── l10n/                 app_*.arb + generated/, see lib/l10n/README.md
├── theme/
└── main.dart
```

Features: `exercises`, `routines` (Django `manager`, includes gym mode and logs), `nutrition`, `measurements` (also body
weight), `gallery`, `trophies`, `account` (user profile and settings, Django `core`), `auth` (login/MFA UI only, the
session layer is in `core/network/`), `health` (platform health sync, no Django app). Each feature uses this skeleton,
leaving out what it doesn't need and never inventing other top-level names:

```
features/<feature>/
├── models/      @freezed entities, filters, enums
├── providers/   notifiers AND repositories (<name>_repository.dart, <name>_notifier.dart)
├── screens/     full screens (<name>_screen.dart)
├── widgets/     UI fragments, forms under widgets/forms/ or widgets/<area>/
└── <name>.dart  feature-wide helpers (validators.dart, gym_mode.dart), no helpers/ folder
```

- **`core/` or feature?** Only promote to `core/` when two unrelated features use it. When in doubt, keep it in the
  feature. Don't add new `core/` → `features/` imports; the existing ones are the shell (dashboard, home tabs, app bar)
  and the logout wiring in `auth_notifier`.
- **Drift tables** go into `database/powersync/tables/<domain>.dart`, not into the feature; the model in `models/`
  provides the `fromDb` constructor.
- **Codegen output** (`*.g.dart`, `*.freezed.dart`) sits next to its source and is committed.
- **Imports:** `package:wger/...` in new code; the few relative imports are leftovers, don't copy them.
- **Naming:** snake_case files and folders, plural feature names.

```
test/
├── features/<feature>/..., core/, database/, powersync/   mirror lib/ one file per source file (<name>_test.dart)
├── helpers/              in_memory_drift, fake_auth_notifier, fake_auth_environment, ...
├── fixtures/             raw JSON API responses (fixture_reader.dart)
└── screenshots/          store screenshot scene builders
test_data/                shared Dart fixtures (getTestRoutine(), ...), structural variants stay in the test
integration_test/         screenshot driver
```

- **Test file = source file + `_test`, same path:** `lib/features/measurements/widgets/forms/entry.dart` is tested in
  `test/features/measurements/widgets/forms/entry_test.dart`. One test file per source file, no merged or split files.
- `*.mocks.dart` are generated per test file by mockito (`@GenerateMocks`) and live next to it.

## Stack-specific rules

- **Riverpod:**
  - Notifiers go through a repository; no direct DB or `wgerBase` access in a notifier.
  - After mutations that change server state, `ref.invalidate(...)` the affected provider(s).
  - Reading an `AsyncValue` requires handling `loading` and `error` — don't shortcut with `.value!`.
  - Don't leak providers across screens — keep scope tight (`autoDispose` where appropriate).
- **Decimal number inputs:** never wire a raw `TextFormField` straight to `NumberFormat.parse` — keyboards can't be pinned to a locale, so a typed `.` in a `,`-locale is silently mis-read as grouping (`80.5` → `805`). Use `DecimalInputWidget`, or for a plain field add `inputFormatters: [LocalizedDecimalInputFormatter(numberFormat.symbols.DECIMAL_SEP)]`.
- **Codegen drift:** if a `*.g.dart` / `*.freezed.dart` is committed without the matching source change (or vice versa), the build is broken. Re-run `build_runner` and stage both.
- **`// ignore:` comments:** don't add new ones to silence the analyzer. Fix the underlying issue. If genuinely unfixable, explain why in the same line.
- **Drift migrations:** schema bumps need a `MigrationStrategy` that handles existing data. Don't drop and recreate.
- **New columns on PowerSync-synced tables:** there are no client-side migrations; the views regenerate for free, but pre-existing rows keep their old `ps_data` JSON and read NULL for the new column until re-downloaded (which only happens on a sync-rules change or a server-side backfill that touches the rows). So: make the Drift column `.nullable()` even when the domain is non-nullable, map NULL to defaults in a `fromDb` constructor wired via `@UseRowClass(Model, constructor: 'fromDb')` (model fields stay non-null, consumers untouched), and use NULL-safe SQL where the column is queried (`isNotValue(x)`, not `equals(x).not()`). Keep the defaults permanently: installs that skip versions re-open the NULL window until their first full sync. Reference: `lib/database/powersync/tables/measurements.dart` + the measurement models.
- **Date columns in Drift:** a Django `DateTimeField` column needs `UtcDateTimeConverter`, a `DateField` column needs `DateOnlyTextConverter` (never the other way round). A synced `DateField` must also be listed in `_dateOnlyFields` in `lib/powersync/connector.dart`, or the upload sends a full timestamp that Django rejects.
- **PowerSync column types:** the `ps.Column` type must match the Drift column. Bool and int columns need `ps.Column.integer`; behind a `ps.Column.text` a bool reads `'0'` and Dart's `'0' != 0` turns every row `true`. In-memory tests can't catch this.
- **REST write, local read:** a REST write reaches the local DB only after the next sync. Don't `getById` the row right after a POST; use the response or a nullable lookup with a fallback.
- **Logs:** never log a secret at any level (tokens, auth response bodies, deep-link URIs with a `#token=` fragment). Logs are exported into public GitHub issues by the bug-report flow.
- **New language:** a new `lib/l10n/app_<locale>.arb` also needs the locale in `locales_config.xml`, iOS `Info.plist` and `language_native_names.dart`, see `lib/l10n/README.md`.
- **Create/edit forms:** the form owns an editable `_draft` of the entity, seeded once in `initState` (`widget.session ?? Entity(...defaults)`); create vs edit follows from `_draft.id == null`. Never mutate the passed-in or stream-sourced object in place, and never build the default in the widget constructor (it re-runs every rebuild and drops in-progress edits). Mutate via `copyWith` (entity models are `@freezed`). If the entity is fed from a stream and its identity can change under the form (e.g. a lazily created row arrives late), re-seed in `didUpdateWidget` only when the `id` changes. `SessionForm` is the reference.
- **Text-field wiring:** default to controllerless `TextFormField(initialValue: _draft.x, onSaved: (v) => _draft = _draft.copyWith(x: v))`. Reach for a `TextEditingController` ONLY when you need imperative access to the text (quick +/- buttons, autocomplete fill, clear button, format-while-typing, cross-field sync). A controller is state: create it in `initState`, seed once, `dispose()` it; never as a field on a `ConsumerWidget`/`StatelessWidget`, never `TextEditingController(...)` inside `build`, never `controller.text = ` inside `build`. `MeasurementCategoryForm` is the reference for plain text fields, `SessionForm`'s notes field for a justified controller.

## Tests

- **Prove a test can fail.** After writing one, break the production side it guards (flip a type, delete the branch, drop a registry entry) and watch it go red, then restore. A test nobody has seen fail is a guess. This is how the suite grew tests that could never fail: a finder comparing element types against a widget type, an `every(...)` without an `expect`, a `contains('10')` that the prefilled `100` already satisfied, a file without the `_test` suffix that the runner never collected.
- **Don't test library behavior.** No tests that only show that Drift stores a column, Riverpod rebuilds, freezed generates `copyWith`/`==` or `json_serializable` maps a field; test our own code (custom mappings, overrides, logic).
- **Layering:** repositories are tested against a real in-memory Drift DB (`test/helpers/in_memory_drift.dart`), notifiers against a mocked repository (`MockFooRepository`, never a `_FakeFoo extends Foo`), widgets with `authProvider.overrideWith(() => FakeAuthNotifier(...))` from `test/helpers/fake_auth_notifier.dart` instead of seeding prefs and stubbing every auto-login request. One test file per source file, mirroring its path.
- **Test the clearing, not just the change.** Every bug this rule would have caught came from a null crossing a boundary: `toCompanion()` mapping null to `Value.absent()` (an update then leaves the column untouched), a hand-written `copyWith` with `?? this.x` swallowing a cleared field. When a field becomes editable, assert non-null → null against the stored row, not only non-null → non-null.
- **Test the boundary day of a date range.** Callers pass calendar days, entries carry timestamps, and the mismatch hides in the edges: an entry recorded during the end day, the day after, the start day. Same for anything counting days: `difference().inDays` measures elapsed time, so a range spanning the spring-forward switch comes up one day short. Count calendar days as UTC midnights.
- **Assert instants, never the local wall clock.** `expect(converted, DateTime.parse('...11:15'))` only holds in one zone; use `isAtSameMomentAs` against a `DateTime.utc(...)`, or compare UTC components. CI pins `TZ=Europe/Berlin`, so a local-time assumption stays invisible there and turns the suite red for everyone else.
- **Capture the payload on REST writes.** `verify(base.post(any, uri))` only pins the routing; a renamed or dropped field surfaces as a server-side 400. Use `verify(base.post(captureAny, uri)).captured` and assert the wire names.
- **Structural fixture variants belong in the test**, not in the shared corpus in `test_data/`: growing `getTestRoutine()` shifts expectations in dozens of files. Build the superset slot, the rest day, the empty plan locally. (This is why supersets had no coverage at all: the shared fixture defined what was testable.)
- **Widget tests:** `tester.view.physicalSize`/`devicePixelRatio` always with `addTearDown(tester.view.reset)`, and every test sets the size it needs itself — two log-screen tests were silently living off the one a previous test left behind. `installFakeAuthEnvironment()` registers a `setUp`, so it goes at the top of `main()`; calling it inside another `setUp` throws at runtime.

## Scope

Make the minimum change requested. Don't refactor adjacent code, rename things, or move helpers unless explicitly asked. Mention adjacent issues as follow-ups.
