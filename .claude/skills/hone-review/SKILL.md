---
name: hone-review
description: >
  Full Hone review pipeline. Pressure-test a spec, plan, or implementation
  document before execution. Classifies size, asks questions interactively,
  reviews across multiple dimensions, surfaces unknown unknowns, and
  produces a verdict with confidence score.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to review
    required: false
  - name: size
    description: Override size classification (S, M, L, XL)
    required: false
---

Run the full Hone review pipeline. Use the `hone` skill as the core engine.

## Input

Accept one of:
- A file path to a spec/plan document
- The most recently generated spec in conversation context
- Pasted content from the developer

If no input is provided, ask: "What spec or plan would you like me to review?"

## Flags

Parse these from the args if present:
- `--size [S|M|L|XL]` — Override auto-classification
- `--skip-unknowns` — Skip the unknown unknowns phase
- `--fast` — Reduce question depth (half the normal count for the size)
- `--deep` — Increase question depth (double the normal count for the size)

## Process

Execute the full Hone pipeline as described in the `hone` skill:

1. **Phase 0**: Classify size (or use override) — display Classification Announcement box
2. **Phase 1**: Question-driven review — ask questions using `AskUserQuestion` tool
3. **Phase 2**: Dimension review — show Dimension Scorecard after each dimension
4. **Phase 3**: Unknown unknowns (if L/XL and not skipped)
5. **Phase 4**: Verdict — display the full Verdict Block
6. **Phase 5**: Offer sharpen or replan based on verdict

Read ALL reference files applicable to the classified size before starting.

## Interaction Model

**CRITICAL**: Use the `AskUserQuestion` tool for ALL review questions. This renders native interactive UI instead of ASCII text boxes. Follow the Question Formatting section in the `hone` skill for how to map Hone questions to `AskUserQuestion` parameters.

- Use the `header` field for tier badge + counter: `"T2 Gap [3/18]"`
- Provide 2-4 actionable options with descriptions
- Output styled text (progress bars, scorecards, findings) as regular markdown between questions

## Visual Identity

Follow the Visual Identity section in the `hone` skill exactly. Key rules:
- Use box-drawing characters for scorecards, verdicts, anti-pattern callouts
- Show progress bars between questions
- Each finding gets its own 🪙 seam block
- Never output a wall of text — restructure with boxes, tables, dividers
- Anti-pattern detections get the named callout box

## Key Rules

- Ask questions ONE AT A TIME via `AskUserQuestion` (except Size S where batch 2-3)
- Wait for answers before proceeding
- Track every question with its tier
- Be specific — reference exact sections of the spec
- Use the voice defined in the hone skill: direct, specific, no filler
- Show Review Progress bar as text between questions
