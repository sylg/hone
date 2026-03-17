# Hone 磨く

Spec review and refinement plugin for AI coding agents. Sits between plan generation and execution.

## Structure

- `.claude/skills/hone/` — Core skill with reference files
- `.claude/skills/hone-*/` — Individual user-invokable command skills (review, gaps, assumptions, etc.)
- `.claude/agents/hone/` — Subagent prompts for automated review
- `.claude-plugin/` — Plugin manifest
- `tests/fixtures/` — Sample specs for testing review quality

## Key Concepts

- **Questions are the product** — Review is interactive Q&A, not a report dump
- **Size-calibrated** — S/M/L/XL determines review depth (see `reference/size-calibration.md`)
- **Kintsugi output** — Findings are gold seams (🪙), not red errors
- **Four verdicts**: SHARP / NEEDS HONING / ROUGH EDGE / RESHAPE
- **Non-linear loops** — Review can loop back to planning via Replan/Reshape briefs
- **Composable dimensions** — Review dimensions are optional plugins, not a fixed pipeline

## Architecture: Composable Dimensions

### Core vs Optional

The review pipeline has two layers:

**Core (always runs)**:
- Size classification (Phase 0)
- Gap analysis — always relevant, always runs
- Assumption surfacing — always relevant, always runs

**Optional dimensions (composable)**:
Each dimension is a standalone skill + reference file pair. The core review engine
recommends which optional dimensions to run based on:
1. T-shirt size (S skips most, XL runs many)
2. Domain detection (payments spec → suggest security review, data model spec → suggest data quality)
3. Anti-pattern signals (untestable tasks → suggest testability review)
4. User preference (user can opt in/out via flags or settings)

After the core review, Hone presents recommended dimensions via `AskUserQuestion`:
"Based on this spec, I recommend also running: [Complexity], [Testability]. Run them?"

### Adding New Dimensions

To add a new dimension:
1. Create `reference/<dimension-name>.md` — the review checklist
2. Create `.claude/skills/hone-<name>/SKILL.md` — the user-invokable command
3. Register it in the dimension registry (in SKILL.md)

Each dimension must follow the contract:
- Takes a spec as input
- Asks questions via `AskUserQuestion`
- Produces findings in Kintsugi seam format
- Returns a dimension scorecard

### Current Dimensions

| Dimension | Type | Status | When to recommend |
|-----------|------|--------|-------------------|
| Gap analysis | Core | ✅ Done | Always |
| Assumption surfacing | Core | ✅ Done | Always |
| Unknown unknowns | Optional | Stub | L/XL size, or unfamiliar domain |
| Complexity audit | Optional | Stub | God Task anti-pattern, L/XL size |
| Scope creep detection | Optional | Stub | Scope Balloon anti-pattern, long task lists |
| Dependency check | Optional | Stub | Multi-task specs, ordering-sensitive work |
| Testability review | Optional | Stub | Untestable Task anti-pattern, vague success criteria |
| Context completeness | Optional | Stub | Agent-targeted specs, handoff documents |
| Code simplicity | Optional | Not started | Code-heavy specs, refactoring tasks |
| Data quality | Optional | Not started | Data model changes, ERD/schema specs, migrations |

### Future Dimensions (ideas)

- **Security review** — auth, input validation, secrets management
- **Performance review** — benchmarks, load expectations, caching strategy
- **Accessibility review** — a11y requirements, WCAG compliance
- **API design review** — REST conventions, versioning, pagination contracts
- **Migration safety** — rollback plans, data integrity, zero-downtime checks

## Settings

### Where settings live

- **Project-level**: `.hone/config.json` — committed or gitignored per team preference
- **User-level**: Could extend to `~/.hone/config.json` for global defaults (future)

### Settings schema

```json
{
  "model": {
    "default": null,
    "review": null,
    "subagents": null
  },
  "dimensions": {
    "always_run": ["gap-analysis", "assumption-surfacing"],
    "never_run": [],
    "auto_recommend": true
  },
  "review": {
    "auto_review": false,
    "default_size_override": null,
    "question_depth": "normal",
    "skip_unknowns": false,
    "save_reports": true,
    "report_dir": "docs/hone"
  },
  "voice": "direct"
}
```

### Model configuration

- `model.default` — Model for the main review. `null` = inherit from user's current session model.
- `model.review` — Override for the review orchestrator specifically.
- `model.subagents` — Model for subagent dispatches (reviewer, questioner, unknown-scout). Useful for cost control — e.g., use Sonnet for subagents while main review uses Opus.
- Per-agent overrides can be set in the agent `.md` frontmatter via the `model` field.

### TODO: Settings implementation

- [ ] Create `.hone/config.json` on first run with sensible defaults
- [ ] Add `/hone-settings` command to view/edit config interactively
- [ ] Read config at start of every review pipeline
- [ ] Pass model config to subagent dispatches
- [ ] Allow `--model` flag on `/hone-review` for one-off override

## Implementation Status

- Phase 1 (Core Engine): ✅ COMPLETE
- Phase 2 (Knowledge Expansion): Scaffolded — stubs only
- Phase 3 (Composable Dimensions): Scaffolded — architecture defined, stubs only
- Phase 4 (Non-Linear Loops): Scaffolded — stubs only
- Phase 5 (Sharpen + Report): Scaffolded — stubs only
- Phase 6 (Settings + Config): Not started

## TODOs

- [ ] Settings system (`.hone/config.json`, model selection, dimension preferences)
- [ ] Dimension recommendation engine (in SKILL.md, after core review)
- [ ] Write Phase 2: `reference/unknown-unknowns.md` full content
- [ ] Write Phase 3: all optional dimension reference files
- [ ] Write Phase 4: `reference/replan-protocol.md` full content
- [ ] Write Phase 5: sharpen, diff, report commands + agents
- [ ] Code simplicity dimension (new)
- [ ] Data quality dimension (new)
- [ ] End-to-end test in fresh session with all fixtures
