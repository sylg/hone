---
name: hone-scope
description: >
  Detect scope creep in a spec. Compares tasks against original intent
  and flags anything that wasn't part of the original ask.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to check
    required: false
---

Scope creep detection. Optional composable dimension.

## Input

Accept a file path, conversation context, or pasted content. If no input, ask for it.

## Process

1. Read the `hone` skill for voice, visual identity, and output format
2. Read `hone/reference/scope-creep-detection.md` for the full methodology
3. Read `hone/reference/anti-patterns.md` to check for The Scope Balloon and The Kitchen Sink patterns

## Behavior

**Open** with a styled phase header:

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 HONE ─ SCOPE CREEP DETECTION                                    │
╰───────────────────────────────────────────────────────────────────────╯
```

Follow the process from the reference file:

1. **Identify original intent** — find the core ask from the title/overview
2. **Categorize every task** — CORE / ADJACENT / SCOPE CREEP
3. **Detect creep patterns** — "while we're at it", gold-plating, v2-as-v1, tangential systems

Ask questions using `AskUserQuestion`. Use the `header` field: `"T5 Scope [N/M]"`. For ADJACENT tasks, ask if they're truly required. For SCOPE CREEP tasks, ask if they can be follow-ups.

Apply the MVP test for specs with 6+ tasks: "If you could only ship 3 of these, which 3?"

Display the scope map from the reference file showing CORE / ADJACENT / SCOPE CREEP categorization.

If The Scope Balloon or Kitchen Sink anti-pattern is detected, show the callout box.

## Output

End with a dimension scorecard:

```
┌─ SCOPE REVIEW COMPLETE ──────────────────────────────────────────────┐
│  Tasks: 8 total   Core: 4   Adjacent: 2   Scope creep: 2             │
│  Patterns: gold-plating (1), v2-as-v1 (1)                            │
│  Questions: 4 asked, 4 answered   Tasks removed: 1                    │
└───────────────────────────────────────────────────────────────────────┘
```
