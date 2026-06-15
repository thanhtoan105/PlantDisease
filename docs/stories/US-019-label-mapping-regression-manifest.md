# US-019 Label Mapping Regression Manifest

## Status

implemented

## Lane

normal

## Product Contract

The AI inference MVP must have a stable data boundary between raw model labels
and public result UI/domain records before real browser inference is wired into
the public demo.

## Relevant Product Docs

- `docs/product/web-ai-inference.md`
- `docs/stories/US-018-ai-inference-mvp-discovery.md`

## Acceptance Criteria

- `assets/data/label_mapping.json` maps every label in
  `assets/models/labels.txt` exactly once.
- Each mapping row includes `modelLabel`, `cropId`, `diseaseId`,
  `displayNameEn`, `displayNameVi`, `isHealthy`, `shortDescription`, and
  `careNote`.
- The healthy label is the only row marked `isHealthy: true`.
- `assets/data/sample_image_manifest.json` lists all existing sample images
  under `assets/images/sample` with an expected model label.
- Unit tests validate label coverage, uniqueness, healthy classification, and
  sample image path existence.
- The mapping and manifest are bundled as Flutter assets for later runtime use.

## Design Notes

- Commands: Flutter test/analyze/build, Harness CLI.
- Queries: `scripts/bin/harness-cli.exe query matrix`.
- API: no network API changes.
- Tables: no database table changes.
- Domain rules: UI must resolve model output through the mapping, not through
  ad hoc string formatting.
- UI surfaces: no direct UI change in this story.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli.exe story update --id US-019 --unit 1 --integration 1 --e2e 0 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | `flutter test test\plant_disease_label_mapping_test.dart` validates mapping and manifest integrity. |
| Integration | `pubspec.yaml` bundles `assets/data/` and `assets/images/sample/` for runtime use. |
| E2E | Not required; real browser inference remains a follow-up story. |
| Platform | `flutter analyze` and web release build should continue to pass. |
| Release | CI/deploy runs after push or PR. |

## Harness Delta

No harness policy change expected.

## Evidence

- Added `lib/core/models/plant_disease_label_mapping.dart`.
- Added `assets/data/label_mapping.json`.
- Added `assets/data/sample_image_manifest.json`.
- Added `test/plant_disease_label_mapping_test.dart`.
- Updated `pubspec.yaml` to bundle `assets/data/` and `assets/images/sample/`.
- TDD red check: `flutter test test\plant_disease_label_mapping_test.dart`
  first failed because `plant_disease_label_mapping.dart` did not exist.
- Fixed a sample manifest path after the test caught a non-existent
  `IMG_7568` path.
