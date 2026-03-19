# Hone 磨く

Spec review and refinement tool for AI coding agents. 15 commands, 6 agents, 10 review dimensions.

## What This Repo Is

Hone is a plugin that reviews and sharpens specs/plans before execution. It does not generate specs — it pressure-tests specs written by other agents or humans through interactive Q&A.

## Capabilities

- **Size classification** — Categorizes specs as S/M/L/XL to calibrate review depth
- **Interactive review** — Asks questions one at a time, waits for answers, adapts
- **10 composable dimensions** — Gaps, Assumptions, Unknown Unknowns, Complexity, Scope, Dependencies, Testability, Context, Code Simplicity, Data Quality
- **Living Spec Markup** — Shows the spec getting annotated in real-time during review
- **Sharpen** — Applies all findings as tracked repairs with `<!-- 🪙 HONED -->` markers
- **Reports** — Persistent review reports that serve as memory for future reviews
- **Settings** — Configurable models, dimensions, and report preferences

## Repository Structure

```
.claude-plugin/plugin.json          Plugin manifest
.claude/skills/hone/               Core skill + reference files
.claude/skills/hone/reference/     Review dimension checklists (10 files)
.claude/skills/hone-*/             User-invokable commands (15 commands)
.claude/agents/hone/               Subagent prompts (6 agents)
tests/fixtures/                    Sample specs for testing
tests/sandbox/                     Local test specs (gitignored)
```

## Commands

`hone-review`, `hone-gaps`, `hone-assumptions`, `hone-unknowns`, `hone-complexity`, `hone-scope`, `hone-deps`, `hone-testability`, `hone-context`, `hone-simplicity`, `hone-data-quality`, `hone-sharpen`, `hone-diff`, `hone-report`, `hone-settings`

## Review Flow

Size spec → Recommend dimensions → Interactive Q&A → Milestone chain progress → Living Spec Markup → Verdict → Sharpen → Report
