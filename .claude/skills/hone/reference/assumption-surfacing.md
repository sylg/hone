# Assumption Surfacing

For every statement in the spec, ask: "What must be true for this to work?" If the answer isn't stated in the spec, it's a hidden assumption.

## Assumption Categories

### Environment Assumptions
- Operating system, runtime version, available system resources
- Network connectivity, latency expectations, bandwidth
- File system permissions, disk space, directory structure
- Environment variables, configuration files, secrets availability
- Container/VM specs, orchestration platform capabilities
- Geographic region, timezone, locale

### Data Assumptions
- Data shape, schema version, field presence/absence
- Data volume (current and projected growth)
- Data freshness (real-time? eventual consistency? stale OK?)
- Data quality (always valid? needs cleaning? mixed formats?)
- Character encoding (UTF-8 everywhere? legacy encodings?)
- Null/empty handling (fields always present? optional?)
- Data ownership (who can read/write/delete?)

### Dependency Assumptions
- Library/framework version and API stability
- Third-party service availability and SLA
- Internal service availability and response time
- Database engine capabilities and version-specific features
- Browser/client capabilities (JavaScript enabled? modern CSS? WebSocket support?)
- Package registry availability (npm, PyPI, etc.)

### User Assumptions
- User behavior (follows happy path? tries to break things?)
- Input patterns (valid format? reasonable length? correct encoding?)
- Permission level (admin? regular user? anonymous?)
- Device capabilities (screen size, processing power, network speed)
- Technical literacy (understands error messages? can troubleshoot?)
- Usage volume (concurrent users, request frequency)

### Ordering Assumptions
- Implicit sequencing not stated ("obviously X runs before Y")
- Setup/prerequisite steps assumed to be done
- Migration ordering (schema first? data first? code first?)
- Deployment ordering (backend before frontend? feature flag first?)
- Initialization ordering (database seeded? cache warmed? config loaded?)

### Performance Assumptions
- Response time expectations ("this will be fast")
- Throughput capacity ("the database can handle it")
- Scaling behavior ("it'll scale horizontally")
- Resource consumption ("it won't use much memory")
- Cost assumptions ("this won't be expensive")

## How to Surface Assumptions

Read each statement in the spec. For each one, mentally construct the chain of requirements:

```
Spec says: "Query the user's order history"

Hidden assumptions:
- User is authenticated (how?)
- User has an order history (what if new user?)
- Order history is in a queryable format (indexed? which database?)
- Query will return in reasonable time (how many orders? pagination?)
- Results fit in memory (max result set size?)
- User can only see their own orders (authorization checked where?)
```

### Present Each Assumption

Tag assumptions as [STATED] or [UNSTATED]:

```
[STATED] Users authenticate via JWT token — spec section 2.1
[UNSTATED] JWT token is validated on every request, not just at session start
[UNSTATED] Token refresh happens transparently to the user
[UNSTATED] Expired tokens return 401, not 403
```

### Ask, Don't Tell

For each unstated assumption, ask the developer to confirm or deny:

"The spec assumes [X]. Is that correct? If not, what's the actual constraint?"

This gives the developer a chance to:
1. Confirm it (now it's stated, not assumed)
2. Deny it (now we've found a real gap)
3. Say "I don't know" (now we've found an unknown)

## Severity of Assumptions

| Impact if assumption is wrong | Severity |
|------|----------|
| Spec still works, minor adjustment needed | Low |
| Feature works differently than intended | Medium |
| Feature breaks in production | High |
| Security vulnerability or data loss | Critical |

## Output Format

```
### 🪙 Assumption: [Short title]

**Location**: [Which statement in the spec]
**The assumption**: [What must be true for this to work]
**Status**: [STATED / UNSTATED]
**Question**: [T3] [Question to the developer]
**If wrong**: [What breaks if this assumption is false]
**Severity**: [Critical/High/Medium/Low]
**Suggested repair**: [How to make this explicit in the spec]
```
