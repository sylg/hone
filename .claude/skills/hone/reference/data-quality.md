# Data Quality Review

Review specs involving data models, schemas, migrations, ERDs, and data-intensive features. Ensure data integrity, consistency, and correctness are addressed.

## When to Recommend

This dimension is relevant when the spec involves:
- Database schema changes (new tables, columns, constraints)
- Data migrations (transforming existing data)
- ERD / data model design
- API contracts with structured data
- Import/export features
- Reporting or analytics features
- Search indexing
- Cache strategies with data consistency requirements

## What to Check

### Schema Design

#### Naming Conventions
- Are table/column names consistent? (snake_case vs camelCase)
- Are naming conventions stated or implied?
- Are names descriptive? (`status` is ambiguous — status of what?)
- Are boolean columns named as questions? (`is_active`, `has_paid`)

#### Data Types
- Are types appropriate? (string for email vs dedicated email type/constraint)
- Are numeric types correct? (integer for money is wrong — use decimal/cents)
- Are dates stored with timezone? (timestamp vs timestamptz)
- Are enums used for fixed sets? (status: 'active'|'inactive' vs free-text string)
- Are UUIDs vs auto-increment IDs chosen deliberately?

#### Constraints
- Are NOT NULL constraints specified for required fields?
- Are UNIQUE constraints specified where needed? (email, username, slug)
- Are CHECK constraints specified for value ranges? (price > 0, rating 1-5)
- Are DEFAULT values specified where appropriate?
- Are foreign key constraints defined?

#### Indexes
- Are indexes specified for frequently queried columns?
- Are composite indexes in the right column order?
- Are indexes specified for foreign keys? (not auto-created in all databases)
- Is there a unique index for natural keys?

**Question pattern**: "The spec adds a `status` column but doesn't specify the allowed values, default, or index. What are the valid statuses? Should it be an enum?"

### Relationships & Integrity

#### Referential Integrity
- Are foreign key relationships defined?
- What happens on parent deletion? (CASCADE, SET NULL, RESTRICT)
- Are orphan records possible?
- Are circular references handled?

#### Cardinality
- Is the relationship cardinality stated? (one-to-one, one-to-many, many-to-many)
- Are junction/join tables needed for many-to-many?
- Is the cardinality correct? (a user has one avatar vs many avatars)

#### Soft Delete vs Hard Delete
- Are records deleted or soft-deleted?
- If soft-deleted, do queries filter by `deleted_at IS NULL`?
- Can soft-deleted records be restored?
- Do unique constraints account for soft-deleted records?

**Question pattern**: "When a team is deleted (Task [N]), what happens to its members and their data? CASCADE deletes everything, SET NULL orphans the records. Which is intended?"

### Migration Safety

#### Zero-Downtime Migrations
- Can the migration run while the application is serving traffic?
- Does the migration require a maintenance window?
- Are backwards-incompatible changes split into safe steps?
  - Step 1: Add new column (nullable)
  - Step 2: Backfill data
  - Step 3: Update code to use new column
  - Step 4: Make column NOT NULL
  - Step 5: Drop old column

#### Data Backfill
- Is existing data transformed correctly?
- What happens to rows that don't match the new constraints?
- Is the backfill idempotent? (safe to re-run)
- How long does the backfill take? (minutes vs hours)

#### Rollback
- Can the migration be rolled back?
- Is data loss possible during rollback?
- Is there a point of no return?

**Question pattern**: "Task [N] adds a NOT NULL column. What value do existing rows get? Is there a backfill step, and what happens to rows where the value is unknown?"

### Data Consistency

#### Race Conditions
- Can concurrent requests create inconsistent data? (double booking, double spend)
- Are database transactions used for multi-step operations?
- Is optimistic or pessimistic locking needed?
- Are uniqueness checks atomic? (check-then-insert has a race window)

#### Eventual Consistency
- If using caching, how stale can data be?
- If using read replicas, is replication lag acceptable?
- If using event-driven updates, what happens during the inconsistency window?
- Are there user-facing consequences of stale data?

#### Data Validation
- Is validation in the application, database, or both?
- Can the database contain data that the application considers invalid?
- Are validation rules the same in all write paths? (API, admin panel, migration, seed)

**Question pattern**: "Two users can create a team with the same name simultaneously. Is there a unique constraint on team name, or is duplicate naming intentional?"

### Data Lifecycle

#### Retention
- How long is data kept? (forever? 90 days? until account deletion?)
- Is there a data retention policy required by regulation? (GDPR, CCPA)
- Are audit logs retained separately from operational data?

#### Archival
- Is old data archived or deleted?
- Can archived data be restored?
- Does archival affect query performance?

#### Privacy & Compliance
- Is PII identified and labeled?
- Can user data be exported? (GDPR right of access)
- Can user data be deleted? (GDPR right to erasure)
- Are there fields that need encryption at rest?
- Is there an audit trail for sensitive data access?

**Question pattern**: "The spec stores user payment information. Is this PII? Does it need encryption at rest? What happens when a user requests data deletion?"

## Output Format

### Schema Review Table

```
╭───────────────────────────────────────────────────────────────────────╮
│  🪙 DATA QUALITY REVIEW                                              │
│                                                                       │
│  Tables affected: 3 (teams, team_memberships, roles)                  │
│                                                                       │
│  Naming        ✅  Consistent snake_case                              │
│  Types         🟡  `status` should be enum, not varchar               │
│  Constraints   ❌  Missing: NOT NULL on role, UNIQUE on team name     │
│  Indexes       ❌  Missing: index on team_memberships.user_id         │
│  Relationships 🟡  CASCADE vs SET NULL not specified                  │
│  Migration     ❌  No backfill strategy for existing users            │
│  Consistency   🟡  No locking for concurrent team creation            │
│  Privacy       ❌  PII not identified                                 │
│                                                                       │
│  Data quality score: ███░░░░░░░  35%                                  │
╰───────────────────────────────────────────────────────────────────────╯
```

### Individual Findings

```
🪙 ── Data: [Short title] ──────────────────────────────────────────────

   📍  [Which table/column/migration]
   ❓  [T2 or T3] [Question about data quality]

   [Description of the data quality concern]

   ⚠  RISK:  [Data corruption / inconsistency / compliance violation]
   🔧 FIX:   [Specific schema change, constraint, or migration step]

   Severity: [████░░░░░░] [LEVEL]
─────────────────────────────────────────────────────────────────────────
```
