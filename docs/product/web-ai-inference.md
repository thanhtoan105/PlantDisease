# Web AI Inference Contract

## Goal

The public Flutter Web demo should replace the current simulated diagnosis
result with real disease inference while staying safe for a public portfolio
site.

## Current Model Assets

- Model: `assets/models/model.tflite`
- Model size: 3,407,592 bytes
- Model SHA-256:
  `BE32AEEC9466E9E03849444389D2BA48C78A1BE715728FFDE73291A8A17EFD98`
- Labels: `assets/models/labels.txt`
- Labels SHA-256:
  `516868D7C2C0C90AEEDC29BFE8EC629870F1A64E23EE14FBCE8156EB8C33CCB3`
- Class count: 6

Current labels:

1. `Durian___Leaf_Algal`
2. `Durian___Leaf_Blight`
3. `Durian___Leaf_Colletotrichum`
4. `Durian___Leaf_Healthy`
5. `Durian___Leaf_Phomopsis`
6. `Durian___Leaf_Rhizoctonia`

## Current Native Pipeline

The native Flutter service uses:

- Input size: 224 x 224
- Channels: RGB
- Tensor shape expected by code: `[1, 224, 224, 3]`
- Input values: raw RGB float values in the `0..255` range
- Resize method: `image.copyResize(..., interpolation: linear)`
- Output handling: predictions are paired with `labels.txt`, sorted by
  confidence descending, and the top prediction drives result display.

The code comments say the model handles MobileNetV3/ImageNet-style
preprocessing internally, so the current mobile path does not normalize to
`[-1, 1]`.

## Current Web Behavior

`tensorflow_service_web.dart` intentionally does not run inference. It loads
labels for diagnostic UI but returns:

- `success: false`
- `analysisMethod: web_unsupported`
- `requiresWebInference: true`

The public demo page currently shows a simulated result after upload. That
behavior is acceptable only until real web inference is implemented.

## Browser Runtime Direction

The next implementation should start with a client-side browser inference proof
before introducing a backend. The model is small enough for a portfolio demo,
and the spec prefers browser inference when feasible because images stay on the
user device and Vercel can remain static hosting.

The proof must verify:

- The browser runtime can load the model or a converted equivalent.
- The runtime accepts the same 224 x 224 RGB `0..255` input pipeline, or the
  required preprocessing delta is explicitly documented.
- Output class order matches `labels.txt`.
- Top-k predictions are stable against a fixed sample image set.
- The web bundle and model load time remain acceptable for the public demo.

If the TFLite model cannot run reliably in browser, use a separate inference
backend and keep Vercel as the static Flutter Web frontend.

## Label Mapping Requirement

Before exposing real results publicly, model labels must resolve through the
structured mapping in `assets/data/label_mapping.json`. A minimum mapping row
needs:

- `modelLabel`
- `cropId`
- `diseaseId`
- `displayNameEn`
- `displayNameVi`
- `isHealthy`
- short description
- care or prevention note

The result UI must not infer disease details by formatting the raw model label
alone.

US-019 also adds `assets/data/sample_image_manifest.json` as the fixed sample
image regression manifest. Browser inference work should use that manifest to
compare expected labels before replacing the simulated public demo result.

## Privacy Requirement

The MVP should not upload or persist user images unless a backend architecture
is explicitly selected. If client-side inference is used, the demo page should
state that images are processed in the browser and are not stored by default.
