# US-007 Browser Smoke Deploy Readiness

## Status

implemented

## Lane

normal

## Product Contract

Prove the public Flutter Web demo shell can be loaded and exercised in a real browser before deployment, with root and `/demo` routes rendering meaningful content and no relevant console errors.

## Relevant Product Docs

- `SPEC.md`
- `README.md`
- `docs/stories/US-006-public-web-demo-shell.md`
- `lib/navigation/app_router.dart`
- `lib/features/public_demo/screens/public_demo_screen.dart`

## Acceptance Criteria

- `/` renders the public demo shell in a real browser.
- `/demo` renders the same public demo shell in a real browser.
- The primary demo CTA can be clicked and leaves the user in the expected public demo state.
- The public demo shell is checked at desktop and mobile-sized viewports.
- Browser console output has no relevant runtime errors from the demo shell.
- Flutter test, analyzer, and web release build proof remain current.

## Design Notes

- Commands: `flutter test`, `flutter analyze`, `flutter build web --release --no-wasm-dry-run`, `flutter run -d web-server`.
- Queries: `scripts/bin/harness-cli.exe query matrix`, browser route checks for `/` and `/demo`.
- API: no backend API changes.
- Tables: no database changes.
- Domain rules: no AI inference, auth, scan history, or Supabase behavior changes.
- UI surfaces: public web demo shell only.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Existing public demo widget test passes through `flutter test`. |
| Integration | Not applicable. |
| E2E | Browser smoke checks for `/`, `/demo`, CTA interaction, console health, and desktop/mobile screenshots. |
| Platform | Flutter Web release build succeeds. |
| Release | Not applicable; remote deploy remains out of scope unless explicitly requested. |

## Harness Delta

This story adds browser smoke evidence after US-006 so future deploy work starts from a verified local public web route.

## Evidence

- Added `lib/core/config/startup_diagnostics_policy.dart` so startup diagnostics are skipped on web and remain enabled off web.
- Updated `lib/main.dart` to avoid running `AppDiagnostics.runDiagnostics()` in the public web shell. This removed startup camera/location/permission diagnostics from web route smoke tests.
- Added `test/startup_diagnostics_policy_test.dart`; it first failed because the policy did not exist, then passed after implementation.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test test\startup_diagnostics_policy_test.dart` passed with 2 tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 3 tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` still reports the existing 45 warning/info baseline.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` succeeds and writes `build\web`.
- Local web server proof used `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat run -d web-server --web-hostname 127.0.0.1 --web-port 8123`.
- Chrome CDP smoke proof checked:
  - `http://127.0.0.1:8123/` has a Plant/Disease page title and Flutter host mounted.
  - `http://127.0.0.1:8123/demo` has a Plant/Disease page title and Flutter host mounted.
  - Desktop viewport `1366x768` renders the public demo shell.
  - Clicking `Try the web demo` shows the expected web inference snackbar.
  - Mobile-sized viewport `390x844` renders `/demo` without layout breakage.
  - Console warning/error collection is empty after disabling startup diagnostics on web.
- Screenshot evidence was captured outside the repo under `C:\Users\duong\AppData\Local\Temp\plant_ai_us007_screenshots_after\`.
