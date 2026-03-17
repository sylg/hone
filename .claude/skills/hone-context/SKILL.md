---
name: hone-context
description: >
  Check if a spec contains enough context for a fresh agent to execute
  without asking clarifying questions. Finds missing file paths, undefined
  contracts, and absent rationale.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to check
    required: false
---

# Placeholder — Phase 3

Context completeness check. Read `hone` skill for voice, `hone/reference/context-completeness.md` for checklist.

Output: Completeness percentage + list of questions an implementer would need to ask.
