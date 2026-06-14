# US-010 Public Web Deployment Readiness

## Status

implemented

## Lane

normal

## Product Contract

The public Flutter web demo should be deployable to Vercel and should render
the demo routes through a validated preview deployment. If Vercel Deployment
Protection is enabled, QA may use a temporary Vercel share URL for browser
smoke proof.

## Relevant Product Docs

- `docs/product/README.md`
- `docs/stories/US-006-public-web-demo-shell.md`
- `docs/stories/US-007-browser-smoke-deploy-readiness.md`
- `docs/stories/US-008-web-image-upload-preview-validation.md`
- `docs/stories/US-009-flutter-analyze-baseline-cleanup.md`

## Acceptance Criteria

- Local Flutter tests pass before deployment.
- Local analyzer and web release build pass before deployment.
- Vercel CLI creates a ready deployment for the linked project.
- The deployed `/` route renders the public demo shell.
- The deployed `/demo` route renders the upload preview flow.
- A browser smoke check confirms first meaningful content, no framework error
  overlay, clean relevant console output, and at least one primary interaction.

## Design Notes

- Commands: `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test`, `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze`, `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run`, `vercel deploy`.
- Queries: `scripts/bin/harness-cli.exe query matrix`.
- API: no public API shape changes are intended.
- Tables: no data model changes are intended.
- Domain rules: deployment should not change scan, auth, crop, profile, or upload validation rules.
- UI surfaces: public web `/` and `/demo` routes.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli.exe story update --id US-010 --unit 1 --integration 1 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Full Flutter test suite passes. |
| Integration | Vercel CLI deploys the linked project and deployment inspection confirms a ready preview. |
| E2E | Browser smoke confirms `/` and `/demo` render and a primary demo interaction responds. |
| Platform | Flutter analyzer and web release build pass on Windows. |
| Release | Preview deployment URL is recorded; production promotion is out of scope. |

## Harness Delta

No harness policy change made. Browser smoke remains partly manual because the
`agent-browser` CLI was not available in PATH, matching the existing backlog
item for a reusable Flutter web browser smoke command.

## Evidence

- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 9 tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` passed with no issues.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` succeeded and wrote `build\web`.
- Initial `vercel deploy --yes` produced `dpl_459ssu7vQCBya1yqFr5TPAVXX1ig`, but browser smoke showed Vercel `404: NOT_FOUND` on `/` and `/demo`.
- `vercel.json` now sets `"outputDirectory": "build/web"` so Vercel serves the Flutter web artifact instead of the repository root.
- Second `vercel deploy --yes` produced preview deployment `dpl_9ZCevzodd7iuZ7XYzkzzQTYdmMgS` at `https://plant-ai-disease-flutter-inbeogatt.vercel.app`.
- `vercel inspect https://plant-ai-disease-flutter-inbeogatt.vercel.app` reported target `preview` and status `Ready`.
- Vercel Deployment Protection showed a login gate on the raw preview URL; the Vercel connector created a temporary share URL expiring on 2026-06-14 12:42:40.
- Playwright CLI screenshots with Chrome verified desktop `/` and mobile `/demo` render the public demo through the share URL.
- Temporary Playwright smoke script using system Chrome verified `/` and `/demo` returned HTTP 200, page title was `Plant Disease Detection`, console warnings/errors were empty, and clicking the web demo CTA showed the expected snackbar.
- Screenshot evidence was written outside the repo under `C:\Users\duong\AppData\Local\Temp\plant-ai-us010\`.
