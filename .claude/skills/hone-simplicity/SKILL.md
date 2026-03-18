---
name: hone-simplicity
description: >
  Review a spec for unnecessary complexity, premature abstraction, and
  over-engineering. Ensures the spec leads toward simple, maintainable
  code — DRY where it matters, simple where it can be.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to review
    required: false
---

Code simplicity review. Optional composable dimension.

## Input

Accept a file path, conversation context, or pasted content. If no input, ask for it.

## Process

1. Read the `hone` skill for voice, visual identity, and output format
2. Read `hone/reference/code-simplicity.md` for the full checklist

## Behavior

**Open** with a styled phase header:

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 HONE ─ CODE SIMPLICITY                                          │
╰───────────────────────────────────────────────────────────────────────╯
```

Look for:
- **Premature abstraction** — building plugins/frameworks/factories for one use case
- **Unnecessary indirection** — layers that just pass through
- **Over-configuration** — making things configurable that never change
- **Duplicated concepts** — same thing described multiple ways
- **Missing reuse** — building from scratch when a library/pattern exists
- **Complexity budget** — is complexity spent on user value or infrastructure?

Apply the **YAGNI Check**: for each architectural decision, ask "Do we need this now?"

Ask questions using `AskUserQuestion`. Use the `header` field: `"T3 Simplicity [N/M]"` or `"T5 Simplicity [N/M]"`. Options should include: "Simplify", "Keep — justified", "Need to research".

## Output

After the interactive Q&A, produce findings using the Kintsugi seam format from the reference file. End with a dimension scorecard:

```
┌─ CODE SIMPLICITY COMPLETE ────────────────────────────────────────────┐
│  Premature abstractions: 1   Unnecessary layers: 1   YAGNI: 2         │
│  Complexity budget: 60% infra / 40% user value (should be inverted)    │
│  Questions: 4 asked, 3 answered   Simplifications accepted: 2         │
└───────────────────────────────────────────────────────────────────────┘
```
