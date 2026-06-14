# US-008 Web Upload Preview Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add public web demo image selection, preview, remove, and validation without AI inference or server upload.

**Architecture:** Keep upload state inside `PublicDemoScreen` and move file validation into a small pure Dart policy file for unit testing. Use `image_picker`'s existing `XFile` support to select images and `Image.memory` for preview.

**Tech Stack:** Flutter, Dart, `image_picker`, widget tests, Harness CLI, Chrome/Playwright smoke validation.

---

### Task 1: Story Packet

**Files:**
- Create: `docs/stories/US-008-web-image-upload-preview-validation.md`

- [ ] **Step 1:** Create a normal-lane story with product contract, acceptance criteria, validation plan, and evidence section.
- [ ] **Step 2:** Add durable Harness story row with `scripts/bin/harness-cli.exe story add --id US-008 --title "Web Image Upload Preview Validation" --lane normal --verify "C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test"`.

### Task 2: Validation Policy TDD

**Files:**
- Create: `lib/features/public_demo/models/public_demo_upload_policy.dart`
- Test: `test/public_demo_upload_policy_test.dart`

- [ ] **Step 1:** Write failing tests for valid JPG/PNG/WebP, invalid extension, empty file, and file over 5 MB.
- [ ] **Step 2:** Run `flutter test test\public_demo_upload_policy_test.dart` and verify failure because the policy does not exist.
- [ ] **Step 3:** Implement `validatePublicDemoUpload` with max size `5 * 1024 * 1024`.
- [ ] **Step 4:** Re-run the targeted test and verify pass.

### Task 3: Public Demo Upload UI

**Files:**
- Modify: `lib/features/public_demo/screens/public_demo_screen.dart`
- Modify: `test/public_demo_screen_test.dart`

- [ ] **Step 1:** Add widget tests that assert upload panel labels/actions render and detect is disabled before image selection.
- [ ] **Step 2:** Run the widget test and verify failure on missing UI.
- [ ] **Step 3:** Convert `PublicDemoScreen` to a stateful screen with `ImagePicker`, selected bytes/name/error state, and upload panel.
- [ ] **Step 4:** Add choose, remove, and detect placeholder actions. Detect without an image must not crash.
- [ ] **Step 5:** Re-run widget tests and verify pass.

### Task 4: Validation And Browser Proof

**Files:**
- Update: `docs/stories/US-008-web-image-upload-preview-validation.md`

- [ ] **Step 1:** Run `flutter test`.
- [ ] **Step 2:** Run `flutter analyze` and record the known 45 warning/info baseline if unchanged.
- [ ] **Step 3:** Run `flutter build web --release --no-wasm-dry-run`.
- [ ] **Step 4:** Run Chrome/Playwright smoke on `/demo` with `--channel chrome`, including first paint and upload panel screenshot.
- [ ] **Step 5:** Update story evidence, durable story proof status, and trace.
