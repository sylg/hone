---
name: complexity
description: >
  Audit a spec for hidden complexity and underestimated risk. Finds tasks
  that are actually multiple tasks, glossed-over integration points, and
  architectural decisions buried in task descriptions.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to audit
    required: false
---

# Placeholder — Phase 3

Audit spec for hidden complexity. Read `hone` skill for voice, `hone/reference/complexity-audit.md` for checklist.

Present complexity findings as questions, not reports. For each complex area: "This task says [X] but actually requires [Y, Z, W]. Are you aware of that scope?"

Output: Complexity findings with suggested decomposition in Kintsugi format.
