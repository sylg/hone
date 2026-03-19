#!/bin/bash
# Check if a spec has already been Hone-reviewed.
# Input: path to a spec file
# Output: JSON with review status and details if found

set -euo pipefail

SPEC_FILE="${1:?Usage: check-honed.sh <spec-file>}"

if [ ! -f "$SPEC_FILE" ]; then
  echo '{"error": "File not found: '"$SPEC_FILE"'"}' >&2
  exit 1
fi

if grep -q '<!-- 🪙 Hone Review:' "$SPEC_FILE" 2>/dev/null; then
  # Extract review header details
  REVIEW_LINE=$(grep -A5 '<!-- 🪙 Hone Review:' "$SPEC_FILE" | head -6)
  DATE=$(echo "$REVIEW_LINE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1 || echo "unknown")
  VERDICT=$(echo "$REVIEW_LINE" | grep -oiE 'Verdict:\s*(SHARP|NEEDS.HONING|ROUGH.EDGE|RESHAPE)' | sed 's/Verdict:[[:space:]]*//' | head -1 || echo "unknown")
  
  echo "{\"reviewed\": true, \"date\": \"$DATE\", \"verdict\": \"$VERDICT\"}"
else
  echo '{"reviewed": false}'
fi
