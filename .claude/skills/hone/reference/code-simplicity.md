# Code Simplicity Review

Is the spec leading toward simple, maintainable code? Or is it designing complexity that doesn't need to exist?

This dimension reviews the spec's implied code architecture — not the code itself, but the structural decisions in the spec that will determine whether the code ends up simple or convoluted.

## What to Look For

### Premature Abstraction

Specs that design abstractions before they're needed:

#### P0 — Always check
- "Create a plugin system for..." when only one plugin exists
- "Build an extensible framework for..." when only one use case is specified

#### P1 — Check for M+
- "Design a generic handler that..." when one specific handler would do
- "Create a factory/strategy/adapter pattern for..." when a simple function suffices
- "Support configurable X" when only one configuration is needed

**Question pattern**: "The spec designs a [abstraction] but only describes one [concrete use]. Is the abstraction needed now, or can you start with the simple version and extract the pattern later?"

### Unnecessary Indirection

Layers that don't add value:

#### P1 — Check for M+
- Service layer that just passes through to the repository
- API gateway that just proxies to one service

#### P2 — Check for L+
- Event bus for communication between two components in the same process
- Message queue for a synchronous operation
- Microservice for something that could be a function

**Question pattern**: "Task [N] introduces [layer/service/abstraction]. What problem does this solve that [simpler approach] wouldn't?"

### Over-Configuration

Making things configurable that don't need to be:

#### P1 — Check for M+
- Admin UI for settings that change once per year
- Config files for values that are constants

#### P2 — Check for L+
- Feature flags for features that will always be on
- Environment-specific behavior that's identical across environments

**Question pattern**: "The spec makes [X] configurable. How often does this value actually change? Would a constant be simpler?"

### Duplicated Concepts

Specs that describe the same thing in multiple places or create parallel systems:

#### P1 — Check for M+
- Two different validation approaches for the same data
- Duplicate state (same data in database, cache, and frontend store without sync strategy)

#### P2 — Check for L+
- Multiple ways to do the same thing (REST + GraphQL for the same resource)
- Multiple notification channels without a unified system

**Question pattern**: "The spec describes [X] in Task [N] and [similar X] in Task [M]. Are these the same concept? Can they be unified?"

### Missing Reuse

Opportunities to reuse existing code or patterns:

#### P1 — Check for M+
- Building a custom solution when a well-maintained library exists
- Reimplementing a pattern that exists elsewhere in the codebase

#### P2 — Check for L+
- Creating a new utility when an existing one covers the use case
- Writing custom middleware when the framework provides built-in solutions

**Question pattern**: "Task [N] describes building [X] from scratch. Does [existing library/pattern] already solve this?"

### Complexity Budget

Every feature has a complexity budget. Check if the spec is spending it wisely:

#### P2 — Check for L+
- Are the complex parts of the spec where the actual business complexity lives?
- Or is complexity being spent on infrastructure, abstractions, and "good engineering" rather than user-facing value?
- Is there a simpler way to achieve 90% of the value with 10% of the complexity?

**Question pattern**: "This spec has [N] tasks. [M] of them are infrastructure/tooling. Is that the right ratio for delivering user value?"

## The YAGNI Check

#### P0 — Always check

For each architectural decision in the spec, ask: "Do we need this now?"

| If the spec says... | Ask... |
|-------|--------|
| "Support multiple databases" | Which databases are actually used? Just one? |
| "Extensible via plugins" | How many plugins exist today? Just one? |
| "Microservice architecture" | Is there more than one team? More than one deploy cadence? |
| "Event-driven" | Are there actually multiple consumers? Or just one? |
| "Configurable via admin panel" | How often does this config change? Monthly? Never? |
| "Abstract base class" | How many concrete implementations exist? Just one? |

## DRY vs WET Assessment

Check if the spec encourages DRY (Don't Repeat Yourself) appropriately:

- **Good DRY**: Shared validation rules, common error handling, reusable UI components
- **Bad DRY**: Premature abstractions that couple unrelated features, shared code that changes for different reasons
- **Good WET (Write Everything Twice)**: Similar but not identical code that will evolve independently
- **Bad WET**: Copy-pasted logic that must stay in sync

**Rule of thumb**: Three similar things warrant abstraction. Two similar things are fine as-is.

## Output Format

```
🪙 ── Simplicity: [Short title] ─────────────────────────────────────────

   📍  [Which task/section]
   ❓  [T3 or T5] [Question about unnecessary complexity]

   The spec designs: [what the spec proposes]
   Simpler alternative: [what could work instead]

   ⚠  RISK:  [Over-engineering / maintenance burden / delayed delivery]
   🔧 FIX:   [Specific simplification]

   Severity: [████░░░░░░] [LEVEL]
─────────────────────────────────────────────────────────────────────────
```
