# Visual Identity

Hone's output should feel **crafted**, not generated. Every interaction has a distinct visual presence — the developer should recognize Hone output at a glance.

## Design Language

- **🪙 is rare** — The 🪙 emoji appears in exactly TWO places: the final verdict header (`🪙 HONE REVIEW COMPLETE`) and the sharpen offer. Nowhere else. No phase headers, no finding lines, no progress indicators.
- **Severity colors** — Use colored square emojis for severity throughout:
  - 🟥 critical
  - 🟠 high
  - 🟡 medium
  - 🔵 low
  These appear on finding annotations in the spec markup, milestone chain summaries, and the verdict dimensions table. The color does the work — no additional shape needed.
- **Box drawing** — Use Unicode box-drawing characters (`─`, `│`, `┌`, `┐`, `└`, `┘`, `├`, `┤`, `┬`, `┴`, `╭`, `╯`) for frames and containers. Never plain `---` dividers.
- **Progress bars** — Use block characters (`█`, `░`, `▓`, `▒`) for confidence and completion indicators.
- **Compact tables** — Use markdown tables for structured data. Align columns. Keep them tight.
- **Whitespace is intentional** — Breathing room between sections. Never a wall of text.
- **Wide containers** — All boxes should be exactly 72 characters wide (from `│` to `│` or `┌` to `┐`). Right edges MUST align vertically. A misaligned right border looks broken and is unacceptable.

## RIGHT BORDER ALIGNMENT — CRITICAL

**This is the #1 visual quality rule.** Every line inside a box MUST be padded with trailing spaces so the closing `│` lands in the exact same column. No exceptions.

How to do it:
1. Pick a fixed width for the box (72 chars from left border to right border)
2. For EVERY content line: write the text, then pad with spaces until the closing `│` is at exactly column 72
3. The top border (`┌─...─┐`), bottom border (`└─...─┘`), and every content line (`│ ... │`) must ALL be the same total width
4. Double-check: if you look at only the rightmost column, every character should be `│`, `┐`, `┘`, `┤`, or `║`

Common mistakes to avoid:
- Lines with emojis: emojis are 2 chars wide but look like 1. Add 1 extra space per emoji.
- Lines with `█░▓▒` block characters: these are 1 char wide, no special handling needed.
- Nested boxes: the inner box's right `│` is NOT the outer box's right `║`. Count carefully.

If you cannot guarantee alignment, use a simpler format (no right border) rather than a misaligned one:

```
┌─ GAPS ─────────────────────────────────────────
│
│  3 findings  ·  █ high  █ med  █ low
│  5 questions asked, 4 answered
│
```

This open-right format is acceptable when exact padding is uncertain. It's better than a wobbly right border.

## Phase Headers

When entering a new phase, announce it with a styled header:

```
╭───────────────────────────────────────────────────────────────────────╮
│  PHASE 0 ─ SIZE CALIBRATION                                          │
╰───────────────────────────────────────────────────────────────────────╯
```

## Classification Announcement

Use a wide format. Right-align the progress bars and scores into a clean table. Keep descriptions short — one line per axis.

```
╭───────────────────────────────────────────────────────────────────────╮
│  SIZE CLASSIFICATION                                                  │
│                                                                       │
│  Verdict:   L (Large)                                                 │
│  Reason:    New feature, 3 integration points, external service       │
│                                                                       │
│  Blast radius    ███░  3/4   new feature, new dependency, 3+ integs  │
│  Reversibility   ██░░  2/4   mostly reversible, minor cleanup        │
│  Domain risk     ████  4/4   auth / payments / security              │
│  Novelty         ██░░  2/4   known pattern, first time in codebase   │
│                                                                       │
│  Total: 11/16 → L (bumped: domain risk = 4)                          │
│                                                                       │
│  Review depth:   15-25 questions                                      │
│  Dimensions:     all 7                                                │
│  Unknowns:       yes                                                  │
╰───────────────────────────────────────────────────────────────────────╯
```

## Finding Format

Each finding uses the severity color as its marker — not 🪙:

```
🟠 ── Gap: Missing webhook retry logic ─────────────────────────────────

   📍  Task 5 — Webhook handler
   ❓  [T2] What happens when Stripe returns 502?

   The spec says "handle errors" but doesn't specify what "handle" means.
   In production, webhooks fail 2-5% of the time on transient errors.

   ⚠  RISK:  Events silently dropped on transient failure
   🔧 FIX:   Add exponential backoff retry (3 attempts)
             + dead letter queue for persistent failures
─────────────────────────────────────────────────────────────────────────
```

The severity color (`🟥` / `🟠` / `🟡` / `🔵`) replaces both the 🪙 marker and the `Severity:` bar.

## Verdict Block (Final)

Use open-right format for the verdict to avoid alignment issues:

