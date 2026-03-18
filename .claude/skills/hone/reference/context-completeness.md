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

- Are file paths specified for files to create or modify?
- Are directory conventions stated? (`src/api/` vs `api/` vs `server/routes/`)
- If referencing existing code, are function/class names given?
- Are test file locations specified?

**Question pattern**: "Task [N] says 'create the endpoint' but doesn't specify which file or directory. Where should this code live?"

### API Contracts

- Are request schemas defined? (parameters, body, headers)
- Are response schemas defined? (success and error formats)
- Are HTTP methods specified?
- Are status codes specified?
- Are content types specified?
- Are authentication requirements per-endpoint?

**Question pattern**: "Task [N] says 'create POST /api/checkout' but doesn't define the request body schema. What fields does the client send?"

### Technology & Stack

- Is the tech stack specified? (language, framework, database)
- Are specific libraries called out? (or left to implementer choice)
- Are version requirements stated?
- Are build/deployment tools specified?

**Question pattern**: "The spec doesn't mention which framework is used. Is this Express, Next.js API routes, Fastify, or something else?"

### The "Why" Behind Decisions

- Is the motivation for the feature explained?
- Are tradeoff decisions documented with rationale?
- Are constraints explained (not just listed)?
- Would the implementer understand what "good" looks like?

**Question pattern**: "The spec says to use Redis for caching but doesn't explain why (vs. in-memory cache or CDN). Understanding the 'why' affects implementation choices."

### Constraints & Non-Goals

- Are constraints explicitly stated? (performance, compatibility, etc.)
- Are non-goals listed? (what this feature intentionally does NOT do)
- Are out-of-scope items documented?
- Are assumptions called out as assumptions?

**Question pattern**: "Is there a performance requirement for this feature? The spec doesn't mention latency or throughput targets."

### Examples & Expected Behavior

- Are example inputs/outputs provided?
- Are edge case behaviors specified?
- Are UI mockups or wireframes referenced?
- Are database schema changes illustrated?

**Question pattern**: "What does the success page actually look like? The spec says 'display a success message' but doesn't describe the layout, copy, or next actions."

### Environment & Configuration

- Are environment variables listed?
- Are configuration values specified?
- Are third-party service credentials documented?
- Is the development setup described?

**Question pattern**: "Task [N] requires a Stripe API key. Where is this stored? Environment variable? Config file? Secrets manager?"

### Integration Context

- How does this feature connect to existing code?
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
