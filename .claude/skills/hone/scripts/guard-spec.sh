#!/bin/bash
# PreToolUse hook: prevents editing the spec file during review phases (0-2).
# Only /hone-sharpen (Phase 4) may modify the spec.
#
# This script is called by the hook system with tool input on stdin.
# It checks if the target file matches the spec being reviewed.
#
# Environment:
#   HONE_SPEC_PATH — set by the review skill to the spec being reviewed
#   HONE_PHASE — set by the review skill to the current phase (0-4)
#
# Exit codes:
#   0 — allow the edit
#   2 — block the edit (with reason on stdout as JSON)

set -uo pipefail

# If Hone environment vars aren't set, this isn't a Hone review — allow
if [ -z "${HONE_SPEC_PATH:-}" ] || [ -z "${HONE_PHASE:-}" ]; then
  exit 0
fi

# Only block during review phases (0, 1, 2, 3). Phase 4 (sharpen) may edit.
if [ "${HONE_PHASE}" = "4" ]; then
  exit 0
fi

# Read tool input from stdin to get the target file path
INPUT=$(cat)
TARGET_FILE=$(echo "$INPUT" | grep -oE '"file_path"\s*:\s*"[^"]*"' | head -1 | sed 's/"file_path"\s*:\s*"//' | sed 's/"$//')

if [ -z "$TARGET_FILE" ]; then
  exit 0
fi

# Resolve to absolute paths for comparison
SPEC_REAL=$(realpath "$HONE_SPEC_PATH" 2>/dev/null || echo "$HONE_SPEC_PATH")
TARGET_REAL=$(realpath "$TARGET_FILE" 2>/dev/null || echo "$TARGET_FILE")

if [ "$SPEC_REAL" = "$TARGET_REAL" ]; then
  echo '{"decision": "block", "reason": "Hone review in progress (Phase '"$HONE_PHASE"'). The spec cannot be edited during review. Use /hone-sharpen to apply repairs after the review is complete."}'
  exit 2
fi

exit 0