```
╔═ 🪙 HONE REVIEW COMPLETE ═════════════════════════════════════════════
║
║  Spec:       auth-feature-plan.md
║  Size:       L (new feature, 3 integration points)
║
║  ┌─ QUESTIONS ─────────────────────────────────────────────
║  │
║  │  Total asked:          23
║  │
║  │  T1 Clarification      ░░░░░░░░░░   0
║  │  T2 Gap                ████░░░░░░   7
║  │  T3 Challenge          ██░░░░░░░░   4
║  │  T4 Unknown Unknown    ██░░░░░░░░   4
║  │  T5 Tradeoff           █░░░░░░░░░   3
║  │
║  │  Answered: 21  ·  Deferred: 2  ·  Unknowns surfaced: 4
║  │
║  ┌─ DIMENSIONS ────────────────────────────────────────────
║  │
║  │  Gaps              3 findings    🟠 2 high  🟡 1 med
║  │  Assumptions       2 findings    🟠 1 high  🔵 1 low
║  │  Complexity        1 finding     🟠 1 high
║  │  Scope             ✓ clean
║  │  Dependencies      1 finding     🟡 1 med
║  │  Testability       1 finding     🟡 1 med
║  │  Context           ✓ clean
║  │  Unknowns          4 findings    🟠 2 high  🟡 2 med
║  │
║  Confidence:  ████████░░  HIGH
║
║  ┌─ VERDICT ───────────────────────────────────────────────
║  │
║  │   🟡  NEEDS HONING
║  │
║  │   12 findings  ·  🟠 6 high  🟡 4 med  🔵 2 low
║  │   Run /hone-sharpen to apply 🪙 repairs
║  │
╚════════════════════════════════════════════════════════════════════════
```

## Verdict Badges

Use these exact badge formats for each verdict:

- `🟢  SHARP` — clean, minimal, confident
- `🟡  NEEDS HONING` — work to do, but sound structure
- `🟠  ROUGH EDGE` — structural problems, needs replanning
- `🔴  RESHAPE` — fundamentally wrong approach

## Anti-Pattern Callouts

When an anti-pattern is detected, call it out with a named box:

```
╭─ ⚠ ANTI-PATTERN: The Happy Path Only ─────────────────────────────────
│
│  This spec describes 6 tasks. All 6 describe success scenarios.
│  Zero describe failure. Missing: error handling, retry logic,
│  rollback, timeout behavior, partial failure recovery.
│
```

## Review Progress (Milestone Chain)

After each dimension completes, show the **Milestone Chain** — a visual pipeline of connected dimension blocks. Use open-right format:

```
┌───────────────────────────────────────────────────────────────
│  ✅ GAPS
│  Found what's missing from the spec
│  3 findings  (🟠 1 high  🟡 1 med  🔵 1 low)  ·  5 questions
├───────────────────────────────────────────────────────────────
│  ✅ ASSUMPTIONS
│  Surfaced what must be true but isn't stated
│  2 findings  (🟠 1 high  🔵 1 low)  ·  4 questions
├───────────────────────────────────────────────────────────────
│  ▶ TESTABILITY
│  Checking if "done" is defined concretely...
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌
│  ○ CONTEXT
│  Can a fresh dev execute without asking questions?
├───────────────────────────────────────────────────────────────
│  Total: 5 findings  ·  9 questions asked, 8 answered
│  Progress ██████████░░░░░░░░░░  50%
└───────────────────────────────────────────────────────────────
```

Status markers: `✅` completed · `▶` running · `○` pending · `⚠` skipped

## Living Spec Markup

Display the spec's task list with inline annotations:

```
╭─ SPEC MARKUP — Stripe Payment Integration ─────────────────────────────
│  5 findings · 2 dimensions complete
│
│  Task 1: Add Stripe SDK
│  └─ ✓ clean
│
│  Task 2: Create checkout session endpoint
│  ├─ 🟠 Missing error handling for 402/429/500
│  │  → Developer chose: needs research
│  └─ 🟡 Assumes price IDs exist in Stripe
│     → Developer confirmed: yes, pre-configured
│
│  Task 5: Handle webhook
│  ├─ 🟥 No signature verification  ⚠ RISK ACCEPTED
│  └─ 🟡 Only handles completed event
│     → Developer chose: needs research
│
│  ╔═ 💡 KEY LEARNINGS ═════════════════════════════════════════════════
│  ║
│  ║  1. Stripe error catalog needs research before implementation
│  ║  2. ⚠ Webhook signature verification skipped for v1
│  ║
│  ╚════════════════════════════════════════════════════════════════════
│
```

### Rules for the Living Markup

1. **Show it after every dimension completes** — not after every question (too noisy)
2. **Annotations accumulate** — each dimension adds its findings to the markup
3. **Include developer decisions** — "chose: needs research", "confirmed: yes"
4. **Mark accepted risks prominently** — `⚠ RISK ACCEPTED` for critical/high dismissals
5. **Learnings section is visually prominent** — use a double-border box (`╔═╗`) with `💡 KEY LEARNINGS` header
6. **Clean tasks are marked** — `✓ clean` so the developer sees what's fine too
7. **Annotations can evolve** — if a later dimension extends an earlier finding, update it

## General Rules

1. **Never output a wall of text.** If you're writing more than 4 lines of prose without a visual break (box, table, divider, list), restructure.
2. **Every finding gets its own seam block.** Never list findings as bullet points.
3. **Progress is always visible.** The developer should always know: which phase, which dimension, which question number.
4. **Tables over paragraphs.** If data can be a table, make it a table.
5. **Breathe.** Empty lines between sections. Compact inside containers.
