# US-005 Google Fonts Web Build Compatibility

## Status

implemented

## Lane

normal

## Product Contract

Resolve the Flutter Web build blocker in `google_fonts` exposed after `US-004` without changing the app typography API or unrelated dependencies.

## Relevant Product Docs

- `docs/stories/US-004-platform-safe-inference-boundary.md`
- `pubspec.yaml`
- `pubspec.lock`
- `lib/core/theme/app_typography.dart`

## Acceptance Criteria

- The current `google_fonts` blocker is reproduced and documented.
- Dependency resolver evidence identifies the smallest compatible upgrade.
- The fix does not change app typography call sites.
- `flutter analyze` is rerun.
- `flutter build web --release --no-wasm-dry-run` is rerun to confirm whether the `google_fonts` blocker is removed and to record any next blocker.

## Design Notes

- Commands: `flutter pub outdated --json`, targeted `flutter pub upgrade google_fonts`, `flutter analyze`, `flutter build web --release --no-wasm-dry-run`.
- Queries: `rg -n "GoogleFonts|google_fonts" lib pubspec.yaml pubspec.lock`.
- API: no app API changes.
- Tables: no database changes.
- Domain rules: no disease detection or auth behavior changes.
- UI surfaces: typography appearance should remain Inter/Roboto through the existing `AppTypography` API.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Not applicable; dependency compatibility only. |
| Integration | Not applicable. |
| E2E | Not available until web app compiles and runs. |
| Platform | Web build no longer fails in `google_fonts_variant.dart`; record the next blocker if compilation stops later. |
| Release | Not applicable. |

## Harness Delta

This story records dependency compatibility as the next web build blocker after the inference boundary fix.

## Evidence

- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat pub outdated --json` reported `google_fonts` current `6.2.1`, upgradable `6.3.3`, resolvable/latest `8.1.0`.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat pub upgrade google_fonts` upgraded `google_fonts` from `6.2.1` to `6.3.3` inside the existing `^6.1.0` pubspec constraint.
- `pubspec.lock` also updated Flutter SDK transitive test packages and the lockfile SDK floor to Dart `>=3.9.0` / Flutter `>=3.35.0`; `README.md` was updated to match that resolver floor.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` still reports the existing 45 warning/info baseline.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` succeeds and writes `build\web`.
