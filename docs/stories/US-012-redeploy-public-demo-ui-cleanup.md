# US-012 Redeploy Public Demo UI Cleanup

## Status

implemented

## Lane

normal

## Product Contract

The refined public demo UI from US-011 should be deployed to a Vercel preview
and verified in a real browser. The deployed build should show the clarified
hero CTAs and the single upload affordance without regressing page load,
console health, or mobile layout.

## Relevant Product Docs

- `docs/product/README.md`
- `docs/stories/US-010-public-web-deployment-readiness.md`
- `docs/stories/US-011-public-demo-cta-upload-affordance-cleanup.md`

## Acceptance Criteria

- Fresh Flutter tests pass before deployment.
- Fresh analyzer and web release build pass before deployment.
- Vercel CLI creates a ready preview deployment.
- Browser smoke confirms the deployed `/` route renders the US-011 CTA labels.
- Browser smoke confirms the deployed upload panel no longer shows a separate
  `Choose leaf image` button.
- Browser smoke checks desktop and mobile screenshots plus console health.

## Design Notes

- Commands: `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test`, `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze`, `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run`, `vercel deploy --yes`, `vercel inspect`.
- Queries: `scripts/bin/harness-cli.exe query matrix`.
- API: no backend or route contract changes.
- Tables: no data model changes.
- Domain rules: no upload validation or inference behavior changes.
- UI surfaces: deployed public web `/`.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli.exe story update --id US-012 --unit 1 --integration 1 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Full Flutter test suite passes. |
| Integration | Vercel deploy and inspect confirm a ready preview deployment. |
| E2E | Browser smoke confirms deployed CTA/upload UI and clean console. |
| Platform | Flutter analyzer and web release build pass. |
| Release | Preview URL recorded; production promotion is out of scope. |

## Harness Delta

No harness policy change expected.

## Evidence

- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 9 tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` passed with no issues.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` succeeded and wrote `build\web`.
- `vercel deploy --yes` created preview deployment `dpl_CagdJWLHYkFVa7C5yt2zrbJ6Z9yp` at `https://plant-ai-disease-flutter-k9cn1zpmz.vercel.app`.
- `vercel inspect https://plant-ai-disease-flutter-k9cn1zpmz.vercel.app` reported target `preview` and status `Ready`.
- Raw preview URL showed the expected Vercel Deployment Protection login gate; the Vercel connector created a temporary share URL expiring on 2026-06-14 13:11:46.
- Chrome/Playwright screenshots through the share URL confirmed the deployed desktop and mobile UI show `Preview upload flow`, `Open authenticated app`, and the single upload area copy `Click to choose a leaf image`.
- Chrome/Playwright smoke script verified HTTP 200, title `Plant Disease Detection`, empty console warning/error collection, and CTA interaction snackbar proof.
- Screenshot evidence was written outside the repo:
  - `C:\Users\duong\AppData\Local\Temp\plant-ai-us012-desktop.png`
  - `C:\Users\duong\AppData\Local\Temp\plant-ai-us012-mobile.png`
  - `C:\Users\duong\AppData\Local\Temp\plant-ai-us012-interaction.png`
