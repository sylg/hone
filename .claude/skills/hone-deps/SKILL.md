---
name: hone-deps
description: >
  Check task dependencies and execution ordering in a spec. Finds
  missing prerequisites, incorrect sequencing, and parallelization
  opportunities.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to check
    required: false
---

Dependency & ordering check. Optional composable dimension.

## Input

Accept a file path, conversation context, or pasted content. If no input, ask for it.

## Process

1. Read the `hone` skill for voice, visual identity, and output format
2. Read `hone/reference/dependency-check.md` for the full checklist

## Behavior

**Open** with a styled phase header:

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 HONE ─ DEPENDENCY CHECK                                         │
╰───────────────────────────────────────────────────────────────────────╯
```

Check for:
- **Task-to-task dependencies** — build the dependency graph
- **Missing prerequisites** — env setup, infrastructure, accounts, data
- **Ordering errors** — tasks listed before their dependencies
- **Circular dependencies** — tasks that depend on each other
- **External dependencies** — things outside the team's control
- **Parallelization opportunities** — tasks that could run concurrently

Ask questions using `AskUserQuestion`. Use the `header` field: `"T2 Deps [N/M]"`. Options should be contextual — e.g., "Add prerequisite", "Reorder tasks", "Already set up".

Display the dependency graph (text format) from the reference file.

## Output

End with a dimension scorecard:

```
┌─ DEPENDENCY CHECK COMPLETE ───────────────────────────────────────────┐
│  Missing prerequisites: 2   Ordering issues: 1   Circular deps: 0     │
│  External deps: 1   Parallel groups identified: 2                      │
│  Questions: 4 asked, 3 answered                                        │
└───────────────────────────────────────────────────────────────────────┘
```
