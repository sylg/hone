---
name: hone-complexity
description: >
  Audit a spec for hidden complexity and underestimated risk. Finds tasks
  that are actually multiple tasks, glossed-over integration points, and
  architectural decisions buried in task descriptions.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to audit
    required: false
---

Audit spec for hidden complexity. Optional composable dimension.

## Input

Accept a file path, conversation context, or pasted content. If no input, ask for it.

## Process

1. Read the `hone` skill for voice, visual identity, and output format
2. Read `hone/reference/complexity-audit.md` for the full checklist
3. Read `hone/reference/anti-patterns.md` to check for The God Task pattern

## Behavior

**Open** with a styled phase header:

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 HONE ─ COMPLEXITY AUDIT                                         │
╰───────────────────────────────────────────────────────────────────────╯
```

Look for:
- **God Tasks** — single tasks that are actually multiple tasks
- **Glossed integration points** — complex integrations described in one sentence
- **Buried architectural decisions** — decisions that look like implementation details
- **Underestimated dependencies** — infrastructure/setup work not captured
- **Optimistic estimates** — "just" and "simple" preceding non-trivial work

Ask questions using `AskUserQuestion`. Use the `header` field: `"T2 Complexity [N/M]"` or `"T3 Complexity [N/M]"`. Options should include: "Decompose", "Keep as-is", "Need to research".

When a God Task is found, suggest a concrete decomposition in the question description.

If The God Task anti-pattern is detected, show the anti-pattern callout box.

## Output

After the interactive Q&A, produce findings using the standard findings format from the reference file. End with a dimension scorecard:

```
┌─ COMPLEXITY AUDIT COMPLETE ───────────────────────────────────────────┐
│  God Tasks found: 2   Glossed integrations: 1   Buried decisions: 1   │
│  Questions: 6 asked, 5 answered   Decompositions suggested: 2         │
└───────────────────────────────────────────────────────────────────────┘
```
