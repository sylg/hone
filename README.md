# Hone 磨く

**Sharpen the spec. Ship with craft.**

Hone is a spec review and refinement tool for AI coding agents. It sits between plan generation and execution — the moment where developers say "looks good" without actually checking.

Hone pressure-tests specs through interactive Q&A, surfaces what's missing, challenges assumptions, and discovers what you didn't know to ask about. Then it sharpens the spec with tracked repairs.

**Hone is not a spec generator.** It's the whetstone — the tool that sharpens specs written by other agents or humans.

---

## How It Works

```
Your Spec → Hone Review → Questions → Findings → Sharpen → Ship
```

1. **Size it** — Hone classifies your spec as S/M/L/XL based on blast radius, reversibility, domain risk, and novelty
2. **Pick dimensions** — Core checks always run. Hone recommends optional dimensions based on your spec's content. You choose.
3. **Answer questions** — Hone asks questions one at a time. Your answers shape the review.
4. **See findings accumulate** — The Living Spec Markup shows your spec getting annotated in real-time
5. **Get a verdict** — SHARP / NEEDS HONING / ROUGH EDGE / RESHAPE
6. **Sharpen** — Apply all findings as tracked repairs to your spec

## The Review Flow

```
╭─ SIZE ─────────────────────────────────────────────────
│  Blast radius    ██░░  2/4
│  Reversibility   █░░░  1/4
│  Domain risk     ██░░  2/4
│  Novelty         ██░░  2/4
│  → Size M · 5-10 questions

    ↓

╭─ REVIEW PLAN ──────────────────────────────────────────
│  ✦ Gaps — Find what's missing
│  ✦ Assumptions — Surface what's unstated
│  ✦ Context — Can a fresh dev execute this?

    ↓

   Interactive Q&A via native UI
   Questions asked one at a time
   Your answers inform the next question

    ↓

┌────────────────────────────────────────────────────────
│  ✅ GAPS
│  2 findings  (🟠 1 high  🟡 1 med)  ·  4 questions
├────────────────────────────────────────────────────────
│  ✅ ASSUMPTIONS
│  1 finding  (🟡 1 med)  ·  2 questions
├────────────────────────────────────────────────────────
│  ✅ CONTEXT
│  1 finding  (⚠ skipped)  ·  1 question
└────────────────────────────────────────────────────────

    ↓

╔═ 🪙 HONE REVIEW COMPLETE ═════════════════════════════
║  Verdict: 🟡 NEEDS HONING
║  4 findings · 7 questions · Confidence: MEDIUM
╚════════════════════════════════════════════════════════

    ↓

   /hone-sharpen → Repairs applied with tracked markers
   /hone-report  → Persistent report saved
```

## Commands

| Command | What it does |
|---------|-------------|
| `/hone-review` | Full review pipeline — size, recommend, question, verdict |
| `/hone-gaps` | Find what's missing — error handling, edge cases, rollback |
| `/hone-assumptions` | Surface what must be true but isn't stated |
| `/hone-unknowns` | Domain-specific gotchas you didn't know to ask about |
| `/hone-complexity` | Find tasks that are actually multiple tasks |
| `/hone-scope` | Detect scope creep — what doesn't belong |
| `/hone-deps` | Map task dependencies and ordering |
| `/hone-testability` | Check if "done" is defined concretely |
| `/hone-context` | Can a fresh dev execute without asking questions? |
| `/hone-simplicity` | Flag premature abstractions and over-engineering |
| `/hone-data-quality` | Review schema design, constraints, migration safety |
| `/hone-sharpen` | Apply all findings as tracked repairs |
| `/hone-diff` | Show before/after of sharpened spec |
| `/hone-report` | Generate persistent review report |
| `/hone-settings` | Configure models, reports, dimensions |

## 10 Review Dimensions

Hone reviews are composable. Two core dimensions always run. The rest are recommended based on your spec's size and content.

**Core (always run):**

| Dimension | What it checks |
|-----------|---------------|
| **Gaps** | Missing error handling, edge cases, rollback, validation, observability |
| **Assumptions** | What must be true but isn't stated — env, data, deps, ordering |

**Optional (recommended per-spec):**

| Dimension | What it checks | Recommended when |
|-----------|---------------|-----------------|
| **Unknown Unknowns** | Domain-specific failure modes, security gotchas | L/XL size, unfamiliar domain |
| **Complexity** | God Tasks, glossed integrations, buried decisions | Tasks with hidden sub-tasks |
| **Scope** | "While we're at it" creep, gold-plating | Task count > 8, scope mismatch |
| **Dependencies** | Missing prerequisites, ordering errors | Multi-phase specs, 5+ tasks |
| **Testability** | Vague success criteria, undefined "done" | "It works" in criteria |
| **Context** | Missing file paths, contracts, rationale | Agent-targeted specs |
| **Code Simplicity** | Premature abstraction, YAGNI violations | Refactoring, code-heavy specs |
| **Data Quality** | Schema, constraints, migration safety | Data model changes |

## Severity Indicators

Findings use colored squares for severity at a glance:

- 🟥 **Critical** — Will cause data loss, security breach, or outage
- 🟠 **High** — Will cause user-facing errors in production
- 🟡 **Medium** — Will cause degraded experience or require hotfix
- 🔵 **Low** — Cosmetic or minor, can address post-launch

## Verdicts

| Verdict | Meaning |
|---------|---------|
| 🟢 **SHARP** | Minor issues only. Safe to execute. |
| 🟡 **NEEDS HONING** | Gaps found but structure is sound. Run `/hone-sharpen`. |
| 🟠 **ROUGH EDGE** | Structural issues. Plan needs rethinking. |
| 🔴 **RESHAPE** | Approach is fundamentally wrong. Back to design. |

## Install

### Skills.sh

```bash
npx skills add sylg/hone
```

### Manual

Clone the repo into your project:

```bash
git clone https://github.com/sylg/hone.git .hone-plugin
cp -r .hone-plugin/.claude .claude
cp -r .hone-plugin/.claude-plugin .claude-plugin
```

### Supported Platforms

Hone is designed to work with any AI coding agent that supports skills/commands:

- Claude Code
- Cursor
- Codex CLI
- Gemini CLI
- OpenCode

## Settings

Run `/hone-settings` to configure:

- **Models** — Set which model runs the review vs. subagents (cost control)
- **Reports** — Auto-save toggle, report directory location
- **Dimensions** — Always-run, never-run, auto-recommend preferences

Settings stored at `.hone/config.json`.

## Review Memory

Hone saves review reports to `.hone/reports/`. Future reviews read past reports to:

- Avoid re-asking questions that were already answered
- Reference past decisions ("You accepted this risk in March — still the case?")
- Check if previous findings were addressed

Remove `.hone/` from your `.gitignore` to share review history with your team.

## Philosophy

- **Questions are the product** — A spec that survived 23 questions is categorically different from one that survived 3
- **Craft over speed** — Slow down at the spec to go faster everywhere else
- **Repair is refinement** — Gaps found are features, not failures. Gold seams, not red errors.
- **Right-sized rigor** — A copy fix doesn't need the same depth as a system migration
- **Composable, not monolithic** — Use one dimension or all ten

## License

MIT

---

*Hone 磨く — Sharpen the spec. Ship with craft.*
