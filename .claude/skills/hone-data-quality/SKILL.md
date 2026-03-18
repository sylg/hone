---
name: hone-data-quality
description: >
  Review specs involving data models, schemas, migrations, and data-intensive
  features. Ensures data integrity, consistency, naming conventions,
  constraints, and migration safety are addressed.
user-invokable: true
args:
  - name: target
    description: File path or description of spec to review
    required: false
---

Data quality review. Optional composable dimension.

## Input

Accept a file path, conversation context, or pasted content. If no input, ask for it.

## Process

1. Read the `hone` skill for voice, visual identity, and output format
2. Read `hone/reference/data-quality.md` for the full checklist

## Behavior

**Open** with a styled phase header:

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 HONE ─ DATA QUALITY                                             │
╰───────────────────────────────────────────────────────────────────────╯
```

Check for:
- **Schema design** — naming, types, constraints, indexes
- **Relationships** — referential integrity, cardinality, delete behavior
- **Migration safety** — zero-downtime, backfill, rollback
- **Data consistency** — race conditions, eventual consistency, validation
- **Data lifecycle** — retention, archival, privacy/compliance

Ask questions using `AskUserQuestion`. Use the `header` field: `"T2 Data [N/M]"` or `"T3 Data [N/M]"`. Options should be contextual — e.g., "Add constraint", "Add migration step", "Already handled", "Need to research".

Display the schema review table from the reference file.

## Output

End with a dimension scorecard:

```
┌─ DATA QUALITY COMPLETE ───────────────────────────────────────────────┐
│  Tables affected: 3   Schema issues: 4   Migration gaps: 2            │
│  Missing constraints: 3   Missing indexes: 1   Privacy gaps: 1        │
│  Data quality score: ███░░░░░░░  35%                                   │
│  Questions: 6 asked, 5 answered                                        │
└───────────────────────────────────────────────────────────────────────┘
```
