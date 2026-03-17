# Gap Analysis

Find what's missing. Not what's wrong — what's absent.

## What to Look For

### Error Handling Gaps
- What happens when an API call fails? (timeout, 4xx, 5xx)
- What happens when a database query fails? (connection lost, deadlock, constraint violation)
- What happens when a third-party service is unavailable?
- What happens when the user provides invalid input?
- What happens when the system runs out of resources? (disk, memory, connections)
- Is there a distinction between retryable and non-retryable errors?
- Are error messages user-facing or internal-only? Is that specified?

### Edge Case Gaps
- What happens with empty inputs? (empty string, empty array, null, undefined)
- What happens with boundary values? (0, -1, MAX_INT, empty set)
- What happens with concurrent requests? (race conditions, double-submit)
- What happens with very large inputs? (10x, 100x expected size)
- What happens with very slow responses? (timeout behavior)
- What happens when the user is unauthenticated mid-flow? (session expires)
- What happens during partial failure? (2 of 5 operations succeed)

### Rollback & Recovery Gaps
- If step 3 of 5 fails, what happens to steps 1-2?
- Is there a rollback mechanism? Is it automatic or manual?
- After a failure, what state is the system in? Is it consistent?
- Can the operation be safely retried?
- Is there idempotency where needed?

### Contract Gaps
- Are API request/response schemas defined?
- Are error response formats specified?
- Are pagination parameters defined? (limit, offset, cursor)
- Are rate limits documented?
- Are authentication requirements specified per endpoint?
- Are content types specified? (JSON, form-data, multipart)

### Validation Gaps
- Are input validation rules specified? (length, format, range, type)
- Is validation client-side, server-side, or both?
- What happens when validation fails? (error format, user experience)
- Are there business rule validations beyond type checking?

### Observability Gaps
- Is logging specified? What events are logged?
- Are metrics defined? (counters, gauges, histograms)
- Is there alerting criteria? What triggers a page?
- Is there a health check endpoint?
- How is the feature monitored in production?

### Security Gaps
- Are authentication requirements specified?
- Are authorization rules defined? (who can do what)
- Is input sanitization addressed? (XSS, SQL injection, path traversal)
- Are secrets managed properly? (not hardcoded, rotatable)
- Is data encryption specified? (at rest, in transit)
- Are audit logs required?

### Data Gaps
- What's the data migration strategy?
- Is backward compatibility addressed? (old clients, old data)
- What's the data retention policy?
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
