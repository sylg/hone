---
name: hone-context
description: >
  Check if a spec contains enough context for a fresh agent to execute
  without asking clarifying questions. Finds missing file paths, undefined
  contracts, and absent rationale.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to check
    required: false
---

Context completeness check. Optional composable dimension.

## Input

Accept a file path, conversation context, or pasted content. If no input, ask for it.

## Process

1. Read the `hone` skill for voice, visual identity, and output format
2. Read `hone/reference/context-completeness.md` for the full checklist

## Behavior

**Open** with a styled phase header:

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 HONE ─ CONTEXT COMPLETENESS                                     │
╰───────────────────────────────────────────────────────────────────────╯
```

Apply the **Fresh Agent Test**: imagine handing this spec to a developer who has never seen the codebase, doesn't know conventions, and can't ask questions. What would they need to ask?

Check each category from the reference file:
- File paths & locations
- API contracts
- Technology & stack
- The "why" behind decisions
- Constraints & non-goals
- Examples & expected behavior
- Environment & configuration
- Integration context

Ask questions using `AskUserQuestion`. Use the `header` field: `"T1 Context [N/M]"` or `"T2 Context [N/M]"`. Options should include: "Add to spec", "Not needed — convention is clear", "Will add later".

Display the completeness score table from the reference file.

## Output

End with a dimension scorecard:

```
┌─ CONTEXT COMPLETENESS ────────────────────────────────────────────────┐
│  Completeness: ████░░░░░░  40%   Rating: INCOMPLETE                   │
│  Questions an implementer would ask: 8                                 │
│  Categories complete: 3/9   Categories missing: 6/9                    │
└───────────────────────────────────────────────────────────────────────┘
```
