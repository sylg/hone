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
TASKS_RAW=$(grep -nE '^\s*(-\s*\[.\]|[0-9]+\.\s|#{1,3}\s*(Task|Step)\s)' "$SPEC_FILE" 2>/dev/null | head -50 || true)

# Use python3 for safe JSON output (handles escaping correctly)
# Pass tasks via stdin, everything else via env vars
export _HONE_FILE="$SPEC_FILE" _HONE_TASKS="$TASK_COUNT" _HONE_WORDS="$WORD_COUNT" \
  _HONE_WHY="$HAS_WHY" _HONE_CONSTRAINTS="$HAS_CONSTRAINTS" _HONE_NONGOALS="$HAS_NON_GOALS" \
  _HONE_SUCCESS="$HAS_SUCCESS" _HONE_HASTASKS="$HAS_TASKS" \
  _HONE_AUTH="$MENTIONS_AUTH" _HONE_PAY="$MENTIONS_PAYMENTS" _HONE_MIG="$MENTIONS_MIGRATION" \
  _HONE_API="$MENTIONS_EXTERNAL_API" _HONE_SEC="$MENTIONS_SECURITY" _HONE_DB="$MENTIONS_DATABASE" \
  _HONE_RT="$MENTIONS_REALTIME" _HONE_FILE="$MENTIONS_FILE_HANDLING" \
  _HONE_HONED="$ALREADY_HONED"

echo "$TASKS_RAW" | python3 -c '
import json, sys, os, re

def to_bool(s):
    return s.strip().lower() == "true"

def env(k):
    return os.environ.get(k, "")

# Parse task lines from stdin (format: "linenum:text")
tasks = []
for line in sys.stdin:
    line = line.strip()
    if ":" not in line:
        continue
    num, text = line.split(":", 1)
    text = re.sub(r"^\s*[-*]\s*\[.\]\s*", "", text)
    text = re.sub(r"^\s*\d+\.\s*", "", text)
    text = re.sub(r"^#+\s*", "", text)
    try:
        tasks.append({"line": int(num.strip()), "title": text.strip()[:200]})
    except ValueError:
        continue

tc = env("_HONE_TASKS")
wc = env("_HONE_WORDS")

result = {
    "file": env("_HONE_FILE"),
    "task_count": int(tc) if tc else 0,
    "word_count": int(wc) if wc else 0,
    "tasks": tasks,
    "sections": {
        "has_why": to_bool(env("_HONE_WHY")),
        "has_constraints": to_bool(env("_HONE_CONSTRAINTS")),
        "has_non_goals": to_bool(env("_HONE_NONGOALS")),
        "has_success_criteria": to_bool(env("_HONE_SUCCESS")),
        "has_tasks": to_bool(env("_HONE_HASTASKS")),
    },
    "domain_signals": {
        "auth": to_bool(env("_HONE_AUTH")),
        "payments": to_bool(env("_HONE_PAY")),
        "migration": to_bool(env("_HONE_MIG")),
        "external_api": to_bool(env("_HONE_API")),
        "security": to_bool(env("_HONE_SEC")),
        "database": to_bool(env("_HONE_DB")),
        "realtime": to_bool(env("_HONE_RT")),
        "file_handling": to_bool(env("_HONE_FILE")),
    },
    "already_honed": to_bool(env("_HONE_HONED")),
}

print(json.dumps(result, indent=2))
'
