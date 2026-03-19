#!/bin/bash
# Save a Hone review report to the reports directory.
# Input: spec name as argument, report content via stdin
# Output: the file path where the report was saved

set -euo pipefail

SPEC_NAME="${1:?Usage: save-report.sh <spec-name> < report-content}"
CONFIG_DIR="${2:-.hone/reports}"

DATE=$(date +%Y-%m-%d)

# Sanitize spec name for filename
SAFE_NAME=$(echo "$SPEC_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

mkdir -p "$CONFIG_DIR"

FILEPATH="$CONFIG_DIR/$DATE-$SAFE_NAME-review.md"

cat > "$FILEPATH"

echo "$FILEPATH"
