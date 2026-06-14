# US-003 Flutter Web Vercel Baseline

## Status

implemented

## Lane

normal

## Product Contract

Create the minimum Flutter Web platform and Vercel static deployment baseline so the project can attempt a public web build and expose the next concrete blockers without changing native Android AI, camera, auth, or data behavior.

## Relevant Product Docs

- `README.md`
- `docs/HARNESS.md`
- `docs/ARCHITECTURE.md`
- `docs/stories/US-001-tooling-codebase-audit.md`
- `docs/stories/US-002-phase-0-web-readiness-audit.md`

## Acceptance Criteria

- Flutter Web platform files exist in the repo.
- Vercel static SPA routing is configured for Flutter Web output.
- The baseline build command is run with the available Flutter SDK.
- Any web compilation blockers are recorded with file references.
- No auth, inference, camera, Supabase, or UI runtime behavior is intentionally changed in this story.

## Design Notes

- Commands: direct Flutter SDK path at `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat`, `flutter create . --platforms web`, `flutter build web --release`, `flutter analyze`.
- Queries: `scripts/bin/harness-cli.exe query matrix`, `rg --files`, targeted blocker scans.
- API: no app API changes.
- Tables: no database or Supabase table changes.
- Domain rules: no disease detection, scan history, auth, or plant library behavior changes.
- UI surfaces: generated web shell only; public demo shell remains future work.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Not applicable; this story does not add unit-level domain logic. |
| Integration | Not applicable; no provider or backend contract changes. |
| E2E | Not available until the app compiles and runs as a web surface. |
| Platform | `flutter create . --platforms web` result, `flutter build web --release` result, and Vercel config presence. |
| Release | Not applicable; deploy is out of scope for this baseline. |

## Harness Delta

This story should leave the matrix with explicit platform proof status and concrete blockers for the next story.

## Evidence

- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat create . --platforms web` created the Flutter Web platform files.
- `vercel.json` now configures static SPA rewrites to `/index.html`.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` completed with the existing 45 warning/info issues from the Phase 0 baseline.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` now recognizes the web platform and starts compilation, then fails because `tflite_flutter` imports `dart:ffi`, which is unavailable for Flutter Web.
- The failing import path starts at `lib/main.dart` -> `lib/app.dart` -> `lib/navigation/app_router.dart` -> `lib/features/main/main_screen.dart` -> `lib/features/ai_scan/screens/disease_scanner_screen.dart` -> `lib/features/ai_scan/screens/ai_scan_screen.dart` -> `lib/core/services/tensorflow_service.dart` -> `package:tflite_flutter/tflite_flutter.dart`.

## Next Blocker

The next story should introduce a platform-safe inference boundary so web builds do not import `tflite_flutter`. The native Android implementation can keep using TFLite, while the web implementation should use either a browser-compatible model runtime or a remote inference backend.
