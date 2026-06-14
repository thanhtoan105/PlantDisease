# US-017 GitHub Actions Vercel Autodeploy

## Status

implemented

## Lane

normal

## Product Contract

The Flutter web demo should deploy automatically to Vercel production after a
validated push to `main`. Pull requests should run the same Flutter validation
without deploying production.

## Relevant Product Docs

- `docs/product/README.md`
- `docs/stories/US-016-production-public-demo-deployment.md`

## Acceptance Criteria

- A GitHub Actions workflow validates pull requests targeting `main`.
- A push to `main` runs Flutter test, analyzer, and web release build.
- Production deploy runs only after validation passes on `main`.
- Vercel deploy uses repository secrets instead of committed credentials.
- The workflow creates a public-safe placeholder `.env` for CI builds because
  `.env` is a Flutter asset but is not committed.

## Design Notes

- Commands: GitHub Actions `flutter pub get`, `flutter test`,
  `flutter analyze`, `flutter build web --release --no-wasm-dry-run`,
  `vercel pull --environment=production`, `vercel build --prod`,
  `vercel deploy --prebuilt --prod`.
- Queries: `scripts/bin/harness-cli.exe query matrix`.
- API: no backend or route contract changes.
- Tables: no data model changes.
- Domain rules: CI must not inject private app provider keys into the public web
  bundle.
- UI surfaces: deployed production Flutter web demo.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli.exe story update --id US-017 --unit 0 --integration 1 --e2e 0 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Not required for workflow-only change; local Flutter tests are already covered by the workflow command definitions. |
| Integration | Workflow YAML contains Vercel secret-driven prebuilt deploy steps. |
| E2E | First live GitHub Actions run is expected after the user adds repository secrets and pushes/dispatches the workflow. |
| Platform | Workflow defines Flutter setup, dependency install, analyzer, test, and web build on Ubuntu. |
| Release | Production deployment is gated to pushes or manual dispatch on `main`, not pull requests. |

## Harness Delta

No harness policy change expected.

## Required GitHub Secrets

Add these under GitHub repository settings before expecting production deploy to
work:

- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

Current Vercel identifiers:

- `VERCEL_ORG_ID=team_ZFVhzKD1HHoxrUtH8oACtHdU`
- `VERCEL_PROJECT_ID=prj_zq8VbqqjzHBCFj9x4qtTMcLKLJkr`

## Evidence

- Added `.github/workflows/deploy-vercel.yml`.
- Workflow triggers on pull requests to `main`, pushes to `main`, and manual
  `workflow_dispatch`.
- Pull requests run validation only; production deploy is gated to non-PR runs
  on `main`.
- Workflow creates a public-safe placeholder `.env` for CI builds so Flutter can
  resolve the committed `.env` asset without bundling private app provider keys.
- Workflow checks for `VERCEL_TOKEN`, `VERCEL_ORG_ID`, and
  `VERCEL_PROJECT_ID`; production deploy steps are skipped with a warning until
  all three secrets are configured.
- Vercel CLI is pinned to `54.12.2`, matching the locally verified production
  deploy tool version.
- Workflow opts JavaScript actions into Node.js 24 with
  `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true` to avoid the GitHub Actions Node.js
  20 deprecation path.
- Workflow uses Node 24-capable GitHub actions:
  `actions/checkout@v5`, `actions/upload-artifact@v6`, and
  `actions/download-artifact@v7`.
- `npx --yes js-yaml .github\workflows\deploy-vercel.yml` parsed the workflow
  successfully.
- `git diff --check` passed.
- `scripts/bin/harness-cli.exe story verify US-016` passed after adding the
  workflow, proving the same Flutter test/analyze/build commands still pass.
- First pushed workflow run
  `https://github.com/thanhtoan105/PlantDisease/actions/runs/27500635220`
  passed validation and skipped production deploy with the expected warning
  because Vercel secrets were not configured yet.
- Follow-up run
  `https://github.com/thanhtoan105/PlantDisease/actions/runs/27501428475`
  passed validation and production deployment after the workflow actions were
  upgraded to Node 24-capable versions.
