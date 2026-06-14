# Validation

## Proof Strategy

The story is complete only when local history scans show no Gemini API key
pattern in the PR commit range, the final tree remains behaviorally unchanged
except Harness evidence, Flutter validation passes, the rewritten branch is
force-pushed with lease, and GitGuardian no longer reports the leaked key in the
PR.

## Test Plan

| Layer | Cases |
| --- | --- |
| Unit | Flutter widget tests continue to pass. |
| Integration | GitHub PR security status is rechecked after force-push. |
| E2E | Not required; no user-visible behavior changes. |
| Platform | Flutter analyzer and web release build continue to pass. |
| Performance | Not applicable. |
| Logs/Audit | Harness trace records the security correction and validation evidence. |

## Fixtures

- PR #2 on `feature/flutter-web-readiness-audit`.
- GitGuardian finding reported against `test_gemini.dart`.

## Commands

```text
git show <historical-commit>:test_gemini.dart
git log -G "AIza[0-9A-Za-z_-]{35}" --oneline origin/main..HEAD
git grep -n -I -E "AIza[0-9A-Za-z_-]{35}" HEAD -- . ":!build" ":!output"
git diff --stat <pre-redaction-backup>..HEAD
C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test
C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze
C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat build web --release --no-wasm-dry-run
git push --force-with-lease origin feature/flutter-web-readiness-audit
gh pr view 2 --json statusCheckRollup,mergeStateStatus
```

## Acceptance Evidence

- Root cause confirmed in historical branch commits: `test_gemini.dart` and
  `lib/core/services/gemini_service.dart` previously contained a hardcoded
  Gemini API key before later environment-backed changes.
- Rewrote the feature branch history with a Gemini API key regex redaction
  across Dart files.
- Deleted the temporary local backup branch and `refs/original` ref, then
  expired reflogs and pruned unreachable objects locally after verification.
- `git log -G "AIza[0-9A-Za-z_-]{35}" --oneline origin/main..HEAD` returned
  no commits after rewrite.
- `git grep -n -I -E "AIza[0-9A-Za-z_-]{35}" HEAD -- . ":!build" ":!output"`
  returned no matches.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat test` passed with 10
  tests.
- `C:\Users\duong\fvm\versions\3.41.5\bin\flutter.bat analyze` passed with no
  issues.
