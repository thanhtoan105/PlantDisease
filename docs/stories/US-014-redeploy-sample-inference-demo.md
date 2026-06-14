# US-014 Redeploy Sample Inference Demo

## Status

implemented

## Lane

normal

## Product Contract

The public Flutter web demo should deploy the US-013 sample diagnosis result to
a fresh Vercel preview and prove that `/` and `/demo` render the updated demo
flow in a real browser. The deployment must preserve the local-only sample
result contract: no model call, upload, persistence, or production diagnosis
claim is added.

## Relevant Product Docs

- `docs/product/README.md`
- `docs/stories/US-010-public-web-deployment-readiness.md`
- `docs/stories/US-012-redeploy-public-demo-ui-cleanup.md`
- `docs/stories/US-013-web-demo-sample-inference-result.md`

## Acceptance Criteria

- Fresh Flutter test, analyzer, and web release build checks pass before deploy.
- Vercel creates a ready preview deployment for the current branch contents.
- The deployed `/` route renders the public demo shell.
- The deployed `/demo` route renders the upload flow and shows the sample
  result after selecting a valid image and clicking `Detect Disease`.
- Browser smoke reports HTTP 200 and no relevant console errors.
- Any Vercel Deployment Protection access path is recorded for verification.

## Design Notes

- Commands: `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test`,
  `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze`,
  `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run`,
  `vercel deploy --yes`, `vercel inspect`.
- Queries: `scripts/bin/harness-cli.exe query matrix`.
- API: no backend or route contract changes.
- Tables: no data model changes.
- Domain rules: sample diagnosis remains deterministic demo UI copy only.
- UI surfaces: deployed public web `/` and `/demo`.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli.exe story update --id US-014 --unit 1 --integration 1 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Flutter widget tests pass. |
| Integration | Vercel deploy and inspect confirm a ready preview deployment. |
| E2E | Browser smoke confirms deployed sample result flow and clean console. |
| Platform | Flutter analyzer and web release build pass. |
| Release | Preview deployment URL is recorded; production promotion is out of scope. |

## Harness Delta

No harness policy change expected.

## Evidence

- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 10
  tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` passed with no
  issues.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run`
  succeeded and wrote `build\web`.
- `vercel deploy --yes` created preview deployment
  `dpl_H3juBWL7ipZHLjuHEHhskC5ygCop` at
  `https://plant-ai-disease-flutter-fdbgvy3i7.vercel.app`.
- `vercel inspect plant-ai-disease-flutter-fdbgvy3i7.vercel.app` reported
  status `Ready`, target `preview`, created on June 14, 2026 at 09:41:33
  GMT+0700.
- The raw preview URL returned `401 Unauthorized` because Vercel Deployment
  Protection is enabled.
- The Vercel connector created a temporary share URL expiring on June 15, 2026
  at 01:42:42.
- Playwright/Chrome smoke through the share URL loaded `/` with HTTP 200,
  navigated to `/demo`, selected
  `assets/images/sample/Leaf_Algal/IMG_7439_JPG_jpg.rf.d5ad373e6361c19d18f00b74fe170c2c.jpg`
  through the real file chooser, clicked `Detect Disease`, and captured the
  sample result card screenshot at `output/playwright/us014-sample-result.png`.
- Browser smoke reported title `Plant Disease Detection`, one Flutter canvas,
  file chooser upload success, result screenshot capture success, and no
  console errors.
