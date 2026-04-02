# Context Completeness

Could a fresh agent execute this spec without asking a single clarifying question?

This dimension is especially important for specs that will be handed to an AI coding agent for execution. A human developer can infer missing context from institutional knowledge. An agent cannot.

## The Fresh Agent Test

Imagine handing this spec to a developer (or agent) who:
- Has never seen the codebase
- Doesn't know the team's conventions
- Can't ask clarifying questions
- Must implement based solely on the spec

What questions would they need to ask? Every question they'd ask represents a completeness gap.

## What to Check

### File Paths & Locations

#### P0 — Always check
- Are file paths specified for files to create or modify?

#### P1 — Check for M+
- Are directory conventions stated? (`src/api/` vs `api/` vs `server/routes/`)
- If referencing existing code, are function/class names given?

#### P2 — Check for L+
- Are test file locations specified?

**Question pattern**: "Task [N] says 'create the endpoint' but doesn't specify which file or directory. Where should this code live?"

### API Contracts

#### P0 — Always check
- Are request/response schemas defined? (parameters, body, headers)

#### P1 — Check for M+
- Are HTTP methods specified?
- Are status codes specified?
- Are content types specified?

#### P2 — Check for L+
- Are authentication requirements per-endpoint?

**Question pattern**: "Task [N] says 'create POST /api/checkout' but doesn't define the request body schema. What fields does the client send?"

### Technology & Stack

#### P0 — Always check
- Is the tech stack specified? (language, framework, database)

#### P1 — Check for M+
- Are specific libraries called out? (or left to implementer choice)
- Are version requirements stated?

#### P2 — Check for L+
- Are build/deployment tools specified?

**Question pattern**: "The spec doesn't mention which framework is used. Is this Express, Next.js API routes, Fastify, or something else?"

### Sync & Conflict Resolution

#### P0 — Always check (when spec involves bidirectional data flow, sync, or integration with an external service that can also mutate the same data)
- Is the conflict resolution strategy defined? (e.g., "external source wins", "last-write-wins", "manual merge required")
- Is there a deduplication or idempotency scheme? (e.g., what field is used as an idempotency key to avoid processing the same event twice?)
- Is the sync state model described? (e.g., what table/field tracks "last synced at" or "external ID → internal ID" mapping?)

**When to flag**: Any spec that mentions "sync", "bidirectional", "webhook from external provider", "import from", or "push to" an external service. If the spec describes a two-way data flow without specifying who wins on conflict, flag it at P0.

**Question pattern**: "Task [N] describes syncing calendar events in both directions, but doesn't define what happens if the same event is modified in both systems before the next sync. Which side's change survives? How does the system detect it already processed a given external event ID?"

### The "Why" Behind Decisions

#### P1 — Check for M+
- Is the motivation for the feature explained?
- Are tradeoff decisions documented with rationale?

#### P2 — Check for L+
- Are constraints explained (not just listed)?
- Would the implementer understand what "good" looks like?

**Question pattern**: "The spec says to use Redis for caching but doesn't explain why (vs. in-memory cache or CDN). Understanding the 'why' affects implementation choices."

### Constraints & Non-Goals

#### P1 — Check for M+
- Are constraints explicitly stated? (performance, compatibility, etc.)
- Are non-goals listed? (what this feature intentionally does NOT do)

#### P2 — Check for L+
- Are out-of-scope items documented?
- Are assumptions called out as assumptions?

**Question pattern**: "Is there a performance requirement for this feature? The spec doesn't mention latency or throughput targets."

### Examples & Expected Behavior

#### P1 — Check for M+
- Are example inputs/outputs provided?

#### P2 — Check for L+
- Are edge case behaviors specified?
- Are UI mockups or wireframes referenced?
- Are database schema changes illustrated?

**Question pattern**: "What does the success page actually look like? The spec says 'display a success message' but doesn't describe the layout, copy, or next actions."

### Environment & Configuration

#### P1 — Check for M+
- Are environment variables listed?

#### P2 — Check for L+
- Are configuration values specified?
- Are third-party service credentials documented?
- Is the development setup described?

**Question pattern**: "Task [N] requires a Stripe API key. Where is this stored? Environment variable? Config file? Secrets manager?"

### Integration Context

#### P1 — Check for M+
- Are specific existing files, classes, or functions named that this feature extends or modifies? Flag vague references like "update the service" or "add to the existing handler" when no concrete file path or identifier is given — an agent cannot locate the right code without a named anchor.

#### P2 — Check for L+
- Are there existing patterns to follow?
- Are there existing utilities/helpers to reuse?
- Are there style guides or conventions to follow?

**Question pattern**: "Are there existing API endpoints in the codebase that this should follow the pattern of? What's the convention for error responses?"

## Completeness Score

Calculate a rough completeness percentage:

| Category | Weight | Complete? |
|----------|--------|-----------|
| File paths & locations | 10% | ✅/❌ |
| API contracts | 15% | ✅/❌ |
| Technology & stack | 10% | ✅/❌ |
| Why / rationale | 10% | ✅/❌ |
| Constraints & non-goals | 10% | ✅/❌ |
| Examples & behavior | 15% | ✅/❌ |
| Environment & config | 10% | ✅/❌ |
| Integration context | 10% | ✅/❌ |
| Success criteria (testable) | 10% | ✅/❌ |

Score = sum of weights for complete categories.

| Score | Rating |
|-------|--------|
| >= 80% | Good — minor gaps only |
| 50-79% | Incomplete — implementer will need to ask questions |
| < 50% | Insufficient — spec needs significant additional context |

## Output Format

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 CONTEXT COMPLETENESS                                             │
│                                                                       │
│  File paths         ❌  No file paths specified                       │
│  API contracts      🟡  Endpoints listed, no schemas                  │
│  Tech stack         ✅  React + Node + Stripe SDK                     │
│  Rationale          ❌  No "why" section                              │
│  Constraints        ❌  No constraints or non-goals                   │
│  Examples           ❌  No input/output examples                      │
│  Environment        ❌  No env vars or config listed                  │
│  Integration        ❌  No reference to existing patterns             │
│  Sync/conflicts     ❌  No conflict resolution strategy               │
│  Success criteria   🟡  Present but vague                             │
│                                                                       │
│  Completeness: ███░░░░░░░  25%                                        │
│  Rating: INSUFFICIENT — spec needs significant context                │
│                                                                       │
│  Questions an implementer would ask: 12                               │
╰───────────────────────────────────────────────────────────────────────╯
```

Individual findings:

```
🪙 ── Context: [Short title] ───────────────────────────────────────────

   📍  [Which task/section]
   ❓  [T1 or T2] [The question an implementer would ask]

   What's missing: [Specific context gap]
   Why it matters: [What goes wrong without this context]

   🔧 FIX: [What to add to the spec]
─────────────────────────────────────────────────────────────────────────
```