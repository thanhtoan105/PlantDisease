# Design

## Domain Model

No product domain model changes. This is repository security hygiene for
credential handling.

## Application Flow

No application flow changes. The final tree continues to read Gemini credentials
through environment configuration.

## Interface Contract

No route, API, or UI contract changes.

## Data Model

No database or durable product data changes.

## UI / Platform Impact

No browser, mobile, desktop, or deployment behavior changes are intended. The
Git branch history is rewritten and pushed with lease so the PR no longer
contains the leaked key in its scanned commit range.

## Observability

Evidence is recorded through GitGuardian PR status, local git history scans,
Harness story proof, and a Harness trace.

## Alternatives Considered

1. Add a new deletion/sanitization commit only. Rejected because GitGuardian
   scans the PR commit range and the key would remain in old commits.
2. Drop old Gemini commits entirely. Rejected because one later commit also
   introduced legitimate environment-backed Gemini service changes.
3. Rewrite the feature branch history with pattern redaction. Selected because
   it removes the leaked key while preserving the final tree and legitimate
   feature work.
