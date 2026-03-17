---
name: unknowns
description: >
  Surface unknown unknowns — things the developer doesn't know they
  don't know. Uses broad domain knowledge to identify failure modes,
  security concerns, and gotchas common in the spec's domain.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to analyze
    required: false
---

# Placeholder — Phase 2

Unknown unknowns discovery. Read `hone` skill for voice, `hone/reference/unknown-unknowns.md` for methodology.

Process:
1. Identify the domain(s) the spec operates in
2. Recall common failure modes in those domains
3. Check each against the spec
4. Present unaddressed ones as T4 questions

For each: brief explanation, concrete example, ask "What do you want to do about this?"
