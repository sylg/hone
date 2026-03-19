# Testability Review

Can every task be verified? Is "done" defined concretely? Could a fresh agent verify success without asking questions?

## The Testability Test

#### P0 — Always check

For each task's success criteria, apply this test:

> If I handed this task to a new developer who has never seen the codebase, could they verify it's done without asking a single question?

If the answer is no, the success criteria are too vague.

## What Makes Success Criteria Testable

### Testable (good)

- "API returns 200 with `{ status: 'active' }` when subscription is confirmed"
- "Button is disabled and shows spinner during CSV generation"
- "File downloads with name format `dashboard-export-YYYY-MM-DD.csv`"
- "Query executes in under 200ms for datasets up to 100K rows"
- "Error message 'Invalid email format' appears below the input field"

### Untestable (bad)

- "It works"
- "Tests pass"
- "Performance is acceptable"
- "UI looks good"
- "No regressions"
- "User experience is improved"
- "Code is clean"

### The Vague Words Checklist

Flag these words in success criteria — they're almost always untestable:

#### P0 — Always check

| Vague Word | What to Ask Instead |
|-----------|-------------------|
| "works" | Works how? What's the input, expected output, and error case? |
| "fast" | How fast? What's the baseline and target in milliseconds? |
| "good" | Good by what standard? What would bad look like? |
| "secure" | Against which threats? What security controls are verified? |

#### P1 — Check for M+

| Vague Word | What to Ask Instead |
|-----------|-------------------|
| "clean" | What specific code quality metrics? Lint rules? Complexity score? |
| "robust" | What failure modes does it handle? What's the recovery behavior? |
| "scalable" | At what scale? What's the current load and target load? |
| "improved" | Improved from what baseline? By how much? Measured how? |
| "better" | Better than what? By what metric? |

#### P2 — Check for L+

| Vague Word | What to Ask Instead |
|-----------|-------------------|
| "appropriate" | Appropriate according to whom? What's the rule? |
| "properly" | What does proper look like? What's improper? |
| "correctly" | What defines correct? What's an example of incorrect? |

## Task Rating

Rate each task:

| Rating | Definition |
|--------|-----------|
| **TESTABLE** ✅ | Clear input, expected output, and verification method. A fresh agent can verify. |
| **VAGUE** 🟡 | Partially testable. Some criteria are clear, others need refinement. |
| **UNTESTABLE** 🔴 | No concrete success criteria. "Done" is undefined or subjective. |

## Concrete Verification Steps

For each VAGUE or UNTESTABLE task, suggest a concrete verification:

**Original**: "Make the dashboard faster"

**Suggested verification**:
```
1. Measure current page load time (DOMContentLoaded) — record baseline
2. Measure current largest contentful paint (LCP) — record baseline
3. After optimization:
   - Page load time < 1.5s on 3G throttle
   - LCP < 2.5s
   - No layout shift (CLS < 0.1)
4. Run Lighthouse audit — performance score > 90
```

**Original**: "Tests pass"

**Suggested verification**:
```
1. All existing unit tests pass (npm test exits 0)
2. New tests added for: [specific behaviors]
3. Test coverage for new code > 80%
4. No skipped or pending tests
```

## Missing Test Considerations

Beyond success criteria, check:

#### P1 — Check for M+
- **No test strategy mentioned**: How is this feature tested? Unit? Integration? E2E? Manual?
- **No error case testing**: Are failure modes verified?

#### P2 — Check for L+
- **No edge case coverage**: Are boundary conditions tested?
- **No performance criteria**: Are there latency/throughput requirements?

#### P3 — Check for XL only
- **No regression testing**: How do we know nothing else broke?
- **No acceptance criteria**: How does the product owner verify this?

## Output Format

### Task Rating Table

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 TESTABILITY REVIEW                                               │
│                                                                       │
│  Task 1 — Add Stripe SDK              ✅ TESTABLE                    │
│  Task 2 — Create checkout endpoint    🟡 VAGUE ("creates a session") │
│  Task 3 — Redirect to checkout        ✅ TESTABLE                    │
│  Task 4 — Handle success redirect     🟡 VAGUE ("display success")   │
│  Task 5 — Handle webhook              🔴 UNTESTABLE (no error cases) │
│  Task 6 — Update UI                   🔴 UNTESTABLE ("show status")  │
│                                                                       │
│  Summary: 2 testable, 2 vague, 2 untestable                          │
╰───────────────────────────────────────────────────────────────────────╯
```

### Individual Findings

```
🪙 ── Testability: [Short title] ────────────────────────────────────────

   📍  [Which task]
   ❓  [T2] [Question about vague success criteria]

   Current criteria: "[quoted from spec]"
   Problem: [Why this is untestable]

   🔧 SUGGESTED VERIFICATION:
      1. [Concrete step]
      2. [Concrete step]
      3. [Concrete step]

   Rating: [TESTABLE ✅ / VAGUE 🟡 / UNTESTABLE 🔴]
─────────────────────────────────────────────────────────────────────────
```
