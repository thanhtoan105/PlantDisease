# Exec Plan

## Goal

Remove the leaked Gemini API key from the PR history that GitGuardian flagged,
without changing the final app behavior.

## Scope

In scope:

- Confirm where the key entered the branch history.
- Rewrite the feature branch history to redact Gemini API key literals from Dart
  files.
- Verify the rewritten branch has no matching key pattern in current contents or
  PR history.
- Force-push the rewritten branch with lease.
- Re-check PR security status.

Out of scope:

- Revoking or rotating the exposed provider key.
- Production Vercel deployment changes.
- Runtime Gemini feature changes.

## Risk Classification

Risk flags:

- Audit/security.
- External systems.
- Existing behavior.
- Weak proof.

Hard gates:

- Audit/security.
- External provider behavior.

## Work Phases

1. Discovery: inspect `test_gemini.dart`, historical commits, and current PR
   status.
2. Design: choose branch-history redaction instead of a normal deletion commit.
3. Validation planning: define history scan and final-tree comparison checks.
4. Implementation: rewrite branch history with a Gemini key regex redaction.
5. Verification: scan current tree and PR commit range, run Flutter validation,
   and check GitGuardian after push.
6. Harness update: record story and trace evidence.

## Stop Conditions

Pause for human confirmation if:

- The final app tree differs from the pre-redaction tree.
- Force-push with lease is rejected because the remote changed.
- GitGuardian still reports a secret after rewritten history is pushed.
