---
name: hone-unknowns
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

Surface unknown unknowns in a spec/plan. Knowledge expansion dimension.

## Input

Accept a file path, conversation context, or pasted content. If no input, ask for it.

## Process

1. Read the `hone` skill for voice, visual identity, and output format
2. Read `hone/reference/unknown-unknowns.md` for the full methodology

## Behavior

**Open** with a styled phase header:

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 HONE ─ UNKNOWN UNKNOWNS                                         │
╰───────────────────────────────────────────────────────────────────────╯
```

Follow the 5-step process from the reference file:

1. **Identify domains** — What kind of system is this? Auth, payments, file handling, etc. Display the detected domains.
2. **Recall failure modes** — For each domain, recall common production failure modes from the reference file's domain-specific lists.
3. **Cross-reference** — Check each failure mode against the spec. Skip any that are already addressed.
4. **Present as T4 questions** — Use `AskUserQuestion` for each unaddressed failure mode. Use the `header` field: `"T4 Unknown [1/~5]"`. Options: "Add to spec", "Out of scope for v1", "Need to research", "Tell me more".
5. **Process responses** — Record each decision. If "Tell me more", explain in detail then re-ask.

Apply the risky answer pushback from the `hone` skill when critical risks are dismissed.

## Output

After the interactive Q&A, produce findings using the standard findings format:

```
🪙 ── Unknown: [Short title] ───────────────────────────────────────────

   📍  Domain: [which domain]
   ❓  [T4] [Question text]

   [2-3 sentence explanation]
   [Concrete example of what goes wrong]

   Developer response: [Add to spec / Out of scope / Research]

   Risk:     [████░░░░░░] [critical/high/medium/low]
   Action:   [What was decided]
─────────────────────────────────────────────────────────────────────────
```

End with a dimension scorecard:

```
┌─ UNKNOWN UNKNOWNS COMPLETE ───────────────────────────────────────────┐
│  Domains identified: 3   Unknowns surfaced: 5                         │
│  Added to spec: 2   Out of scope: 1   Research: 2                     │
│  Developer already knew: 1   New to developer: 4                      │
└───────────────────────────────────────────────────────────────────────┘
```
