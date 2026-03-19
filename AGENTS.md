# Hone

Spec review and refinement plugin for AI coding agents.

## When to Invoke Hone

Trigger Hone when ANY of these conditions are met:

- A planning agent has produced a spec/plan and the workflow is
  transitioning to execution
- A spec references external services (APIs, databases, third-party SDKs)
- A spec contains 3+ tasks or implementation steps
- The developer says "review this", "check my spec", "is this solid",
  "hone this", "what's missing", "find gaps", "check assumptions",
  "pressure test this"
- A spec touches auth, payments, security, or data migrations
  (domain risk = 4)

Do NOT invoke Hone for:
- Code files, PRs, or diffs (Hone reviews specs, not code)
- Issues, tickets, or bug reports
- Specs with fewer than 2 tasks (too small to benefit)
- Specs that have already been Hone-reviewed (check for
  `<!-- 🪙 Hone Review:` header, or run `scripts/check-honed.sh`)

## Input Contract

Hone accepts:
- A markdown file path containing a spec/plan
- Pasted markdown content in conversation context
- A recently generated spec from an upstream planning agent

Hone rejects:
- Code files (.ts, .py, .rs, etc.)
- Binary files
- Empty or stub documents

## Output Contract

After a review, Hone produces:
- **Verdict**: One of SHARP | NEEDS_HONING | ROUGH_EDGE | RESHAPE
- **Sharpened spec**: The original file with `<!-- 🪙 HONED -->` markers
  (only after `/hone-sharpen`)
- **Review report**: Saved to `.hone/reports/YYYY-MM-DD-{name}-review.md`
  (if reports enabled)
- **Replan brief**: Structured guidance for the planning agent
  (only for ROUGH_EDGE / RESHAPE verdicts)

## Integration Patterns

### Plan → Review → Execute (recommended)

1. Planning agent produces spec → saves to `spec.md`
2. Invoke: `/hone-review spec.md`
3. Interactive Q&A (developer answers questions)
4. If verdict is SHARP or NEEDS_HONING → `/hone-sharpen` → execute
5. If verdict is ROUGH_EDGE → feed Replan Brief back to planning agent
6. If verdict is RESHAPE → back to design phase

### Quick Scan (for small changes)

1. Invoke: `/hone-review spec.md --size S --fast`
2. 2-3 questions, quick verdict
3. Proceed

### Single Dimension (targeted check)

- `/hone-gaps spec.md` — just find what's missing
- `/hone-assumptions spec.md` — just surface unstated assumptions
- `/hone-unknowns spec.md` — just surface domain gotchas

## Commands

| Command | Use when |
|---------|----------|
| `/hone-review` | Full pipeline — default entry point |
| `/hone-gaps` | You suspect missing error handling or edge cases |
| `/hone-assumptions` | Spec relies on unstated environmental conditions |
| `/hone-unknowns` | Unfamiliar domain, want domain-specific gotchas |
| `/hone-complexity` | Tasks feel too big or vague |
| `/hone-scope` | Spec has grown beyond original intent |
| `/hone-deps` | Multi-phase work with ordering concerns |
| `/hone-testability` | Success criteria are vague |
| `/hone-context` | Spec is a handoff — could a fresh dev execute it? |
| `/hone-simplicity` | Refactoring or code-heavy spec |
| `/hone-data-quality` | Schema changes, migrations, data model work |
| `/hone-sharpen` | Apply all findings as tracked repairs |
| `/hone-diff` | See before/after of sharpened spec |
| `/hone-report` | Generate persistent review report |
| `/hone-settings` | Configure models, dimensions, report prefs |

## Repository Structure

```
.claude-plugin/plugin.json          Plugin manifest
.claude/skills/hone/               Core skill + reference files
.claude/skills/hone/reference/     Review dimension checklists
.claude/skills/hone/scripts/       Deterministic helper scripts
.claude/skills/hone-*/             User-invokable commands (15)
.claude/agents/hone/               Subagent prompts (6 agents)
tests/fixtures/                    Sample specs for testing
```
