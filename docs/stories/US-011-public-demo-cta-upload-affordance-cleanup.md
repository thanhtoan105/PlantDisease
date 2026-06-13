# US-011 Public Demo CTA and Upload Affordance Cleanup

## Status

implemented

## Lane

normal

## Product Contract

The public web demo should present one clear image-upload control and clear hero
actions. The upload preview remains near the hero because it is the primary
public demo interaction, while the authenticated application remains a separate
entry point.

## Relevant Product Docs

- `docs/product/README.md`
- `docs/stories/US-006-public-web-demo-shell.md`
- `docs/stories/US-008-web-image-upload-preview-validation.md`
- `docs/stories/US-010-public-web-deployment-readiness.md`

## Acceptance Criteria

- The empty upload panel exposes one upload affordance instead of both a drop
  area and a separate `Choose leaf image` button.
- The empty upload panel copy makes the clickable area explicit.
- The hero CTA that previews the public flow is labeled clearly.
- The hero CTA for the full app makes the authenticated boundary clear.
- Existing selected-image preview and disabled detect behavior remain intact.

## Design Notes

- Commands: `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test`, `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze`, `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run`.
- Queries: `scripts/bin/harness-cli.exe query matrix`.
- API: no backend or route contract changes.
- Tables: no data model changes.
- Domain rules: no upload validation or inference behavior changes.
- UI surfaces: public web demo `/` and `/demo`.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli.exe story update --id US-011 --unit 1 --integration 0 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Public demo widget tests cover CTA labels, absence of duplicate upload button, selected image state, and disabled detect state. |
| Integration | Not required; no provider or backend behavior changes. |
| E2E | Browser screenshot/smoke confirms the refined public demo renders without regressions. |
| Platform | Flutter analyzer and web release build pass. |
| Release | Deployment/promotion is out of scope for this UI refinement. |

## Harness Delta

No harness policy change expected.

## Evidence

- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test test\public_demo_screen_test.dart` first failed because the old `Try the web demo`, `Choose leaf image`, and empty-state copy were still present; it passed after the UI update.
- Updated `lib/features/public_demo/screens/public_demo_screen.dart` so the hero uses `Preview upload flow` and `Open authenticated app`.
- The `Preview upload flow` CTA now scrolls toward the upload panel and shows a snackbar explaining the upload preview boundary.
- Removed the separate `Choose leaf image` button; the empty upload area is now the only upload affordance and says `Click to choose a leaf image`.
- Kept the disabled `Detect Disease` button behavior when no image is selected and the selected-image preview behavior unchanged.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 9 tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` passed with no issues.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` succeeded and wrote `build\web`.
- Local browser smoke served `build\web` at `http://127.0.0.1:8126/`; Chrome/Playwright confirmed HTTP 200, title `Plant Disease Detection`, no relevant console warnings/errors, and the hero CTA interaction did not produce runtime errors.
- Screenshot evidence was written outside the repo:
  - `C:\Users\duong\AppData\Local\Temp\plant-ai-us011-desktop.png`
  - `C:\Users\duong\AppData\Local\Temp\plant-ai-us011-mobile.png`
