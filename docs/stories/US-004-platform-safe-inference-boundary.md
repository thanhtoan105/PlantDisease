# US-004 Platform Safe Inference Boundary

## Status

implemented

## Lane

normal

## Product Contract

Keep the existing Android TensorFlow Lite inference behavior available on native platforms while ensuring Flutter Web builds do not import `tflite_flutter`, `dart:ffi`, or native file-processing code through `TensorFlowService`.

## Relevant Product Docs

- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/stories/US-003-flutter-web-vercel-baseline.md`

## Acceptance Criteria

- `lib/core/services/tensorflow_service.dart` becomes a platform-safe public boundary.
- Native platforms keep the current TFLite implementation through a native-only implementation file.
- Web receives a same-shape implementation that initializes safely, exposes labels/configuration, and returns a clear unsupported analysis result instead of importing native FFI code.
- `flutter build web --release --no-wasm-dry-run` is rerun to prove whether the TFLite FFI blocker is removed.
- Any new web compilation blocker discovered after removing the TFLite blocker is recorded.

## Design Notes

- Commands: direct Flutter SDK path at `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat`.
- Queries: `rg -n "TensorFlowService|tensorflow_service" lib`, `flutter build web --release --no-wasm-dry-run`.
- API: keep the static `TensorFlowService` API used by `ai_scan_screen.dart` and `app_diagnostics.dart`.
- Tables: no database changes.
- Domain rules: Android inference behavior should remain unchanged; web inference is explicitly unsupported until a browser model runtime or backend inference story is implemented.
- UI surfaces: no intentional UI changes.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Not added unless a pure service helper is introduced. |
| Integration | Not applicable; no backend or provider contract changes. |
| E2E | Not available until web app compiles and can run in browser. |
| Platform | Web build no longer fails because of `tflite_flutter`/`dart:ffi`; record the next blocker if compilation stops later. |
| Release | Not applicable. |

## Harness Delta

This story records the inference boundary as the next blocker resolution after `US-003`.

## Evidence

- `lib/core/services/tensorflow_service.dart` now conditionally exports a native implementation on `dart.library.io` and a web-safe implementation otherwise.
- The previous native implementation was preserved in `lib/core/services/tensorflow_service_native.dart`.
- `lib/core/services/tensorflow_service_web.dart` provides the same static API without importing `tflite_flutter`, `dart:ffi`, `dart:io`, or native image file processing.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` still reports the existing 45 warning/info baseline and no new analyzer errors from the service split.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` no longer fails on `tflite_flutter` or `dart:ffi`.
- The next blocker is `google_fonts` 6.2.1 failing dart2js constant evaluation in `google_fonts_variant.dart` because `FontWeight` is used as a const map key.
