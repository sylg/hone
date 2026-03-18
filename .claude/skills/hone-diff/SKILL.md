---
name: hone-diff
description: >
  Show the before/after diff of a honed spec. Displays what changed,
  what was added, and what was documented as out-of-scope. Works after
  /hone-sharpen has been run.
user-invokable: true
args:
  - name: target
    description: File path of honed spec
    required: false
---

Show the diff of changes made by `/hone-sharpen`.

## Prerequisites

`/hone-sharpen` must have been run first. If not, say: "No sharpened spec found. Run `/hone-sharpen` first."

## Input

Accept the file path of the sharpened spec. If not provided, use the most recently sharpened spec in conversation.

## Process

1. Find all `<!-- 🪙 HONED: ... -->` markers in the spec
2. For each marker, show a before/after comparison
3. Group changes by type: additions, explicit assumptions, research tasks, non-goals, unreviewed

## Output

Show each change as a styled diff block, using severity colors:

```
╭─ HONE DIFF — Changelog Notification Popover ──────────────────────────
│  4 changes applied by /hone-sharpen
│
│  🟡 ── Made explicit: Version format ─────────────────────────────────
│
│     BEFORE:  (not in spec)
│     AFTER:   "Version strings use semver without 'v' prefix (1.2.3)"
│     REASON:  GROQ exact match — mismatch = popover never shows
│
│  🟡 ── Revised: Non-goal updated ─────────────────────────────────────
│
│     BEFORE:  "External Portable Text rendering library"
│     AFTER:   (removed from non-goals — library now permitted)
│     REASON:  Custom PT renderer is disproportionate complexity
│
│  🔵 ── Added: Research task ──────────────────────────────────────────
│
│     ADDED:   "Spike: Catalog Stripe webhook events for checkout flow"
│     REASON:  Only checkout.session.completed handled — need full list
│
│  🟠 ── Documented risk: Webhook security ─────────────────────────────
│
│     ADDED:   Non-goal with ⚠ ACCEPTED RISK marker
│     RISK:    Anyone can forge webhook events without signature check
│     PLAN:    Planned for v2
│
```

At the end, show a summary:

```
│  Summary:
│  + 1 assumption made explicit
│  ~ 1 non-goal revised
│  + 1 research task added
│  + 1 risk documented
│  = 4 total changes
│
```
