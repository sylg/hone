---
name: hone-testability
description: >
  Review if every task in a spec has clear, testable success criteria.
  Flags vague definitions of "done" and suggests concrete verification steps.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to review
    required: false
---

Testability review. Optional composable dimension.

## Input

Accept a file path, conversation context, or pasted content. If no input, ask for it.

## Process

1. Read the `hone` skill for voice, visual identity, and output format
2. Read `hone/reference/testability-review.md` for the full methodology
3. Read `hone/reference/anti-patterns.md` to check for The Untestable Task pattern

## Behavior

**Open** with a styled phase header:

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 HONE ─ TESTABILITY REVIEW                                       │
╰───────────────────────────────────────────────────────────────────────╯
```

For each task:
1. Apply the **Fresh Agent Test**: could a new developer verify this is done without asking questions?
2. Check for **vague words**: works, fast, good, clean, secure, robust, improved, better, properly
3. Rate as **TESTABLE** ✅ / **VAGUE** 🟡 / **UNTESTABLE** 🔴

For VAGUE and UNTESTABLE tasks, ask questions using `AskUserQuestion`. Use the `header` field: `"T2 Testability [N/M]"`. Options should include: "Use suggested verification", "Define my own criteria", "Acceptable as-is".

Suggest concrete verification steps for each vague/untestable task.

Display the Task Rating Table from the reference file.

If The Untestable Task anti-pattern is detected, show the callout box.

## Output

End with a dimension scorecard:

```
┌─ TESTABILITY REVIEW COMPLETE ─────────────────────────────────────────┐
│  Tasks: 6   Testable: 2 ✅   Vague: 2 🟡   Untestable: 2 🔴         │
│  Concrete verifications suggested: 4                                   │
│  Questions: 4 asked, 3 answered                                        │
└───────────────────────────────────────────────────────────────────────┘
```
