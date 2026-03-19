# Scope Creep Detection

Compare the spec against its stated intent. Find what doesn't belong.

## Process

### Step 1: Identify Original Intent

Find the original ask. Look for:
- Title of the spec
- "Overview" or "Why" section
- The first task (usually closest to the original intent)
- Any mention of "the original request" or "the ask"

If the intent isn't stated, ask: "What was the original request that led to this spec?"

### Step 2: Categorize Every Task

For each task in the spec, classify it:

| Category | Definition | Action |
|----------|-----------|--------|
| **CORE** | Directly required to fulfill the original intent | Keep |
| **ADJACENT** | Related and arguably necessary, but could be a follow-up | Flag for discussion |
| **SCOPE CREEP** | Not part of the original intent, added as "while we're at it" | Recommend removal |

### Step 3: Detect Creep Patterns

#### P0 — Always check

##### The "While We're At It" Pattern

Tasks that piggyback on the original work:
- "While we're touching the auth system, let's also refactor the middleware"
- "Since we're adding a new endpoint, we should also update the API docs framework"
- "We might as well add dark mode support since we're changing the UI"

**Tell**: Tasks that start with "also", "while we're at it", "might as well", "since we're already".

#### P1 — Check for M+

##### The Gold-Plating Pattern

Features that go beyond minimum viable:
- Adding a settings page when a config file would suffice
- Building a custom component when a library exists
- Adding analytics/tracking to a feature before validating it works
- Building admin tools before the feature is live

**Tell**: Tasks that make the feature more polished but aren't required for it to work.

##### The v2 Disguised as v1 Pattern

Future requirements pulled into the current scope:
- "Support for multiple languages" when the feature is only needed in English
- "Handle 10,000 concurrent users" when current traffic is 100
- "Extensible plugin architecture" when only one implementation is needed

**Tell**: Requirements that address scale, flexibility, or features that aren't needed yet.

#### P2 — Check for L+

##### The Tangential System Pattern

Work that's actually a separate project:
- Building a notification system to support one notification
- Creating a design system to support one new component
- Setting up a new microservice for one endpoint

**Tell**: Infrastructure work that benefits future features more than the current one.

## Questioning

Present scope concerns as questions:

**For ADJACENT tasks**:
"Task [N] ([description]) is related to the core ask but could be a separate follow-up. Is it truly required for this change, or is it nice-to-have?"

**For SCOPE CREEP tasks**:
"Task [N] ([description]) wasn't part of the original ask ([original intent]). It was likely added as 'while we're at it.' Can this be a follow-up?"

**For the overall spec**:
"If you could only ship 3 of these [N] tasks, which 3 would you pick? That's probably your actual v1."

## The MVP Test

#### P0 — Always apply for specs with 6+ tasks

For any spec with 6+ tasks, apply the MVP test:

1. Which tasks are required for the feature to work at all?
2. Which tasks make it work well?
3. Which tasks make it work perfectly?

Group 1 is your v1. Group 2 is your fast-follow. Group 3 is your backlog.

#### P1 — Apply for specs with 4-5 tasks

For specs with 4-5 tasks, apply a lighter version of the MVP test:

1. Which tasks are required for the feature to work at all?
2. Which tasks could be deferred to a follow-up?

## Output Format

Present a scope map:

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 SCOPE MAP                                                        │
│                                                                       │
│  Original intent: [one-line summary]                                  │
│                                                                       │
│  CORE (required)                                                      │
│  ✅  Task 1 — [description]                                          │
│  ✅  Task 2 — [description]                                          │
│  ✅  Task 3 — [description]                                          │
│                                                                       │
│  ADJACENT (could be follow-up)                                        │
│  🟡  Task 4 — [description] — [why it's adjacent]                    │
│  🟡  Task 5 — [description] — [why it's adjacent]                    │
│                                                                       │
│  SCOPE CREEP (recommend removal)                                      │
│  🔴  Task 6 — [description] — [why it's creep]                       │
│  🔴  Task 7 — [description] — [why it's creep]                       │
│                                                                       │
│  Summary: [N] tasks total, [n] core, [n] adjacent, [n] creep         │
╰───────────────────────────────────────────────────────────────────────╯
```

Individual findings in Kintsugi format:

```
🪙 ── Scope: [Short title] ─────────────────────────────────────────────

   📍  [Which task]
   ❓  [T5] [Question — is this needed for v1?]

   Original intent: [what the spec set out to do]
   This task: [what it actually does]
   Gap: [why it doesn't belong in this scope]

   Category: [ADJACENT / SCOPE CREEP]
   Pattern:  [Which creep pattern — gold-plating, v2-as-v1, etc.]

   🔧 RECOMMENDATION: [Move to follow-up / Remove / Keep with justification]
─────────────────────────────────────────────────────────────────────────
```
