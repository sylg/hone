#!/bin/bash
# Generate a unified diff between original and sharpened spec.
# Input: original spec path, sharpened spec path
# Output: unified diff (exits 0 regardless of whether files differ)

set -uo pipefail

ORIGINAL="${1:?Usage: diff-spec.sh <original> <sharpened>}"
SHARPENED="${2:?Usage: diff-spec.sh <original> <sharpened>}"

if [ ! -f "$ORIGINAL" ]; then
  echo "Error: Original file not found: $ORIGINAL" >&2
  exit 1
fi

if [ ! -f "$SHARPENED" ]; then
  echo "Error: Sharpened file not found: $SHARPENED" >&2
  exit 1
fi

diff -u "$ORIGINAL" "$SHARPENED" || true
