# Hone 磨く

Spec review and refinement plugin for AI coding agents. Sits between plan generation and execution.

## Structure

- `.claude/skills/hone/` — Core skill with reference files
- `.claude/skills/*/` — Individual user-invokable command skills (review, gaps, assumptions, etc.)
- `.claude/agents/hone/` — Subagent prompts for automated review
- `.claude-plugin/` — Plugin manifest
- `tests/fixtures/` — Sample specs for testing review quality

## Key Concepts

- **Questions are the product** — Review is interactive Q&A, not a report dump
- **Size-calibrated** — S/M/L/XL determines review depth (see `reference/size-calibration.md`)
- **Kintsugi output** — Findings are gold seams (🪙), not red errors
- **Four verdicts**: SHARP / NEEDS HONING / ROUGH EDGE / RESHAPE
- **Non-linear loops** — Review can loop back to planning via Replan/Reshape briefs

## Implementation Status

- Phase 1 (Core Engine): IN PROGRESS
- Phase 2 (Knowledge Expansion): Scaffolded
- Phase 3 (Remaining Dimensions): Scaffolded
- Phase 4 (Non-Linear Loops): Scaffolded
- Phase 5 (Sharpen + Report): Scaffolded
