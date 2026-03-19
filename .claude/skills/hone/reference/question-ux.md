# Question UX

All review questions MUST use the `AskUserQuestion` tool. This renders a native, interactive UI instead of ASCII boxes. The developer gets clickable options instead of reading monospace text.

## How to Map Hone Questions to AskUserQuestion

- **`header`**: Use the tier badge as the tag. Format: `T2 Gap [3/18]` (tier + dimension + counter).
- **`question`**: The full question text. Include the spec section reference. Example: "What happens when Stripe returns a 502 at POST /api/checkout? The spec (Task 2) doesn't address any failure path."
- **`options`**: Provide 2-4 context-appropriate response options.
- **`multiSelect`**: Always `false` for Hone questions (one answer per question).

## Option Patterns Per Tier

**For gap questions (T2)**:
- "Add error handling" — Describe what specifically to add
- "Out of scope for v1" — Acknowledge the gap, document as non-goal
- "Need to research" — Flag as spike/research task

**For assumption questions (T3)**:
- "Yes, that's correct" — Confirms the assumption, make it explicit
- "No, actually..." — Developer will clarify via Other
- "I don't know" — Flag as unresolved unknown

**For unknown unknown questions (T4)**:
- "Add to spec" — Incorporate as a task or constraint
- "Out of scope for v1" — Document as non-goal with risk note
- "Need to research" — Add as spike task
- "Tell me more" — Explain in detail, then re-ask

**For tradeoff questions (T5)**:
- Provide the 2-3 concrete tradeoff options as choices
- Each option's `description` explains the implication

## Skip Protection

If the developer tries to skip or dismiss a question (says "skip", "move on", "don't care"), do NOT silently move on. Use `AskUserQuestion` to confirm:

```
AskUserQuestion({
  questions: [{
    header: "⚠ Skip?",
    question: "Skipping this means the spec ships with an unreviewed gap. The quality of the review — and your confidence score — will be lower. Are you sure?",
    options: [
      { label: "Skip it", description: "Accept the gap. It will be flagged as UNREVIEWED in the verdict." },
      { label: "Let me answer", description: "Go back to the question — I'll give it a proper answer." }
    ],
    multiSelect: false
  }]
})
```

## Risky Answer Pushback

When the developer chooses an option that accepts significant risk (e.g., "Out of scope" on a security-critical gap, or dismissing a high-severity finding), push back with a confirmation via `AskUserQuestion`:

```
AskUserQuestion({
  questions: [{
    header: "⚠ Risk accepted",
    question: "You're choosing to ship without webhook signature verification. This means anyone can POST fake events and grant themselves a paid plan. This will be flagged as a CRITICAL accepted risk in the verdict. Are you sure?",
    options: [
      { label: "Yes, accept the risk", description: "I understand the risk. Document it and move on." },
      { label: "On second thought...", description: "Let me reconsider — go back to the original options." }
    ],
    multiSelect: false
  }]
})
```

Apply pushback when:
- A security-critical gap is dismissed (severity: Critical)
- A high-severity gap is marked "out of scope"
- An assumption with Critical/High impact-if-wrong is left unresolved
- An unknown unknown with risk:critical is ignored

Do NOT pushback on medium/low severity choices — respect the developer's judgment on those.

## Batching Questions

`AskUserQuestion` supports 1-4 questions per call. Use this to match pacing:

| Size | Questions per call |
|------|--------------------|
| S    | 2-3 (batch all)    |
| M    | 1-2 at a time      |
| L    | 1 at a time        |
| XL   | 1 at a time        |

## Example

For a T2 Gap question about missing webhook retry logic:

```
AskUserQuestion({
  questions: [{
    header: "T2 Gap [3/18]",
    question: "What happens when the Stripe webhook endpoint returns a 502? Task 5 says 'handle webhook' but doesn't specify retry logic, idempotency, or dead letter behavior. Webhooks fail 2-5% of the time in production.",
    options: [
      { label: "Add retry logic", description: "Add exponential backoff (3 attempts) + dead letter queue for persistent failures" },
      { label: "Out of scope", description: "Document as known gap, accept risk of dropped events in v1" },
      { label: "Need to research", description: "Add spike task to investigate Stripe's retry behavior and webhook best practices" }
    ],
    multiSelect: false
  }]
})
```

## Between Questions — Show Progress as Text

After receiving an answer and before asking the next question, output a brief text progress line:

```
  Gaps ❯ Q 4/~8  ████████░░░░░░░░░░░░  42%
```
