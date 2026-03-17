---
name: hone-gaps
description: >
  Find missing pieces in a spec or plan. Gap analysis only — what's absent,
  not what's wrong. Focuses on missing error handling, unaddressed edge cases,
  missing rollback/recovery, unspecified contracts, and absent validation.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to analyze
    required: false
---

Run gap analysis on a spec/plan. This is a focused, single-dimension review.

## Input

Accept a file path, conversation context, or pasted content. If no input, ask for it.

## Process

1. Read the `hone` skill for voice, visual identity, and output format
2. Read `hone/reference/gap-analysis.md` for the gap analysis checklist
3. Read `hone/reference/anti-patterns.md` to check for The Happy Path Only pattern

## Behavior

Focus exclusively on what's MISSING from the spec:
- Missing error handling
- Unaddressed edge cases
- Missing rollback/recovery
- Unspecified API contracts
- Missing validation rules
- Absent logging/observability
- Missing security considerations

**Open** with a styled phase header:

```
╭─────────────────────────────────────╮
│  🪙 HONE ─ GAP ANALYSIS            │
╰─────────────────────────────────────╯
```

Ask questions related to gaps — do not dump a report. Each gap is presented as a question using the Question Formatting template from the `hone` skill. Include the `[N/M]` counter.

Wait for answers. Fold answers into understanding.

If The Happy Path Only anti-pattern is detected, show the anti-pattern callout box.

## Output

After the interactive Q&A, produce findings using the Kintsugi seam format:

```
🪙 ── Gap: [Short title] ────────────────────────

  📍 [Location in spec]
  ❓ [T2] [Question text]

  [What's missing — 2-3 lines, specific]

  ⚠  RISK: [What goes wrong]
  🔧 FIX:  [Concrete addition to spec]

  Severity: [████░░░░░░] [LEVEL]
──────────────────────────────────────────────────
```

End with a dimension scorecard:

```
  ┌ GAP ANALYSIS COMPLETE ─────────────┐
  │                                     │
  │  Gaps found: 5                      │
  │  ██ Critical: 1  ██ High: 2         │
  │  █ Medium: 1     █ Low: 1           │
  │                                     │
  │  Questions: 7 asked, 6 answered     │
  │                                     │
  └─────────────────────────────────────┘
```
