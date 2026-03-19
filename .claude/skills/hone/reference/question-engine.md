# Question Engine

Questions are the product. Every question asked forces the developer to think about something they hadn't considered. Every question answered adds context that makes the spec stronger.

## Question Tiers

Questions are categorized by what they surface:

| Tier | Type | What It Surfaces | Weight |
|------|------|-----------------|--------|
| **T1: Clarification** | Ambiguity in the spec | Vague language, undefined terms, multiple interpretations | 1x |
| **T2: Gap** | Something missing | Unhandled edge cases, missing error paths, absent requirements | 2x |
| **T3: Challenge** | Testing an assumption | Unvalidated claims, untested constraints, optimistic estimates | 3x |
| **T4: Unknown Unknown** | Developer didn't know to ask | Domain-specific gotchas, security risks, scalability traps | 4x |
| **T5: Tradeoff** | Forcing a decision | Mutually exclusive options, resource constraints, priority conflicts | 3x |

Higher-tier questions contribute more to confidence. A review with 5 T4 questions is more valuable than one with 20 T1 questions.

## Question Construction Rules

### Be specific, not generic
- BAD: "Have you considered error handling?"
- GOOD: "What happens when the Stripe webhook returns a 502? The spec says 'handle errors' but doesn't specify retry logic, dead letter queue, or user notification."

### Reference the spec
- BAD: "What about performance?"
- GOOD: "Task 3 says 'query user history' but doesn't specify a time range. With 2M users averaging 500 events each, this query could return 1B rows. What's the intended scope?"

### One question at a time
- Ask a single question. Wait for the answer. Let the answer inform the next question.
- Exception: For Size S reviews, you may ask 2-3 questions together to keep things fast.

### No leading questions
- BAD: "Don't you think you should add rate limiting?"
- GOOD: "This endpoint is public-facing with no rate limiting specified. What's the expected traffic volume, and what happens if it's 10x higher?"

## Question Flow

```
Ask question → Wait for answer → Process answer
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                  │
              Answer resolves   Answer reveals     Developer can't
              the concern       new concern        answer
                    │                 │                  │
              Mark addressed    Queue follow-up    Flag as unresolved
              Move on           question            Assess risk level
```

### Processing Answers

When the developer answers:

1. **Resolves the concern**: Record the answer. Check if it also resolves any other pending questions. Move to next question.

2. **Reveals new concern**: Record the answer. Generate a follow-up question targeting the new concern. This is not "moving the goalposts" — it's the review working as intended.

3. **Can't answer**: This is valuable signal. Record as unresolved. Assess risk:
   - Low risk: Note it, move on
   - Medium risk: Flag it, suggest research
   - High risk: This may affect the verdict (NEEDS HONING or worse)

### Deferral

The developer can defer any question: "I'll figure this out later." Deferred questions:
- Stay visible in the final report
- Are tagged with risk level
- Count toward the scorecard but don't count as "answered"
- May lower the confidence score if high-risk

## Confidence Calculation

**IMPORTANT**: Do NOT calculate confidence manually. Use `scripts/confidence.py` by piping a JSON scorecard to it. The script handles all weighting, constraints, and edge cases correctly.

Confidence is based on:

1. **Question coverage**: Did the review cover all applicable dimensions?
2. **Answer ratio**: What percentage of questions were answered (not deferred)?
3. **Tier distribution**: Higher-tier questions answered → higher confidence
4. **Unresolved risk**: How many high-risk questions remain unanswered?

```
Confidence Score = (answered_weight / total_weight) × dimension_coverage

Where:
  answered_weight = sum of (tier_weight × 1) for each answered question
  total_weight = sum of (tier_weight × 1) for all questions asked
  dimension_coverage = dimensions_run / dimensions_applicable

Mapping:
  >= 0.8 → HIGH
  >= 0.5 → MEDIUM
  < 0.5  → LOW
```

### Constraint 1: Minimum Tier Diversity

Confidence CANNOT be HIGH unless at least one T3+ question was asked and answered. A review that only asks T1/T2 questions caps at 0.79 (MEDIUM) regardless of answer ratio.

### Constraint 2: Minimum Question Count Per Size

Confidence CANNOT be HIGH unless question count meets minimum for the spec size:

| Size | Min for HIGH | Min for MEDIUM |
|------|-------------|----------------|
| S    | 2           | 1              |
| M    | 4           | 2              |
| L    | 10          | 5              |
| XL   | 15          | 8              |

### Scorecard JSON Format (for scripts/confidence.py)

Pipe this JSON to `scripts/confidence.py` to get the score:

```json
{
  "questions": [
    {"tier": "T2", "status": "answered"},
    {"tier": "T3", "status": "answered"},
    {"tier": "T4", "status": "deferred"},
    {"tier": "T2", "status": "skipped"}
  ],
  "dimensions_run": 3,
  "dimensions_applicable": 5,
  "size": "M"
}
```

Output:
```json
{"score": 0.65, "label": "MEDIUM", "constraints_applied": ["Capped: only 3 answered, need 4 for HIGH at size M"]}
```

## Question Pacing

Match question pacing to task size:

| Size | Pacing |
|------|--------|
| S | 2-3 questions, can be asked together. Fast. |
| M | 5-10 questions, asked 1-2 at a time. Steady. |
| L | 15-25 questions, asked 1 at a time. Thorough. Group by dimension. |
| XL | 25+ questions, asked 1 at a time. Signal dimension transitions. Take breaks between dimensions. |

## Scorecard Format

After the review, display:

```
Questions asked:           [total]
  T1 Clarification:        [n]
  T2 Gap:                  [n]
  T3 Challenge:            [n]
  T4 Unknown Unknown:      [n]
  T5 Tradeoff:             [n]
Questions answered:        [n]
Questions deferred:         [n]
Unknown unknowns surfaced:  [n]

Confidence: [████████░░] [HIGH/MEDIUM/LOW]
```

A spec that survived 23 questions is categorically different from one that survived 3. The scorecard is the proof.
