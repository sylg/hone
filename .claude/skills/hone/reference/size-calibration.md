# Size Calibration

Classify every incoming spec before review begins. Size determines question depth, which dimensions run, and whether subagents are dispatched.

## Classification Criteria

Evaluate these four axes. Each axis scores 1-4. Sum the scores.

### 1. Blast Radius (How much does this touch?)

| Score | Criteria |
|-------|----------|
| 1 | Single file, < 20 lines changed, no behavior change for other features |
| 2 | 2-5 files, new function/endpoint, local behavior change, 1-2 integration points |
| 3 | New feature, multiple integration points, new dependency, data model change |
| 4 | System architecture change, migration, multi-service impact, infrastructure change |

### 2. Reversibility (How hard is this to undo?)

| Score | Criteria |
|-------|----------|
| 1 | Fully reversible — revert the PR and you're back to normal |
| 2 | Mostly reversible — minor cleanup needed (cache invalidation, config rollback) |
| 3 | Partially reversible — data migration, API contract change, external consumers affected |
| 4 | Hard to reverse — database schema migration with data transformation, public API change, security model change |

### 3. Domain Risk (What area is this in?)

| Score | Criteria |
|-------|----------|
| 1 | UI copy, styling, documentation, dev tooling |
| 2 | Business logic, internal APIs, internal tooling |
| 3 | Data model, external integrations, user-facing workflows |
| 4 | Authentication, authorization, payments, data integrity, security, compliance |

### 4. Novelty (How well-understood is this?)

| Score | Criteria |
|-------|----------|
| 1 | Well-established pattern in this codebase, team has done this many times |
| 2 | Known pattern but first time in this codebase, or variation on existing pattern |
| 3 | New technology/approach for the team, unfamiliar domain |
| 4 | Greenfield architecture, novel algorithm, no prior art in the codebase |

## Score → Size Mapping

| Score Range | Size | Review Depth |
|-------------|------|-------------|
| 4-6 | **S (Small)** | Quick scan: 2-3 questions max. Check for obvious mistakes. |
| 7-10 | **M (Medium)** | Standard review: 5-10 questions. Gap analysis + assumption surfacing. |
| 11-13 | **L (Large)** | Full review: 15-25 questions. All dimensions. Unknown unknowns. |
| 14-16 | **XL (Extra Large)** | Deep review: 25+ questions. All dimensions + dedicated unknown unknowns. Subagent reviewers. |

## Domain Risk Bump

If the domain score is 4 (auth, payments, security, compliance), bump the overall size up by one level regardless of total score. A "small" change to auth is never truly small.

## Announce the Classification

After classifying, tell the developer:

```
This looks like a **[SIZE]** task ([one-line summary of why]).
I'll calibrate my review accordingly.

Blast radius: [score]/4 — [brief reason]
Reversibility: [score]/4 — [brief reason]
Domain risk: [score]/4 — [brief reason]
Novelty: [score]/4 — [brief reason]
Total: [sum]/16
```

The developer can override at any time: "treat this as XL" or "just do a quick scan."

## Size Determines Behavior

| Behavior | S | M | L | XL |
|----------|---|---|---|-----|
| Questions asked | 2-3 | 5-10 | 15-25 | 25+ |
| Gap analysis | Quick | Full | Full | Full + subagent |
| Assumption surfacing | Skip | Full | Full | Full + subagent |
| Complexity audit | Skip | Skip | Full | Full + subagent |
| Scope creep detection | Skip | Skip | Full | Full |
| Dependency check | Skip | Brief | Full | Full |
| Testability review | Skip | Brief | Full | Full + subagent |
| Context completeness | Skip | Skip | Full | Full |
| Unknown unknowns | Skip | Brief | Full | Deep + dedicated phase |
| Subagent reviewers | No | No | Optional | Yes |
| Anti-pattern scan | Quick | Standard | Full | Full |
