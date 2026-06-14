# 0006 Web Inference MVP Runtime

Date: 2026-06-14

## Status

Accepted

## Context

The public Vercel demo is live and auto-deployed, but `Detect Disease` still
shows a simulated result. The repository already contains a small TFLite model
and six durian labels, while the current web service explicitly returns
`web_unsupported`.

The project spec prefers client-side inference when the model is light enough
and can run in browser, because the demo can remain static and user images do
not need to leave the browser.

## Decision

Start the real inference MVP with a client-side browser runtime proof. Do not
try to force the existing native `tflite_flutter` path into Flutter Web.

The next implementation should create a web-specific inference path that either
loads the current model through a browser-capable runtime or uses a converted
equivalent. The implementation must preserve or explicitly document any change
from the native preprocessing contract: 224 x 224 RGB input using raw `0..255`
float values.

If the browser runtime cannot load the model, cannot preserve label order, or
performs poorly enough to hurt the portfolio demo, fall back to a separate
inference backend while keeping Vercel as static Flutter Web hosting.

## Alternatives Considered

1. Keep the simulated web result.
   This keeps the site stable but fails the spec requirement for real inference,
   confidence, and top-k predictions.
2. Wire `tflite_flutter` directly into Flutter Web.
   This conflicts with the existing platform boundary that was added because
   the native package imports `dart:ffi`.
3. Build a backend first.
   This is viable, but it adds provider, CORS, timeout, privacy, and deployment
   complexity before proving the small model cannot run in browser.

## Consequences

Positive:

- Keeps the MVP aligned with the static Vercel portfolio goal.
- Avoids uploading user images for the first real inference implementation.
- Preserves the native mobile path while adding a separate web path.

Tradeoffs:

- Requires a model runtime or conversion experiment before UI integration.
- The web implementation must prove preprocessing and label order against a
  fixed test image set.
- A backend may still be needed if browser inference is not reliable.

## Follow-Up

- Create structured label mapping for the six durian classes.
- Build a fixed sample image regression set from `assets/images/sample`.
- Prototype the browser runtime behind the existing public demo result flow.
- Add public copy explaining browser-side processing and model limitations.
