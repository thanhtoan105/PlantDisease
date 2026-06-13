# US-008 Web Image Upload Preview Validation

## Status

implemented

## Lane

normal

## Product Contract

The public web demo at `/demo` lets users select a local leaf image, validates basic file requirements before inference, shows a preview for accepted images, and handles missing or invalid image states without crashing.

## Relevant Product Docs

- `SPEC.md`
- `docs/stories/US-006-public-web-demo-shell.md`
- `docs/stories/US-007-browser-smoke-deploy-readiness.md`
- `lib/features/public_demo/screens/public_demo_screen.dart`

## Acceptance Criteria

- `/demo` shows an upload area with file requirements.
- JPG, JPEG, PNG, and WebP files up to 5 MB are accepted.
- Empty files are rejected with a clear message.
- Unsupported file types are rejected with a clear message.
- Files larger than 5 MB are rejected with a clear message.
- Accepted images show a preview and selected filename.
- Users can remove the selected image and return to the empty state.
- `Detect Disease` does not crash when no image is selected and clearly says inference is not wired yet.
- No image is uploaded to a server or persisted in this story.

## Design Notes

- Commands: `flutter test`, `flutter analyze`, `flutter build web --release --no-wasm-dry-run`, Chrome/Playwright smoke.
- Queries: `scripts/bin/harness-cli.exe query matrix`, public demo route checks.
- API: no backend API changes.
- Tables: no database changes.
- Domain rules: validation only; no inference result semantics.
- UI surfaces: public web demo shell upload panel.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-008 --unit 1 --integration 0 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Upload validation policy tests. |
| Integration | Not applicable. |
| E2E | Chrome/Playwright smoke confirms `/demo` renders upload panel and stays stable. |
| Platform | Flutter Web release build succeeds. |
| Release | Not applicable; remote deploy remains out of scope. |

## Harness Delta

This story turns the public shell into the first interactive web demo slice while keeping inference and upload persistence out of scope.

## Evidence

- Added `lib/features/public_demo/models/public_demo_upload_policy.dart` with pure Dart validation for empty files, unsupported extensions, and the 5 MB max size.
- Added `test/public_demo_upload_policy_test.dart`; it first failed because the policy did not exist, then passed after implementation.
- Updated `lib/features/public_demo/screens/public_demo_screen.dart` with a public upload panel, `Choose leaf image`, preview state, `Remove image`, and disabled `Detect Disease` until an image is selected.
- Updated `test/public_demo_screen_test.dart` to cover upload controls and selected-image preview state.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test test\public_demo_upload_policy_test.dart` passed with 4 tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test test\public_demo_screen_test.dart` passed with 3 widget tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 9 tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` remains at the existing 45 warning/info baseline.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` succeeds and writes `build\web`.
- Served `build\web` through a temporary SPA fallback server at `http://127.0.0.1:8124`.
- Playwright CLI with Chrome channel captured `/demo` screenshots:
  - `C:\Users\duong\AppData\Local\Temp\plant_ai_us008_demo_desktop.png`
  - `C:\Users\duong\AppData\Local\Temp\plant_ai_us008_demo_mobile.png`
  - `C:\Users\duong\AppData\Local\Temp\plant_ai_us008_demo_mobile_full.png`
- Chrome CDP console check for `http://127.0.0.1:8124/demo` confirmed the Flutter host mounted and relevant console warning/error collection was empty.
- Out of scope: drag-and-drop, sample image assets, AI inference, server upload, persistence, and remote Vercel deploy.
