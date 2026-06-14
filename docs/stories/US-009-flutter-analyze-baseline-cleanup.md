# US-009 Flutter Analyze Baseline Cleanup

## Status

implemented

## Lane

normal

## Product Contract

The Flutter project should have a clean analyzer baseline after the web demo readiness work, without changing user-visible scan, auth, crop details, profile, or demo upload behavior.

## Relevant Product Docs

- `docs/product/README.md`
- `docs/stories/US-008-web-image-upload-preview-validation.md`

## Acceptance Criteria

- `flutter analyze` no longer reports the known 45 warning/info baseline.
- Cleanup is limited to mechanical analyzer fixes unless a warning exposes a real behavior issue.
- Existing public demo and upload validation tests still pass.
- Web release build still succeeds.

## Design Notes

- Commands: `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze`, `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test`, `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run`.
- Queries: `scripts/bin/harness-cli.exe query matrix`.
- Domain rules: no scan result, profile, auth, or crop data behavior changes are intended.
- UI surfaces: analyzer cleanup touches existing screens only to remove unused private code/imports.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-009 --unit 1 --integration 0 --e2e 0 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Full Flutter test suite passes. |
| Integration | Not required for mechanical analyzer cleanup. |
| E2E | Not required unless UI behavior changes. |
| Platform | Analyzer and web release build pass. |
| Release | Not required before preview deploy. |

## Harness Delta

No harness policy change expected.

## Evidence

- Initial analyzer run: `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` reported 45 issues.
- Cleanup removed unused imports, unused private fields/helpers, an unnecessary type check, a deprecated `DropdownButtonFormField.value` usage, and excluded the root-level manual Gemini probe from production analyzer scope.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` passed with no issues.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 9 tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` succeeded and wrote `build\web`.
