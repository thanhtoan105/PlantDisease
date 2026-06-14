# US-018 AI Inference MVP Discovery

## Status

implemented

## Lane

normal

## Product Contract

Before replacing the simulated public web diagnosis result with real inference,
the project must have a current model, label, preprocessing, sample image, and
runtime architecture audit that identifies the smallest safe implementation path.

## Relevant Product Docs

- `SPEC.md`
- `docs/product/web-ai-inference.md`
- `docs/decisions/0006-web-inference-mvp-runtime.md`
- `docs/stories/US-013-web-demo-sample-inference-result.md`
- `docs/stories/US-017-github-actions-vercel-autodeploy.md`

## Acceptance Criteria

- Current model and labels are identified with asset paths, size, hashes, and
  class count.
- Current native preprocessing is summarized from source code.
- Current web inference limitation is documented from source code.
- Sample image coverage is counted by class.
- The recommended next architecture is recorded as a durable decision.
- The next implementation tasks are explicit enough to begin real inference
  work without repeating discovery.

## Design Notes

- Commands: PowerShell file inventory, `Get-FileHash`, `rg`, Harness CLI.
- Queries: `scripts/bin/harness-cli.exe query matrix`.
- API: no API added in this story.
- Tables: no data model changes.
- Domain rules: raw model labels must be mapped to stable crop/disease IDs
  before public result detail links are exposed.
- UI surfaces: public demo `/` and `/demo`, specifically the `Detect Disease`
  result flow.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli.exe story update --id US-018 --unit 0 --integration 1 --e2e 0 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Not required; this story records discovery and architecture direction. |
| Integration | Product contract and decision record connect model assets, native pipeline, web limitation, and next runtime path. |
| E2E | Not required; real inference is a follow-up implementation story. |
| Platform | Web limitation and client-side runtime direction are documented. |
| Release | No deployment required for documentation-only discovery. |

## Harness Delta

Added a product contract for web AI inference and a durable architecture
decision for the MVP inference runtime.

## Evidence

- `assets/models/model.tflite` exists and is 3,407,592 bytes.
- Model SHA-256:
  `BE32AEEC9466E9E03849444389D2BA48C78A1BE715728FFDE73291A8A17EFD98`.
- `assets/models/labels.txt` contains 6 non-empty labels.
- Labels SHA-256:
  `516868D7C2C0C90AEEDC29BFE8EC629870F1A64E23EE14FBCE8156EB8C33CCB3`.
- Current labels:
  `Durian___Leaf_Algal`, `Durian___Leaf_Blight`,
  `Durian___Leaf_Colletotrichum`, `Durian___Leaf_Healthy`,
  `Durian___Leaf_Phomopsis`, `Durian___Leaf_Rhizoctonia`.
- `lib/core/config/ai_model_config.dart` sets input size `224`, model channels
  `3`, model path `assets/models/model.tflite`, and labels path
  `assets/models/labels.txt`.
- `lib/core/services/tensorflow_service_native.dart` resizes to 224 x 224,
  extracts RGB values, and keeps raw `0..255` float values instead of applying
  manual `[-1, 1]` normalization.
- The native service reshapes input as `[1, 224, 224, 3]`, runs the interpreter,
  pairs outputs with `labels.txt`, sorts predictions descending, and returns
  top prediction plus all detected diseases.
- `lib/core/services/tensorflow_service_web.dart` currently returns
  `analysisMethod: web_unsupported` and `requiresWebInference: true`.
- `lib/features/public_demo/screens/public_demo_screen.dart` still shows a
  simulated public web result after `Detect Disease`.
- Sample images exist under `assets/images/sample`: Algal 4, Blight 4,
  Colletotrichum 4, Healthy 4, Phomopsis 4, Rhizoctonia 2; total 22 files,
  about 570,799 bytes.
- Local Python environment did not have TensorFlow or `tflite_runtime`, so this
  audit did not independently confirm TFLite tensor metadata outside the app
  source code.

## Next Implementation Tasks

1. Create `assets/data/label_mapping.json` with one row per model label.
2. Add a pure Dart parser/model for label mapping and unit tests that every
   label in `labels.txt` has exactly one mapping row.
3. Build a fixed regression image manifest from `assets/images/sample` with
   expected labels.
4. Prototype a browser-capable inference runtime or model conversion path.
5. Compare browser output with the native preprocessing contract and document
   any required preprocessing delta.
6. Replace the simulated public demo result with real top-3 predictions only
   after the runtime proof passes.
