# Overview

## Current Behavior

GitGuardian flagged the PR because historical commits in the feature branch
contained a hardcoded Gemini API key. The current file contents had already
moved Gemini configuration to `.env`, but the secret remained in the branch
history that GitHub security tooling scans.

## Target Behavior

The feature branch history should not contain Gemini API key literals matching
the provider key pattern. The final application tree should remain behaviorally
unchanged from before the redaction, and the PR should be force-pushed with the
rewritten history.

## Affected Users

- Repository maintainers reviewing PR security checks.
- Future users of the public Vercel portfolio demo.

## Affected Product Docs

- `docs/stories/US-014-redeploy-sample-inference-demo.md`

## Non-Goals

- Rotating the exposed Gemini key in Google Cloud; that must be done by the key
  owner outside this repository.
- Changing Gemini runtime behavior or adding new AI inference features.
- Promoting the Vercel preview to production.
