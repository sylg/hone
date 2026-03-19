#!/bin/bash
# Parse a markdown spec and extract structured data for size classification.
# Input: path to a markdown spec file
# Output: JSON with task count, section structure, domain signals

set -euo pipefail

SPEC_FILE="${1:?Usage: parse-spec.sh <spec-file>}"

if [ ! -f "$SPEC_FILE" ]; then
  echo '{"error": "File not found: '"$SPEC_FILE"'"}' >&2
  exit 1
fi

CONTENT=$(cat "$SPEC_FILE")

# Count tasks (lines starting with - [ ], numbered items, or ### Task headers)
TASK_COUNT=$(grep -cE '^\s*(-\s*\[.\]|[0-9]+\.\s|#{1,3}\s*(Task|Step)\s)' "$SPEC_FILE" 2>/dev/null || true)
TASK_COUNT="${TASK_COUNT:-0}"
TASK_COUNT=$(echo "$TASK_COUNT" | tr -d '[:space:]')

# Count total words
WORD_COUNT=$(wc -w < "$SPEC_FILE" | tr -d ' ')

# Check for section presence
has_section() {
  grep -qiE "^#{1,3}\s*$1" "$SPEC_FILE" 2>/dev/null && echo true || echo false
}

HAS_WHY=$(has_section "(why|motivation|background|context|problem)")
HAS_CONSTRAINTS=$(has_section "(constraints?|limitations?|requirements?)")
HAS_NON_GOALS=$(has_section "(non[- ]goals?|out[- ]of[- ]scope|not included)")
HAS_SUCCESS=$(has_section "(success|acceptance|done|criteria|verification)")
HAS_TASKS=$(has_section "(tasks?|steps?|implementation|plan)")

# Domain signal detection (case-insensitive)
detect_signal() {
  grep -qiE "$1" "$SPEC_FILE" 2>/dev/null && echo true || echo false
}

MENTIONS_AUTH=$(detect_signal "(auth|login|session|token|jwt|oauth|sso|password|mfa|permission|rbac)")
MENTIONS_PAYMENTS=$(detect_signal "(stripe|billing|subscription|checkout|invoice|refund|payment|price|plan)")
MENTIONS_MIGRATION=$(detect_signal "(migrat|schema change|alter table|backfill|data transform)")
MENTIONS_EXTERNAL_API=$(detect_signal "(api key|third.party|external service|webhook|sdk|integration)")
MENTIONS_SECURITY=$(detect_signal "(security|vulnerab|encrypt|sanitiz|xss|injection|csrf|cors)")
MENTIONS_DATABASE=$(detect_signal "(database|schema|table|column|index|query|sql|orm|migration)")
MENTIONS_REALTIME=$(detect_signal "(websocket|sse|real.time|live update|polling|socket)")
MENTIONS_FILE_HANDLING=$(detect_signal "(upload|download|storage|s3|cdn|file|image processing)")

# Check if already hone-reviewed
ALREADY_HONED=$(grep -q '<!-- 🪙 Hone Review:' "$SPEC_FILE" 2>/dev/null && echo true || echo false)

# Extract task details (title + line number for each task-like line)
TASKS_JSON=$(grep -nE '^\s*(-\s*\[.\]|[0-9]+\.\s|#{1,3}\s*(Task|Step)\s)' "$SPEC_FILE" 2>/dev/null | head -50 | while IFS=: read -r line_num line_text; do
  # Clean up the line text for JSON
  clean_text=$(echo "$line_text" | sed 's/^[[:space:]]*[-*] \[.\] //' | sed 's/^[[:space:]]*[0-9]*\. //' | sed 's/^#* //' | sed 's/"/\\"/g' | head -c 200)
  echo "{\"line\":$line_num,\"title\":\"$clean_text\"}"
done | paste -sd',' - 2>/dev/null || echo "")

if [ -z "$TASKS_JSON" ]; then
  TASKS_JSON="[]"
else
  TASKS_JSON="[$TASKS_JSON]"
fi

cat <<EOF
{
  "file": "$SPEC_FILE",
  "task_count": $TASK_COUNT,
  "word_count": $WORD_COUNT,
  "tasks": $TASKS_JSON,
  "sections": {
    "has_why": $HAS_WHY,
    "has_constraints": $HAS_CONSTRAINTS,
    "has_non_goals": $HAS_NON_GOALS,
    "has_success_criteria": $HAS_SUCCESS,
    "has_tasks": $HAS_TASKS
  },
  "domain_signals": {
    "auth": $MENTIONS_AUTH,
    "payments": $MENTIONS_PAYMENTS,
    "migration": $MENTIONS_MIGRATION,
    "external_api": $MENTIONS_EXTERNAL_API,
    "security": $MENTIONS_SECURITY,
    "database": $MENTIONS_DATABASE,
    "realtime": $MENTIONS_REALTIME,
    "file_handling": $MENTIONS_FILE_HANDLING
  },
  "already_honed": $ALREADY_HONED
}
EOF
