# Dependency & Ordering Check

Find missing prerequisites, incorrect sequencing, hidden dependencies, and parallelization opportunities.

## What to Check

### Task-to-Task Dependencies

For each task, ask:

#### P0 — Always check
- Build a mental dependency graph for all tasks
- What must be done before this task can start?
- What does this task produce that other tasks need?

#### P1 — Check for M+
- Missing prerequisites: environment setup, API keys, secrets, environment variables
- Missing prerequisites: infrastructure (databases, queues, caches, CDNs)
- Missing prerequisites: accounts/access (third-party service accounts, IAM permissions)
- Missing prerequisites: data (seed data, test fixtures, migration scripts)
- Missing prerequisites: configuration (config files, feature flags, DNS entries)
- Missing prerequisites: libraries that need installing, services that need deploying

**Question pattern**: "Task [N] requires [prerequisite] but the spec doesn't include setting it up. Is it already done, or is this missing work?"

### Ordering Errors

#### P1 — Check for M+

Tasks listed in an order that doesn't match their actual dependencies:

- A task that uses an API endpoint listed before the endpoint is created
- Frontend work listed before the backend it depends on
- Integration tests listed before the features they test
- Deployment steps listed before the code changes

**Question pattern**: "Task [N] depends on Task [M], but [M] comes after [N] in the spec. Should the order be swapped?"

### Circular Dependencies

#### P2 — Check for L+

Tasks that depend on each other, creating a deadlock:

- "Auth middleware requires user roles" + "User roles require auth middleware to test"
- "API requires database schema" + "Database schema requires API contract definition"

**Question pattern**: "Tasks [N] and [M] depend on each other. Which one should be built first, and what stub/mock is needed to break the cycle?"

### External Dependencies

#### P1 — Check for M+
- Third-party API availability and rate limits
- Infrastructure provisioning timelines
- Domain registration, SSL certificates

#### P2 — Check for L+
- Review/approval processes (security review, design review)
- Other team's deliverables

**Question pattern**: "Task [N] depends on [external dependency]. What's the timeline for this, and what's the fallback if it's delayed?"

### Parallelization Opportunities

#### P2 — Check for L+

Tasks that could run in parallel but are listed sequentially:

- Independent frontend and backend work
- Multiple API endpoints with no dependencies between them
- Test writing alongside implementation
- Documentation alongside development

**Question pattern**: "Tasks [N] and [M] appear independent. Can they run in parallel to save time?"

### Deployment Ordering

#### P2 — Check for L+

If the spec involves deployment, check:

- Database migration before code deployment?
- Feature flag enabled before or after deployment?
- Backend deployed before frontend?
- Rollback plan if deployment fails mid-sequence?

## Output Format

### Dependency Graph (text)

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 DEPENDENCY GRAPH                                                  │
│                                                                       │
│  [0] Prerequisites (missing from spec)                                │
│   └──► [1] SDK install                                                │
│         └──► [2] Checkout endpoint ──┬──► [4] Success page            │
│              [3] Redirect flow ──────┘                                 │
│              [5] Webhook handler ────────► [6] UI update              │
│                                                                       │
│  Parallel groups:                                                     │
│    Group A: Tasks 2, 3 (after task 1)                                 │
│    Group B: Tasks 4, 5 (after task 2)                                 │
│    Group C: Task 6 (after task 5)                                     │
│                                                                       │
│  Critical path: 0 → 1 → 2 → 5 → 6                                   │
╰───────────────────────────────────────────────────────────────────────╯
```

### Individual Findings

```
🪙 ── Dependency: [Short title] ─────────────────────────────────────────

   📍  [Which tasks are involved]
   ❓  [T2] [Question about the dependency issue]

   [Description of the dependency problem]

   ⚠  RISK:  [What happens — blocked work, wasted effort, deployment failure]
   🔧 FIX:   [Reorder / Add prerequisite / Break circular dependency]

   Severity: [████░░░░░░] [LEVEL]
─────────────────────────────────────────────────────────────────────────
```
