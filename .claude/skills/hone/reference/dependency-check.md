# Dependency & Ordering Check

Find missing prerequisites, incorrect sequencing, hidden dependencies, and parallelization opportunities.

## What to Check

### Task-to-Task Dependencies

For each task, ask:
- What must be done before this task can start?
- What does this task produce that other tasks need?
- Can this task run in parallel with others?

Build a mental dependency graph:

```
Task 1 (SDK install) ──► Task 2 (checkout endpoint) ──► Task 3 (redirect)
                                      │
                                      ├──► Task 4 (success page)
                                      │
                                      └──► Task 5 (webhook) ──► Task 6 (UI update)
```

### Missing Prerequisites

Things that must exist before any task can start but aren't listed:

- **Environment setup**: API keys, secrets, environment variables
- **Infrastructure**: Databases, queues, caches, CDNs that need provisioning
- **Accounts/access**: Third-party service accounts, IAM permissions
- **Data**: Seed data, test fixtures, migration scripts
- **Configuration**: Config files, feature flags, DNS entries
- **Dependencies**: Libraries that need installing, services that need deploying

**Question pattern**: "Task [N] requires [prerequisite] but the spec doesn't include setting it up. Is it already done, or is this missing work?"

### Ordering Errors

Tasks listed in an order that doesn't match their actual dependencies:

- A task that uses an API endpoint listed before the endpoint is created
- Frontend work listed before the backend it depends on
- Integration tests listed before the features they test
- Deployment steps listed before the code changes

**Question pattern**: "Task [N] depends on Task [M], but [M] comes after [N] in the spec. Should the order be swapped?"

### Circular Dependencies

Tasks that depend on each other, creating a deadlock:

- "Auth middleware requires user roles" + "User roles require auth middleware to test"
- "API requires database schema" + "Database schema requires API contract definition"

**Question pattern**: "Tasks [N] and [M] depend on each other. Which one should be built first, and what stub/mock is needed to break the cycle?"

### External Dependencies

Things outside the team's control that tasks depend on:

- Third-party API availability and rate limits
- Review/approval processes (security review, design review)
- Other team's deliverables
- Infrastructure provisioning timelines
- Domain registration, SSL certificates

**Question pattern**: "Task [N] depends on [external dependency]. What's the timeline for this, and what's the fallback if it's delayed?"

### Parallelization Opportunities

Tasks that could run in parallel but are listed sequentially:

- Independent frontend and backend work
- Multiple API endpoints with no dependencies between them
- Test writing alongside implementation
- Documentation alongside development

**Question pattern**: "Tasks [N] and [M] appear independent. Can they run in parallel to save time?"

### Deployment Ordering

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
