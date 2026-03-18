---
name: hone-sharpen
description: >
  Apply repairs to a spec based on review findings. Takes all accumulated
  findings from a Hone review and rewrites the spec with fixes applied.
  Marks every change with Kintsugi markers. Shows a before/after diff.
user-invokable: true
args:
  - name: target
    description: File path of spec to sharpen
    required: false
---

Apply all review findings to the spec in a single pass. This is the payoff.

## Prerequisites

A Hone review must have been run first (`/hone-review`, `/hone-gaps`, etc.). The review produces findings — this command applies them.

If no review has been run in the current conversation, say: "No review findings to apply. Run `/hone-review` first."

## Input

Accept the file path of the spec to sharpen. If not provided:
- Use the spec from the most recent review in conversation
- If no file path exists (spec was pasted), ask where to save the sharpened version

## Process

1. **Gather all findings** from the review conversation — every annotated finding with its developer decision
2. **Categorize repairs** based on developer responses:
   - "Add to spec" / "Add error handling" → Apply the suggested fix
   - "Developer confirmed" → Make the implicit assumption explicit
   - "Needs research" → Add as a spike/research task
   - "Out of scope" → Add to Non-goals with risk note
   - "Skipped" → Add as `<!-- ⚠ UNREVIEWED: [description] -->` comment
   - "Risk accepted" → Add to Non-goals with `⚠ ACCEPTED RISK` marker
3. **Apply repairs** to the spec — read the original, apply changes
4. **Add review header** at the top of the spec
5. **Show the diff** — before/after comparison
6. **Offer re-review** — ask if they want to run a quick scan to verify

## Repair Rules

### What to change
- Add missing error handling descriptions to tasks
- Add missing edge cases to acceptance criteria
- Make implicit assumptions explicit (add to Assumptions section, or create one)
- Add research/spike tasks for unresolved questions
- Add items to Non-goals for out-of-scope decisions
- Add validation rules, constraints, or specifications mentioned in answers
- Restructure tasks if God Task decomposition was accepted

### What NOT to change
- Don't rewrite the spec's voice or style — preserve the author's writing
- Don't add content the developer didn't agree to in the Q&A
- Don't remove anything from the original spec
- Don't reorganize sections unless explicitly needed by a finding

### Markers

Every change gets a marker so the author can see what Hone touched:

**For additions** (new content):
```markdown
<!-- 🪙 HONED: Added error handling for Stripe 402/429/500 responses -->
Handle checkout session creation failures:
- 402 (card declined): Show user-friendly error, suggest trying another card
- 429 (rate limited): Retry with exponential backoff, max 3 attempts
- 500 (Stripe outage): Show "payment system temporarily unavailable" message
```

**For explicit assumptions** (making implicit → explicit):
```markdown
<!-- 🪙 HONED: Made version format assumption explicit -->
- Version strings use semver format without 'v' prefix (e.g., `1.2.3`, not `v1.2.3`)
```

**For research tasks** (unresolved questions):
```markdown
<!-- 🪙 HONED: Added research task from review Q3 -->
- [ ] **Spike**: Catalog all Stripe webhook event types needed for checkout flow
      (checkout.session.completed, expired, payment_intent.failed, etc.)
```

**For non-goals** (out of scope with risk):
```markdown
<!-- 🪙 HONED: Documented as non-goal with risk acknowledgment -->
- Webhook signature verification (⚠ ACCEPTED RISK: without this, anyone can
  forge webhook events. Planned for v2.)
```

**For unreviewed items** (skipped questions):
```markdown
<!-- ⚠ UNREVIEWED: Task implementation detail not assessed during review -->
```

### Review Header

Add at the very top of the spec:

```markdown
<!-- 🪙 Hone Review: {date}
     Questions: {n} asked, {m} answered, {k} skipped
     Findings: {total} ({critical} critical, {high} high, {med} medium, {low} low)
     Verdict: {verdict}
     Dimensions: {list of dimensions run}
-->
```

## Output — The Diff

After applying all changes, show the diff in a styled format:

```
╭─ SHARPENED ────────────────────────────────────────────────────────────
│
│  Spec:     Changelog Notification Popover
│  Changes:  4 repairs applied
│
│  + 1 assumption made explicit (version format)
│  + 1 non-goal revised (PT library now allowed)
│  + 1 research task added (Stripe webhook events)
│  + 1 risk documented (webhook signature verification)
│
│  The spec has been updated at: [file path]
│
```

Then show each change as a mini-diff:

```
🟡 ── Assumption: Version format ───────────────────────────────────────

   BEFORE:  (not stated)
   AFTER:   Version strings use semver without 'v' prefix (1.2.3)
   WHY:     GROQ query does exact match — format mismatch = silent failure
─────────────────────────────────────────────────────────────────────────
```

## After Sharpening

Ask via `AskUserQuestion`:

```
AskUserQuestion({
  questions: [{
    header: "Next step",
    question: "The spec has been sharpened with 4 repairs. What would you like to do?",
    options: [
      { label: "Quick re-review", description: "Run a fast Size S scan to verify the repairs look right" },
      { label: "Generate report", description: "Save a full review report to docs/hone/" },
      { label: "Done", description: "The spec is ready — proceed to implementation" }
    ],
    multiSelect: false
  }]
})
```
