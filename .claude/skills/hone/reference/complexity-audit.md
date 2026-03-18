# Complexity Audit

Find hidden complexity. Tasks that are actually multiple tasks. Integration points glossed over with a single sentence. Architectural decisions buried in task descriptions.

## What to Look For

### God Tasks

A single task that contains multiple distinct pieces of work. Signs:

- Task description is longer than 3 sentences
- Task contains sub-bullets that are themselves non-trivial
- Task mentions multiple systems, services, or components
- Task uses "and" to connect unrelated work ("Set up the database and implement the auth middleware and write tests")
- Estimation uncertainty is huge ("could take 2 hours or 2 weeks")

**Question pattern**: "Task [N] contains at least [X] distinct pieces of work: [list them]. Should these be separate tasks with their own success criteria?"

### Glossed-Over Integration Points

Places where the spec hand-waves a complex integration with a single sentence:

- "Connect to [external service]" — what about auth, rate limits, error handling, retries?
- "Sync data between [A] and [B]" — real-time? batch? conflict resolution? consistency model?
- "Send notifications" — email? push? in-app? all three? what triggers them? templates?
- "Update the database" — schema change? migration? backwards compatibility? downtime?

**Question pattern**: "Task [N] says '[glossed phrase].' This actually involves [detailed breakdown]. Has the complexity been accounted for?"

### Buried Architectural Decisions

Decisions that look like implementation details but are actually architectural choices:

- Choice of database (SQL vs NoSQL) buried in a task description
- Sync vs async processing mentioned casually
- Caching strategy implied but not specified
- State management approach assumed
- API design decisions (REST vs GraphQL, pagination strategy) not called out

**Question pattern**: "Task [N] implies [architectural decision]. This constrains [downstream choices]. Is this intentional and have the implications been considered?"

### Underestimated Dependencies

Work that depends on things not mentioned in the spec:

- Infrastructure that needs to exist (queue, cache, CDN)
- Services that need to be running (search index, email service)
- Config/secrets that need to be provisioned
- Permissions/access that need to be granted
- Data that needs to exist (seed data, test accounts)

**Question pattern**: "Task [N] requires [dependency] to exist. Is this already set up, or is it additional work not captured in the spec?"

### Optimistic Estimates

Patterns that suggest the spec underestimates effort:

- "Simple" or "just" preceding a non-trivial task ("just add validation")
- First-time integrations described as if they're routine
- No mention of testing effort for complex features
- No mention of documentation or migration guides
- Assuming third-party services work exactly as documented

**Question pattern**: "The spec describes [task] as straightforward, but in practice this typically involves [hidden work]. Has that been factored in?"

## Decomposition Suggestions

When a God Task is found, suggest a concrete decomposition:

```
Original:  "Implement the webhook handler"

Decomposed:
  5a. Set up webhook endpoint with signature verification
  5b. Parse and validate incoming event payloads
  5c. Implement event-specific handlers (completed, failed, expired)
  5d. Add idempotency to prevent duplicate processing
  5e. Add retry/dead-letter for handler failures
  5f. Add logging and monitoring for webhook events
```

Each sub-task should have its own success criteria and be independently testable.

## Severity Assessment

| Complexity Type | Severity |
|----------------|----------|
| God Task that can be decomposed without changing approach | Medium |
| Glossed integration point that could block the entire feature | High |
| Buried architectural decision that constrains future work | High |
| Missing dependency that requires new infrastructure | High |
| Optimistic estimate on a well-understood task | Low |
| Optimistic estimate on a novel/unfamiliar task | Medium |

## Output Format

```
🪙 ── Complexity: [Short title] ─────────────────────────────────────────

   📍  [Which task/section]
   ❓  [T2 or T3] [Question text]

   [Description of the hidden complexity — what's actually involved]

   ⚠  RISK:  [What happens if this isn't addressed]
   🔧 FIX:   [Suggested decomposition or specification]

   Severity: [████░░░░░░] [LEVEL]
─────────────────────────────────────────────────────────────────────────
```
