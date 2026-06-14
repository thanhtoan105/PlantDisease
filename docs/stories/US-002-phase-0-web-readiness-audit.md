# US-002 Phase 0 Web Readiness Audit

## Status

implemented

## Lane

normal

## Product Contract

Determine what blocks the existing Flutter mobile application from becoming the public Flutter Web portfolio demo described in `SPEC.md`, with emphasis on Vercel deployment, public routing, upload/demo flow, and AI inference strategy.

## Relevant Product Docs

- `SPEC.md`
- `README.md`
- `docs/HARNESS.md`
- `docs/ARCHITECTURE.md`
- `docs/stories/US-001-tooling-codebase-audit.md`

## Acceptance Criteria

- Flutter SDK and web target availability are checked.
- Current web platform support status is known.
- Platform-specific code blockers are identified with file references.
- AI inference options are narrowed to a recommended MVP path.
- Vercel deployment requirements are identified.
- No runtime product behavior is changed by this audit.

## Findings

### Tooling

- `flutter` is not on `PATH`.
- A usable SDK exists at `C:\Users\duong\fvm\versions\3.41.5`.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat --version` reports Flutter `3.41.5`, Dart `3.11.3`.
- `fvm` is on `PATH`, but `fvm` itself fails because `dart` is not on `PATH`.
- `flutter devices` detects Windows desktop, Chrome web, and Edge web when using the direct SDK path.

### Current Platform Support

- `.metadata` lists only `root` and `android` under `migration.platforms`.
- There is no `web/` directory.
- `flutter build web --release` fails before compilation with:

```text
This project is not configured for the web.
To configure this project for the web, run flutter create . --platforms web
```

### Analyzer Baseline

`flutter analyze` completes and reports 45 issues. These are warnings/info, not fatal analyzer errors. Main groups:

- unused imports/fields/elements in AI scan and crop detail screens.
- deprecation warning in `edit_profile_screen.dart`.
- production `print` lint issues in `test_gemini.dart`.

### Web Blockers

High priority blockers:

- `lib/core/services/tensorflow_service.dart` imports `dart:io`, uses `File`, `Platform`, `tflite_flutter`, `Interpreter`, and GPU delegate APIs. This path is native-oriented and should not be imported by web builds.
- `lib/core/services/camera_service.dart` imports `dart:io`, uses `File`, `path_provider`, `gal`, permission APIs, and native-style file paths.
- `lib/features/ai_scan/screens/results_screen.dart` and `lib/features/ai_scan/screens/crop_image_screen.dart` use `Image.file(File(...))`, which is not suitable for Flutter Web upload previews.
- `lib/core/services/supabase_service.dart` uploads scan images from `File(imagePath)`, which is native-file oriented.
- `lib/main.dart` runs `AppDiagnostics.runDiagnostics()` on startup. Diagnostics initialize TensorFlow, location, and camera, which is the wrong startup behavior for a public web landing/demo surface.
- `lib/main.dart` initializes Supabase and `lib/navigation/app_router.dart` redirects unauthenticated users to onboarding/auth. The portfolio demo requires public access without login.
- `pubspec.yaml` includes `.env` as a bundled asset. For a public web build, secrets such as Gemini API keys must not be shipped to browsers.

Medium priority blockers:

- Project currently locks orientation to portrait in `lib/main.dart`, which conflicts with desktop/tablet web presentation.
- `AppProvider` setup creates `AuthProvider` in both `main.dart` and `app.dart`, which should be cleaned when creating a public app shell.
- Plant/disease library currently depends on Supabase runtime RPCs. For MVP portfolio stability, static JSON data should be considered for public pages, or Supabase anon access must be intentionally reviewed.

### Model And Data

- Current model: `assets/models/model.tflite`, about 3.4 MB.
- Current labels: 6 Durian classes:
  - `Durian___Leaf_Algal`
  - `Durian___Leaf_Blight`
  - `Durian___Leaf_Colletotrichum`
  - `Durian___Leaf_Healthy`
  - `Durian___Leaf_Phomopsis`
  - `Durian___Leaf_Rhizoctonia`
- Current preprocessing uses resize to 224 x 224 RGB and raw 0-255 pixel values.

## Recommended MVP Direction

Recommended sequence:

1. Add web platform files with `flutter create . --platforms web`.
2. Create a separate public web entry/app shell that does not require onboarding/auth.
3. Introduce an `InferenceService` interface with platform-specific implementations.
4. Keep the existing native TFLite implementation for Android.
5. For web MVP, choose one:
   - Preferred first experiment: convert model to a browser-supported runtime and keep inference client-side.
   - Fallback: deploy a separate FastAPI inference backend and keep Vercel as static Flutter Web frontend.
6. Move plant/disease display data to static JSON for portfolio pages, or explicitly review Supabase public read policies.
7. Add `vercel.json` with SPA rewrite to `index.html` once `web/` exists.
8. Validate with `flutter build web --release`, then browser smoke test on Chrome and mobile viewport.

## Vercel Notes

For Flutter Web static deploy:

- Build command: `flutter build web --release`.
- Output directory: `build/web`.
- SPA rewrite:

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

If Vercel remote build lacks Flutter SDK, use CI/prebuilt deploy:

- Build Flutter Web in GitHub Actions.
- Run validation.
- Deploy `build/web` with `vercel deploy --prebuilt`.

## Validation

| Layer | Expected proof |
| --- | --- |
| Unit | Not applicable for this audit-only story. |
| Integration | Not applicable for this audit-only story. |
| E2E | Not available until `web/` exists and app can run in Chrome. |
| Platform | Direct Flutter SDK checks, analyzer, and failed web build evidence. |
| Release | Not applicable. |

## Evidence

- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat --version`
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat devices`
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat pub get`
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze`
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release`
- `rg` scans for `dart:io`, `File`, `Platform`, TensorFlow, camera, auth, and environment usage.

## Harness Delta

No Harness policy files changed. Phase 0 confirmed the existing Harness story/matrix flow is enough for audit work.
