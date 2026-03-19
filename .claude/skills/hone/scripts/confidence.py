#!/usr/bin/env python3
"""Calculate confidence score from a question scorecard JSON.

Input: JSON on stdin with structure:
{
  "questions": [
    {"tier": "T2", "status": "answered"|"deferred"|"skipped"},
    ...
  ],
  "dimensions_run": 3,
  "dimensions_applicable": 5,
  "size": "M"
}

Output: JSON with score and label.
"""

import json
import sys


def main():
    try:
        scorecard = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"Invalid JSON: {e}"}))
        sys.exit(1)

    questions = scorecard.get("questions", [])
    if not questions:
        print(json.dumps({"score": 0.0, "label": "LOW", "reason": "No questions in scorecard"}))
        return

    tier_weights = {"T1": 1, "T2": 2, "T3": 3, "T4": 4, "T5": 3}

    answered_weight = sum(
        tier_weights.get(q.get("tier", "T1"), 1)
        for q in questions
        if q.get("status") == "answered"
    )
    total_weight = sum(
        tier_weights.get(q.get("tier", "T1"), 1)
        for q in questions
    )

    dims_run = scorecard.get("dimensions_run", 1)
    dims_applicable = scorecard.get("dimensions_applicable", 1)
    dimension_coverage = dims_run / max(dims_applicable, 1)

    raw = (answered_weight / max(total_weight, 1)) * dimension_coverage

    reasons = []

    # Constraint 1: Tier diversity — confidence cannot be HIGH unless
    # at least one T3+ question was asked and answered
    max_answered_tier = max(
        (int(q["tier"][1]) for q in questions
         if q.get("status") == "answered" and q.get("tier", "T1").startswith("T")),
        default=0
    )
    if max_answered_tier < 3:
        if raw >= 0.8:
            reasons.append("Capped: no T3+ questions answered (tier diversity)")
        raw = min(raw, 0.79)

    # Constraint 2: Minimum question count per size
    size = scorecard.get("size", "M")
    min_for_high = {"S": 2, "M": 4, "L": 10, "XL": 15}
    min_for_medium = {"S": 1, "M": 2, "L": 5, "XL": 8}

    answered_count = sum(1 for q in questions if q.get("status") == "answered")

    if answered_count < min_for_high.get(size, 4):
        if raw >= 0.8:
            reasons.append(f"Capped: only {answered_count} answered, need {min_for_high.get(size, 4)} for HIGH at size {size}")
        raw = min(raw, 0.79)

    if answered_count < min_for_medium.get(size, 2):
        if raw >= 0.5:
            reasons.append(f"Capped: only {answered_count} answered, need {min_for_medium.get(size, 2)} for MEDIUM at size {size}")
        raw = min(raw, 0.49)

    label = "HIGH" if raw >= 0.8 else "MEDIUM" if raw >= 0.5 else "LOW"

    result = {"score": round(raw, 3), "label": label}
    if reasons:
        result["constraints_applied"] = reasons

    print(json.dumps(result))


if __name__ == "__main__":
    main()
