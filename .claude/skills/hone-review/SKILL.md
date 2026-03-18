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

1. **Phase 0**: Classify size — display Classification Announcement box
2. **Phase 1**: Recommend dimensions — user picks which to run via `AskUserQuestion`
3. **Phase 2**: Run dimensions sequentially — questions via `AskUserQuestion`, Living Spec Markup after each
4. **Phase 3**: Verdict — display the full Verdict Block with final Living Spec Markup
5. **Phase 4**: Sharpen — offer bulk repair of all findings

Read ALL reference files applicable to the selected dimensions before starting.

## Interaction Model

**CRITICAL**: Use the `AskUserQuestion` tool for ALL review questions. Follow the Question Formatting section in the `hone` skill.

- Use the `header` field for tier badge + counter: `"T2 Gap [3/18]"`
- Provide 2-4 actionable options with descriptions
- Output styled text (progress, scorecards, Living Spec Markup) between questions

## The Living Spec Markup

This is the reward mechanism. After each dimension completes:
1. Show the Review Progress dashboard (which dimensions done/running/pending)
2. Show the Living Spec Markup — the spec's task list with accumulated 🪙 annotations
3. Show the Learnings section — numbered key takeaways so far

The markup accumulates. Each dimension adds its findings. Developer decisions are shown inline. The spec isn't rewritten until `/hone-sharpen` — but the developer sees the impact building in real-time.

## Visual Identity

Follow the Visual Identity section in the `hone` skill exactly:
- Box-drawing characters for all containers
- Progress bars between questions
- Living Spec Markup with tree-style annotations after each dimension
- Anti-pattern callout boxes when detected
- Wide (~72 char) boxes with aligned right edges

## Key Rules

- Ask questions ONE AT A TIME via `AskUserQuestion` (except Size S where batch 2-3)
- Wait for answers before proceeding
- Track every question with its tier
- Be specific — reference exact sections of the spec
- Use the voice defined in the hone skill: direct, specific, no filler
- Show Review Progress bar between questions
- Show Living Spec Markup after each dimension completes
- Sharpen in bulk at the end, never mid-review
