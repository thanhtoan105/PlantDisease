# US-016 Production Public Demo Deployment

## Status

implemented

## Lane

normal

## Product Contract

The merged Flutter web portfolio demo should be deployed to a production Vercel
URL that can be opened directly without the preview Deployment Protection login
gate. The production deployment should render `/` and `/demo`, allow a valid
leaf image upload, and show the simulated sample diagnosis result after
`Detect Disease`.

## Relevant Product Docs

- `docs/product/README.md`
- `docs/stories/US-014-redeploy-sample-inference-demo.md`
- `docs/stories/US-015-secret-history-redaction/validation.md`

## Acceptance Criteria

- Local `main` is synchronized after PR #2 merge.
- Fresh Flutter test, analyzer, and web release build checks pass on `main`.
- Vercel creates a ready production deployment from the merged code.
- The production URL returns HTTP 200 for `/` and `/demo`.
- Browser smoke selects a sample image, clicks `Detect Disease`, and captures
  the sample result card on the production URL.
- Browser smoke reports no relevant console errors.

## Design Notes

- Commands: `git switch main`, `git pull --ff-only origin main`,
  `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test`,
  `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze`,
  `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run`,
  `vercel deploy --prod --yes`, `vercel inspect`.
- Queries: `scripts/bin/harness-cli.exe query matrix`.
- API: no backend or route contract changes.
- Tables: no data model changes.
- Domain rules: production demo still shows a simulated local sample result,
  not live AI diagnosis.
- UI surfaces: production public web `/` and `/demo`.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli.exe story update --id US-016 --unit 1 --integration 1 --e2e 1 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Flutter widget tests pass. |
| Integration | Vercel production deploy and inspect confirm a ready deployment. |
| E2E | Browser smoke confirms production sample result flow and clean console. |
| Platform | Flutter analyzer and web release build pass. |
| Release | Production URL is recorded and opens without preview share URL. |

## Harness Delta

No harness policy change expected.

## Evidence

- PR #2 was confirmed merged into `main` at merge commit
  `b5cb045ff5d72bcfe2ee494f562d582ffbf589ca`.
- Local checkout switched to `main` and `git pull --ff-only origin main`
  reported already up to date.
- `scripts/bin/harness-cli.exe story verify US-016` passed:
  - `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 10
    tests.
  - `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` passed with
    no issues.
  - `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run`
    succeeded and wrote `build\web`.
- `vercel deploy --prod --yes` created production deployment
  `dpl_FYwUnWK2Yn1wPEoYj4hFYpMgh7zi` at
  `https://plant-ai-disease-flutter-3xc5xm4ab.vercel.app`.
- Vercel assigned the production alias
  `https://plant-ai-disease-flutter.vercel.app`.
- `vercel inspect plant-ai-disease-flutter-3xc5xm4ab.vercel.app` reported
  target `production`, status `Ready`, and aliases
  `https://plant-ai-disease-flutter.vercel.app` and
  `https://plant-ai-disease-flutter-duongthanhtoan105-4637s-projects.vercel.app`.
- Playwright/Chrome smoke loaded `https://plant-ai-disease-flutter.vercel.app/`
  with HTTP 200, navigated to `/demo`, selected
  `assets/images/sample/Leaf_Algal/IMG_7439_JPG_jpg.rf.d5ad373e6361c19d18f00b74fe170c2c.jpg`
  through the real file chooser, clicked `Detect Disease`, captured the sample
  result card screenshot, and reported no console errors.
- `vercel logs https://plant-ai-disease-flutter.vercel.app --since 1h`
  returned no logs for the static deployment.
