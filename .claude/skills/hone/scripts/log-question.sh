#!/bin/bash
# PostToolUse hook: logs every AskUserQuestion invocation to .hone/session.json
# for the reporter agent and eval harness.
#
# This script appends structured question data to the session file.
#
# Environment:
#   HONE_SESSION_FILE — path to session log (default: .hone/session.json)
#   HONE_DIMENSION — current dimension being reviewed
#
# Input: tool output on stdin (the AskUserQuestion result)

set -uo pipefail

SESSION_FILE="${HONE_SESSION_FILE:-.hone/session.json}"

# Create session file with initial structure if it doesn't exist
if [ ! -f "$SESSION_FILE" ]; then
  mkdir -p "$(dirname "$SESSION_FILE")"
  echo '{"questions": [], "started": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}' > "$SESSION_FILE"
fi

# Read the tool output
INPUT=$(cat)

# Extract question details from AskUserQuestion output
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
DIMENSION="${HONE_DIMENSION:-unknown}"

# Extract header (contains tier badge and counter)
HEADER=$(echo "$INPUT" | grep -oE '"header"\s*:\s*"[^"]*"' | head -1 | sed 's/"header"\s*:\s*"//' | sed 's/"$//')

# Extract tier from header (e.g., "T2 Gap [3/18]" → "T2")
TIER=$(echo "$HEADER" | grep -oE 'T[1-5]' | head -1)
TIER="${TIER:-T1}"

# Extract counter from header (e.g., "[3/18]")
COUNTER=$(echo "$HEADER" | grep -oE '\[[0-9]+/~?[0-9]+\]' | head -1)

# Extract question text
QUESTION=$(echo "$INPUT" | grep -oE '"question"\s*:\s*"[^"]*"' | head -1 | sed 's/"question"\s*:\s*"//' | sed 's/"$//' | head -c 500)

# Build the question entry
ENTRY=$(cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "tier": "$TIER",
  "dimension": "$DIMENSION",
  "header": "$HEADER",
  "question": "$QUESTION",
  "counter": "$COUNTER"
}
EOF
)

# Append to questions array in session file
# Use python if available for reliable JSON manipulation, otherwise append raw
if command -v python3 &>/dev/null; then
  python3 -c "
import json, sys
entry = json.loads('''$ENTRY''')
with open('$SESSION_FILE', 'r') as f:
    session = json.load(f)
session['questions'].append(entry)
with open('$SESSION_FILE', 'w') as f:
    json.dump(session, f, indent=2)
" 2>/dev/null || true
fi

exit 0
