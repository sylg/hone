# Hone

You said "looks good" without checking.
The agent ran with it.
Now you're debugging a spec you never reviewed.

Hone sits between plan and execution. It pressure-tests specs through interactive Q&A — surfacing gaps, challenging assumptions, finding what you didn't know to ask. Then it sharpens the spec with tracked repairs.

Your agent writes the spec. Hone sharpens it.

## Philosophy

- **Questions are the product** — A spec that survived 23 questions is categorically different from one that survived 3
- **Craft over speed** — Slow down at the spec to go faster everywhere else
- **Repair is refinement** — Gaps found are features, not failures
- **Right-sized rigor** — A copy fix doesn't need the same depth as a system migration
- **Composable, not monolithic** — Use one dimension or all ten

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

╔═ HONE REVIEW COMPLETE ══════════════════════════════════
║  Verdict: 🟡 NEEDS HONING
║  4 findings · 7 questions · Confidence: MEDIUM
╚═════════════════════════════════════════════════════════

    ↓

   /hone-sharpen → Repairs applied with tracked markers
   /hone-report  → Persistent report saved
```

## What a review looks like

Given a spec for adding Stripe checkout to a pricing page:

```
✦ GAPS
🟠 High — No error handling for checkout session creation. Task 2 calls
  Stripe's API but doesn't handle 402 (card declined), 429 (rate limit),
  or 500 (Stripe outage). Users will see an unhandled exception.

🟠 High — No webhook signature verification. Task 5 accepts POST requests
  to /api/webhooks/stripe without verifying the Stripe-Signature header.
  Anyone can forge events and grant themselves a paid plan.

🟡 Medium — No cancel or failure redirect URL. Task 3 redirects to Stripe
  but doesn't specify where users go if they abandon checkout or payment fails.

✦ ASSUMPTIONS
🟡 Medium — Spec assumes price IDs already exist in Stripe. No task to
  create products/prices or document which price IDs map to which plans.

Verdict: 🟡 NEEDS HONING · 4 findings · 8 questions · Confidence: HIGH
```

## Install

**Works with Claude Code · Cursor · Codex CLI · Gemini CLI · OpenCode**

### Claude Code (Plugin Marketplace)

```
/plugin marketplace add sylg/hone
/plugin install hone@sylg-hone
```

### Skills.sh

```bash
npx skills add sylg/hone
```

### Manual

```bash
git clone https://github.com/sylg/hone.git .hone-plugin
cp -r .hone-plugin/.claude .claude
cp -r .hone-plugin/.claude-plugin .claude-plugin
```

## Commands

Start here:

| Command | What it does |
|---------|-------------|
| `/hone-review` | Full review pipeline — size, recommend, question, verdict |
| `/hone-sharpen` | Apply all findings as tracked repairs |
| `/hone-report` | Generate persistent review report |
| `/hone-gaps` | Find what's missing — error handling, edge cases, rollback |

All commands:

| Command | What it does |
|---------|-------------|
| `/hone-assumptions` | Surface what must be true but isn't stated |
| `/hone-unknowns` | Domain-specific gotchas you didn't know to ask about |
| `/hone-complexity` | Find tasks that are actually multiple tasks |
| `/hone-scope` | Detect scope creep — what doesn't belong |
| `/hone-deps` | Map task dependencies and ordering |
| `/hone-testability` | Check if "done" is defined concretely |
| `/hone-context` | Can a fresh dev execute without asking questions? |
| `/hone-simplicity` | Flag premature abstractions and over-engineering |
| `/hone-data-quality` | Review schema design, constraints, migration safety |
| `/hone-diff` | Show before/after of sharpened spec |
| `/hone-settings` | Configure models, reports, dimensions |

## 10 Review Dimensions

Two dimensions always run. The rest are recommended per-spec.

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

## Ratings

**Severities:**

- 🟥 **Critical** — Data loss, security breach, or outage
- 🟠 **High** — User-facing errors in production
- 🟡 **Medium** — Degraded experience or hotfix needed
- 🔵 **Low** — Cosmetic, can address post-launch

**Verdicts:**

| Verdict | Meaning |
|---------|---------|
| 🟢 **SHARP** | Safe to execute. |
| 🟡 **NEEDS HONING** | Gaps found, structure sound. Run `/hone-sharpen`. |
| 🟠 **ROUGH EDGE** | Structural issues. Needs replanning. |
| 🔴 **RESHAPE** | Wrong approach. Back to design. |

## Configuration

Run `/hone-settings` to configure:

- **Models** — Set which model runs the review vs. subagents (cost control)
- **Reports** — Auto-save toggle, report directory location
- **Dimensions** — Always-run, never-run, auto-recommend preferences

Settings stored at `.hone/config.json`.

Hone remembers past reviews. It won't re-ask questions you already answered. It'll reference past decisions: "You accepted this risk in March — still the case?"

Reports are saved to `.hone/reports/`. Remove `.hone/` from your `.gitignore` to share review history with your team.

## License

MIT
