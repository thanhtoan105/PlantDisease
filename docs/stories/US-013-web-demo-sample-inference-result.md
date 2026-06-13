# US-013 Web Demo Sample Inference Result

## Status

implemented

## Lane

normal

## Product Contract

The public web demo should show a clearly labeled sample diagnosis result after
a valid image is selected and the user taps `Detect Disease`. This result is a
local demo state only: it must not call a model, upload a file, persist data, or
claim real medical/agricultural diagnosis accuracy.

## Relevant Product Docs

- `docs/product/README.md`
- `docs/stories/US-008-web-image-upload-preview-validation.md`
- `docs/stories/US-011-public-demo-cta-upload-affordance-cleanup.md`
- `docs/stories/US-012-redeploy-public-demo-ui-cleanup.md`

## Acceptance Criteria

- `Detect Disease` remains disabled until a valid image is selected.
- After a selected image exists, tapping `Detect Disease` shows a sample result
  card in the public demo.
- The result card labels itself as a demo result, not live AI inference.
- The result includes a sample plant health class, confidence, and care guidance.
- Removing the selected image clears the sample result.
- No network upload, backend call, persistence, or TensorFlow inference is added.

## Design Notes

- Commands: `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test`, `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze`, `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run`.
- Queries: `scripts/bin/harness-cli.exe query matrix`.
- API: no backend or route contract changes.
- Tables: no data model changes.
- Domain rules: result is deterministic UI demo copy only; no real diagnosis.
- UI surfaces: public web demo `/` and `/demo`.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli.exe story update --id US-013 --unit 1 --integration 0 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Widget tests cover sample result display and clearing on remove. |
| Integration | Not required; no backend/provider behavior changes. |
| E2E | Browser screenshot/smoke confirms the sample result renders in the web build. |
| Platform | Flutter analyzer and web release build pass. |
| Release | Deployment/promotion is out of scope unless requested separately. |

## Harness Delta

No harness policy change expected.

## Evidence

- Added a widget test for the sample result flow. It first failed because
  `Demo diagnosis result` was not rendered after tapping `Detect Disease`.
- Updated `lib/features/public_demo/screens/public_demo_screen.dart` with local
  `_showSampleResult` state.
- `Detect Disease` now renders a clearly labeled simulated result card with
  `Sample class: Healthy leaf`, `Confidence: 92% sample score`, and care
  guidance copy.
- The result copy explicitly says it is a simulated web demo result and points
  users to the authenticated full app for native TensorFlow Lite scanning and
  saved history.
- Selecting another image or removing the image clears the sample result.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test test\public_demo_screen_test.dart` passed with 4 widget tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 10 tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` passed with no issues.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` succeeded and wrote `build\web`.
- Local browser smoke served `build\web`, selected a temporary PNG through the
  real file chooser, clicked `Detect Disease`, confirmed HTTP 200/title/clean
  console, and captured sample result screenshot evidence at
  `C:\Users\duong\AppData\Local\Temp\plant-ai-us013-result-card.png`.
