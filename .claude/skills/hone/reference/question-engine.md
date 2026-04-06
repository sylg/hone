# Question Engine

Questions are the product. Every question asked forces the developer to think about something they hadn't considered. Every question answered adds context that makes the spec stronger.

## Question Tiers

Questions are categorized by what they surface:

| Tier | Type | What It Surfaces | Weight |
|------|------|-----------------|--------|
| **T1: Clarification** | Ambiguity in the spec | Vague language, undefined terms, multiple interpretations | 1x |
| **T2: Gap** | Something missing | Unhandled edge cases, missing error paths, absent requirements | 2x |
| **T3: Challenge** | Testing an assumption | Unvalidated claims, untested constraints, optimistic estimates | 3x |
| **T4: Unknown Unknown** | Developer didn't know to ask | Domain-specific gotchas, security risks, scalability traps | 4x |
| **T5: Tradeoff** | Forcing a decision | Mutually exclusive options, resource constraints, priority conflicts | 3x |

Higher-tier questions contribute more to confidence. A review with 5 T4 questions is more valuable than one with 20 T1 questions.

## T4 Trigger Patterns (Domain-Specific Unknown Unknowns)

T4 questions require domain knowledge to surface. Use these triggers to know when to escalate:

### Auth & Password Reset Flows
When a spec touches password reset, credential change, or account recovery, always probe:
- **Token lifecycle**: Is the reset token single-use? Does it expire? What happens to existing tokens when a new one is issued?
- **Session invalidation**: Does a successful password reset invalidate all existing sessions (including OAuth tokens, API keys, remember-me cookies)?
- **Enumeration risk**: Does the "send reset email" endpoint reveal whether an email exists in the system via timing or response differences?
- **Rate limiting**: Is the reset-request endpoint rate-limited per email address AND per IP? Unlimited requests = account harassment vector.
- **Audit trail**: Is the password change event logged with actor, timestamp, and IP for compliance and incident response?

### Org-Scoped / Multi-Tenant Operations
When a spec adds functionality at the organization level, always probe:
- **Permission scope**: Who is allowed to perform this action — org owner only, any admin, any member? Does the spec match how existing org-admin actions are gated (check the existing permission middleware pattern)?
- **Cross-org isolation**: Can an admin from Org A trigger this action for a user in Org B? Verify the query is always scoped by `orgId`.
- **Member vs. invitee state**: Does the operation apply to pending invites or only active members? The spec often omits the pending state.
- **Notification ownership**: When an org-level action affects a user (e.g., forced password reset), who gets notified — the user, the org admin, or both? What if the user's email is unverified?

### Database & Schema Changes
When a spec adds, modifies, or removes database columns/tables, always probe:
- **Zero-downtime migration**: Can the migration run while the app is live? Adding a NOT NULL column without a default locks the table on Postgres until backfill completes — even a 1M-row table can cause minutes of write downtime.
- **Backfill strategy**: If new columns need data populated from existing rows, how is that done? Inline in the migration (blocks deploys on large tables) or async job (requires nullable column + code to handle the transitional state where both old and new rows exist simultaneously)?
- **Rollback safety**: If the deploy is rolled back, does the schema remain compatible with the previous code version? A column rename or removal breaks old code even after rollback — the spec should specify whether a multi-phase deploy is required.
- **Index creation**: Are new indexes created `CONCURRENTLY`? A standard `CREATE INDEX` on a table with 10M+ rows holds a write lock for minutes. Concurrent creation avoids this but cannot run inside a transaction.

### Webhook / External Event Flows
When a spec involves receiving or emitting webhooks:
- **Idempotency**: If the same event is delivered twice (at-least-once delivery is standard), does the handler produce the same result or does it double-apply?
- **Signature verification**: Is the incoming webhook payload verified before any state mutation?
- **Delivery ordering**: Does the handler assume events arrive in order? Most webhook providers (Stripe, Google Calendar, GitHub, etc.) do not guarantee ordering — a `resource.updated` event can arrive before `resource.created` during retries. The handler must be safe to process events out of sequence.
- **Failure visibility**: If the webhook handler throws, does the error surface to the team (dead letter queue, alerting, error tracker)? Silent failures mean the external system retries indefinitely or silently drops the event, causing invisible data drift.
- **Outbound retry policy**: For webhooks the app emits, what's the retry strategy on subscriber failure? Exponential backoff with a max-attempt cap? What happens to the subscriber's state when retries are exhausted — is there a dead letter mechanism or manual replay path?

### Data Sync / Bidirectional Integration
When a spec involves syncing data between the app and an external system (calendars, CRMs, accounting tools, communication platforms):
- **Conflict resolution strategy**: If both sides can mutate the same record (e.g., user edits event in Google Calendar AND in the app), what wins on conflict — last-write-wins, a designated source of truth, or a manual merge UI? The spec must specify this explicitly; defaulting to last-write-wins silently discards data.
- **Cursor / checkpoint persistence**: Where is the sync position (page token, delta cursor, `last_synced_at` timestamp) stored and updated? If the sync job crashes mid-run, does it resume from the last checkpoint or restart from scratch? Restarting from scratch on large datasets causes redundant API calls and potential rate-limit exhaustion.
- **Partial failure handling**: If syncing 500 records and record #237 fails (e.g., external API validation error), does the job abort, skip-and-continue, or quarantine the failed item? How are skipped/failed items surfaced to the user or ops team — silent discard is unacceptable.
- **External API rate limits**: Most calendar/CRM APIs enforce per-user and per-org rate limits. A bulk re-sync triggered by a migration, a new user onboarding, or a backfill job can exhaust these limits instantly. Does the spec account for throttling, queuing, or backoff to avoid getting the integration suspended?

---

## Question Construction Rules

### Be specific, not generic
- BAD: "Have you considered error handling?"
- GOOD: "What happens when the Stripe webhook returns a 502? The spec says 'handle errors' but doesn't specify retry logic, dead letter queue, or user notification."

### Reference the spec
- BAD: "What about performance?"
- GOOD: "Task 3 says 'query user history' but doesn't specify a time range. With 2M users averaging 500 events each, this query could return 1B rows. What's the intended scope?"

### Probe the data contract
When a spec describes behavior but not the underlying data structure, API shape, or state representation, challenge it — these decisions constrain implementation more than any behavioral description:
- BAD: "How will user preferences be stored?"
- GOOD: "Task 2 says 'persist user preferences' but doesn't specify the data contract. Will this be a new `user_preferences` table, a JSONB column on `users`, or a key-value store? Each has different migration, indexing, and query implications for the dashboard query in Task 4."

If the answer pins down a concrete shape, record it explicitly — it will anchor implementation decisions downstream.

### One question at a time
- Ask a single question. Wait for the answer. Let the answer inform the next question.
- Exception: For Size S reviews, you may ask 2-3 questions together to keep things fast.

### No leading questions
- BAD: "Don't you think you should add rate limiting?"
- GOOD: "This endpoint is public-facing with no rate limiting specified. What's the expected traffic volume, and what happens if it's 10x higher?"

## Question Flow