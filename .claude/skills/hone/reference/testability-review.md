# Testability Review

Can every task be verified? Is "done" defined concretely? Could a fresh agent verify success without asking questions?

## The Testability Test

#### P0 — Always check

For each task's success criteria, apply this test:

> If I handed this task to a new developer who has never seen the codebase, could they verify it's done without asking a single question?

If the answer is no, the success criteria are too vague.

**Async operation check (P0):** If any task involves a background job, webhook handler, queue consumer, or sync process, flag it unless the spec defines *all three*:
1. A concrete observable state after completion (e.g., DB record field, API response field)
2. A way to trigger and wait for the operation in a test (e.g., process job inline, mock webhook call)
3. A timeout or SLA (e.g., "within 30 seconds", "before next poll cycle")

Example of untestable: "Calendar events sync to the external provider."
Example of testable: "After `POST /api/sync`, the job runs within 10s; polling `GET /api/sync/status` returns `{status: 'completed', synced_count: N}`; external provider's API shows the created events."

Apply this check especially to: calendar sync, webhook delivery, email/notification dispatch, background job processors, queue consumers, scheduled tasks, and any feature whose spec uses the words "syncs", "processes", "schedules", "notifies", "propagates", or "triggers" to describe the success condition.

## What Makes Success Criteria Testable

### Testable (good)

- "API returns 200 with `{ status: 'active' }` when subscription is confirmed"
- "Button is disabled and shows spinner during CSV generation"
- "File downloads with name format `dashboard-export-YYYY-MM-DD.csv`"
- "Query executes in under 200ms for datasets up to 100K rows"
- "Error message 'Invalid email format' appears below the input field"

### Untestable (bad)

- "It works"
- "Tests pass"
- "Performance is acceptable"
- "UI looks good"
- "No regressions"
- "User experience is improved"
- "Code is clean"

### The Vague Words Checklist

Flag these words in success criteria — they're almost always untestable:

#### P0 — Always check

| Vague Word | What to Ask Instead |
|-----------|-------------------|
| "works" | Works how? What's the input, expected output, and error case? |
| "fast" | How fast? What's the baseline and target in milliseconds? |
| "good" | Good by what standard? What would bad look like? |
| "secure" | Against which threats? What security controls are verified? |

#### P1 — Check for M+

| Vague Word | What to Ask Instead |
|-----------|-------------------|
| "clean" | What specific code quality metrics? Lint rules? Complexity score? |
| "robust" | What failure modes does it handle? What's the recovery behavior? |
| "scalable" | At what scale? What's the current load and target load? |
| "improved" | Improved from what baseline? By how much? Measured how? |
| "better" | Better than what? By what metric? |

#### P2 — Check for L+

| Vague Word | What to Ask Instead |
|-----------|-------------------|
| "appropriate" | Appropriate according to whom? What's the rule? |
| "properly" | What does proper look like? What's improper? |
| "correctly" | What defines correct? What's an example of incorrect? |

## Error-Path Testability

**Error-path check (P1):** If any task defines only the happy-path outcome — without specifying at least one failure case — flag it. A testable error path must include *all three*:
1. The triggering condition (e.g., "when OAuth token is revoked", "when the third-party API returns 429")
2. The observable output (error message text, HTTP status code, or UI indicator — not just "shows an error")
3. The post-error system state (e.g., "user remains on settings page", "record is not created", "connection status stays `null`")

Example of untestable: "User can connect their LinkedIn account."
Example of testable: "Successful connect: `GET /api/connections` returns `{linkedin: {connected: true, username: string}}`; failed connect (scope denied by user): `POST /api/connections/linkedin` returns 400 `{error: 'SCOPE_DENIED'}`; toast 'LinkedIn connection failed' is shown; `GET /api/connections` still returns `{linkedin: null}`."

Apply this check especially to: OAuth/SSO flows, third-party integration setup, payment processing, file upload/export, and any task where the spec mentions a "connected", "verified", or "active" status.

## Status/State Enumeration Testability

**State enumeration check (P1):** If any task introduces an entity with a status or state field (e.g., `connection_status`, `sync_state`, `verification_status`), flag it unless the spec lists *every* possible value and the transition that moves the entity into that state. Implementations routinely require 3–5 states where specs describe only 2 (e.g., connected/disconnected), leaving intermediate and terminal error states undefined.

A testable state model must specify:
1. All possible state values (e.g., `null`, `pending`, `connected`, `expired`, `revoked`)
2. The event or action that triggers each transition (e.g., "moves to `expired` when the OAuth token TTL elapses")
3. Which states are user-visible and what UI indicator represents each

Example of undertested: "The integration shows as connected after OAuth completes."
Example of testable: "`GET /api/integrations/linkedin` returns `status` of `null` (never connected), `pending` (OAuth in progress), `connected` (active token), `expired` (token TTL elapsed, re-auth needed), or `revoked` (user removed app from provider). Each state maps to a distinct UI badge. Transition to `expired` triggers a re-auth banner; transition to `revoked` clears stored tokens and sets status to `null`."

Apply this check especially to: OAuth/third-party connections, sync pipelines, payment methods, background job runners, and any feature where the spec uses the words "connected", "active", "verified", or "enabled" as if they are the only possible states.

## Task Rating

Rate each task:

| Rating | Definition |
|--------|-----------|
| **TESTABLE** ✅ | Clear input, expected output, and verification method. A fresh agent can verify. |
| **VAGUE** 🟡 | Partially testable. Some criteria are clear, others need refinement. |
| **UNTESTABLE** 🔴 | No concrete success criteria. "Done" is undefined or subjective. |

## Concrete Verification Steps

For each VAGUE or UNTESTABLE task, suggest a concrete verification:

**Original**: "Make the dashboard faster"

**Suggested verification**: