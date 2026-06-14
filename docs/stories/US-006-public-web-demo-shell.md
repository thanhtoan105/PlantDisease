# US-006 Public Web Demo Shell

## Status

implemented

## Lane

normal

## Product Contract

Expose a public Flutter Web portfolio demo shell at the root URL and `/demo` without requiring onboarding or authentication, while preserving the existing authenticated mobile app flow under the current app routes.

## Relevant Product Docs

- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/stories/US-005-google-fonts-web-build-compatibility.md`
- `lib/navigation/app_router.dart`
- `lib/navigation/route_names.dart`

## Acceptance Criteria

- `/` renders a public demo shell instead of redirecting to onboarding/auth.
- `/demo` renders the same public demo shell and is also auth-free.
- The demo shell clearly communicates web inference status and links users to the authenticated app flow.
- Existing auth/onboarding-protected routes remain protected.
- Widget test coverage proves the demo shell renders its core copy/actions.
- Web release build still succeeds.

## Design Notes

- Commands: `flutter test`, `flutter analyze`, `flutter build web --release --no-wasm-dry-run`.
- Queries: `rg -n "RouteNames|GoRoute|redirect" lib/navigation lib/features`.
- API: no backend API changes.
- Tables: no database changes.
- Domain rules: no AI inference result semantics change; web scan remains explicitly demo/unsupported until inference is implemented.
- UI surfaces: public portfolio demo shell only.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Widget test for public demo shell copy and actions. |
| Integration | Not applicable. |
| E2E | Not added in this story. |
| Platform | Flutter Web release build succeeds. |
| Release | Not applicable. |

## Harness Delta

This story turns the web build baseline into a public route that can be browser-smoke-tested in a later story.

## Evidence

- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test test\public_demo_screen_test.dart` first failed because `PublicDemoScreen` did not exist, then passed after implementation.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 1 widget test.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` reports the existing 45 warning/info baseline.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run` succeeds and writes `build\web`.
- `/` and `/demo` are public routes backed by `PublicDemoScreen`; protected app routes still flow through the existing auth/onboarding redirect.
