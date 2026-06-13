# US-001 Tooling And Codebase Audit

## Status

implemented

## Lane

normal

## Product Contract

Audit the current Flutter mobile app, current model/inference path, and available Vercel, Flutter, and Build Web Apps tooling before implementation begins for the public Flutter Web portfolio demo.

## Relevant Product Docs

- `SPEC.md`
- `README.md`
- `docs/HARNESS.md`
- `docs/ARCHITECTURE.md`

## Acceptance Criteria

- Current app architecture, dependencies, and web-readiness risks are summarized.
- Available plugin/skill support is mapped to concrete project phases.
- Initial validation blockers are recorded.
- No product code changes are made during the audit.

## Design Notes

- Commands: `scripts/bin/harness-cli.exe query matrix`, `rg --files`, `rg -n`, Flutter tooling probes.
- Queries: package and Vercel documentation checks for web/deploy feasibility.
- API: no app API changes.
- Tables: no app database changes.
- Domain rules: no product behavior changes.
- UI surfaces: landing/demo/library/model-card surfaces remain future work.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Not applicable for audit-only work. |
| Integration | Not applicable for audit-only work. |
| E2E | Not applicable until a web surface exists. |
| Platform | Flutter/Vercel readiness observations from local repo and tooling checks. |
| Release | Not applicable. |

## Harness Delta

The Harness durable layer had to be initialized locally. `query tools --summary` failed because the current SQLite schema does not include a `tool` table.

## Evidence

- `scripts/bin/harness-cli.exe init`
- `scripts/bin/harness-cli.exe query matrix`
- `rg --files`
- `rg -n "dart:io|Platform\\.|File\\(|camera|image_picker|tflite|permission|geolocator|path_provider|gal|image_cropper|SystemChrome" lib pubspec.yaml`
- Vercel documentation search for SPA rewrites/build configuration.
- Follow-up readiness findings were captured in `docs/stories/US-002-phase-0-web-readiness-audit.md`.
