---
name: hone-assumptions
description: >
  Surface hidden assumptions in a spec or plan. For every statement,
  asks "what must be true for this to work?" and flags anything that
  isn't explicitly stated.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to analyze
    required: false
---

Surface hidden assumptions in a spec/plan. Single-dimension review.

## Input

Accept a file path, conversation context, or pasted content. If no input, ask for it.

## Process

1. Read the `hone` skill for voice, visual identity, and output format
2. Read `hone/reference/assumption-surfacing.md` for the assumption categories
3. Read `hone/reference/anti-patterns.md` to check for The Assumption Iceberg pattern

## Behavior

**Open** with a styled phase header:

```
╭─────────────────────────────────────╮
│  🪙 HONE ─ ASSUMPTION SURFACING    │
╰─────────────────────────────────────╯
```

For every statement in the spec, construct the chain of requirements. Ask: "What must be true for this to work?" If the answer isn't stated, it's a hidden assumption.

Work through the categories systematically:
- Environment assumptions
- Data assumptions
- Dependency assumptions
- User assumptions
- Ordering assumptions
- Performance assumptions

Use the Question Formatting template from the `hone` skill for each question. Include the `[N/M]` counter. Tag each assumption as `[STATED]` or `[UNSTATED]`.

If The Assumption Iceberg anti-pattern is detected, show the anti-pattern callout box.

## Output

After the interactive Q&A, produce findings using the Kintsugi seam format:

```
🪙 ── Assumption: [Short title] ─────────────────

  📍 [Which statement in the spec]
  ❓ [T3] [Question to developer]

  Assumes: [What must be true]
  Status:  [STATED ✓] or [UNSTATED ✗]

  ⚠  IF WRONG: [What breaks]
  🔧 FIX:      [How to make explicit in spec]

  Severity: [████░░░░░░] [LEVEL]
──────────────────────────────────────────────────
```

End with a dimension scorecard:

```
  ┌ ASSUMPTION SURFACING COMPLETE ─────┐
  │                                     │
  │  Assumptions found: 12              │
  │  Stated: 4 ✓   Unstated: 8 ✗       │
  │  Confirmed by dev: 5                │
  │                                     │
  │  ██ Critical: 0  ██ High: 3         │
  │  █ Medium: 3     █ Low: 2           │
  │                                     │
  │  Questions: 8 asked, 7 answered     │
  │                                     │
  └─────────────────────────────────────┘
```
