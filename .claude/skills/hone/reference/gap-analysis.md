# Gap Analysis

Find what's missing. Not what's wrong — what's absent.

## What to Look For

### Error Handling Gaps

#### P0 — Always check
- What happens when an API call fails? (timeout, 4xx, 5xx)
- What happens when a third-party service is unavailable?

#### P1 — Check for M+
- Is there a distinction between retryable and non-retryable errors?
- What happens when the user provides invalid input?
- Are error messages user-facing or internal-only? Is that specified?

#### P2 — Check for L+
- What happens when a database query fails? (connection lost, deadlock, constraint violation)
- What happens when the system runs out of resources? (disk, memory, connections)

### Edge Case Gaps

#### P0 — Always check
- What happens with empty inputs? (empty string, empty array, null, undefined)
- What happens with concurrent requests? (race conditions, double-submit)

#### P1 — Check for M+
- What happens with boundary values? (0, -1, MAX_INT, empty set)
- What happens during partial failure? (2 of 5 operations succeed)

#### P2 — Check for L+
- What happens with very large inputs? (10x, 100x expected size)
- What happens with very slow responses? (timeout behavior)

#### P3 — Check for XL only
- What happens when the user is unauthenticated mid-flow? (session expires)
- Is there idempotency where needed?

### Rollback & Recovery Gaps

#### P0 — Always check
- If step 3 of 5 fails, what happens to steps 1-2?

#### P1 — Check for M+
- Is there a rollback mechanism? Is it automatic or manual?
- Can the operation be safely retried?

#### P2 — Check for L+
- After a failure, what state is the system in? Is it consistent?
- Is there idempotency where needed?

### Contract Gaps

#### P1 — Check for M+
- Are API request/response schemas defined?
- Are error response formats specified?

#### P2 — Check for L+
- Are pagination parameters defined? (limit, offset, cursor)
- Are rate limits documented?
- Are authentication requirements specified per endpoint?
- Are content types specified? (JSON, form-data, multipart)

### Validation Gaps

#### P1 — Check for M+
- Are input validation rules specified? (length, format, range, type)
- What happens when validation fails? (error format, user experience)

#### P2 — Check for L+
- Is validation client-side, server-side, or both?
- Are there business rule validations beyond type checking?

### Observability Gaps

#### P2 — Check for L+
- Is logging specified? What events are logged?
- Are metrics defined? (counters, gauges, histograms)

#### P3 — Check for XL only
- Is there alerting criteria? What triggers a page?
- Is there a health check endpoint?
- How is the feature monitored in production?

### Security Gaps

#### P0 — Always check
- Are authentication requirements specified?
- Are authorization rules defined? (who can do what)

#### P1 — Check for M+
- Is input sanitization addressed? (XSS, SQL injection, path traversal)

#### P2 — Check for L+
- Are secrets managed properly? (not hardcoded, rotatable)
- Is data encryption specified? (at rest, in transit)

#### P3 — Check for XL only
- Are audit logs required?

### Data Gaps

#### P1 — Check for M+
- What's the data migration strategy?
- Is backward compatibility addressed? (old clients, old data)

#### P2 — Check for L+
- What's the data retention policy?

#### P3 — Check for XL only
- Is there a backup/restore strategy?
- What happens to existing data when the schema changes?

## How to Surface Gaps

Every gap found should be presented as a question, not a statement.

**Not this**: "The spec is missing error handling for the 429 case."

**This**: "What happens when the API returns a 429 rate limit response? The spec says 'call the API' but doesn't address rate limiting. This is a common failure mode for this type of integration. What's the expected behavior?"

The question format forces the developer to think about it, not just acknowledge it.

## Severity Assessment

| Severity | Criteria |
|----------|----------|
| **Critical** | Will cause data loss, security breach, or system outage if unaddressed |
| **High** | Will cause user-facing errors or broken workflows in production |
| **Medium** | Will cause degraded experience or require hotfix after launch |
| **Low** | Cosmetic or minor inconvenience, can be addressed post-launch |

## Output Format

For each gap found:

```
### 🪙 Gap: [Short title]

**Location**: [Which part of the spec]
**Question**: [T2] [The question that surfaces this gap]
**What's missing**: [Specific description of the gap]
**Risk if unaddressed**: [What goes wrong in production]
**Severity**: [Critical/High/Medium/Low]
**Suggested repair**: [Concrete addition to the spec]
```
