# Assumption Surfacing

For every statement in the spec, ask: "What must be true for this to work?" If the answer isn't stated in the spec, it's a hidden assumption.

## Assumption Categories

### Environment Assumptions

#### P0 — Always check
- Environment variables, configuration files, secrets availability

#### P1 — Check for M+
- Operating system, runtime version, available system resources
- Network connectivity, latency expectations, bandwidth

#### P2 — Check for L+
- File system permissions, disk space, directory structure
- Container/VM specs, orchestration platform capabilities

#### P3 — Check for XL only
- Geographic region, timezone, locale

### Data Assumptions

#### P0 — Always check
- Data shape, schema version, field presence/absence
- **Conflict resolution**: when two actors (users, systems, sync directions) modify the same record concurrently, what wins? Is this stated? (Last-write-wins? Server-authoritative? Manual resolution?) Flag if the spec treats writes as non-conflicting without justification.
- **Idempotency**: can each operation (API call, sync step, webhook handler, migration) be safely retried or re-run without duplicating effects? If the spec doesn't guarantee idempotency for operations that can fail mid-flight, flag it as a reliability gap.
- **Partial failure state**: if a multi-step operation (spanning multiple API calls, DB writes, or service boundaries) fails at step N, does the spec describe the resulting system state? Flag specs that implicitly assume all-or-nothing atomicity where none exists — partial completion commonly leaves records inconsistent, events unfired, or UI out of sync with backend state.

#### P1 — Check for M+
- Data volume (current and projected growth)
- Data freshness (real-time? eventual consistency? stale OK?)
- Null/empty handling (fields always present? optional?)

#### P2 — Check for L+
- Data quality (always valid? needs cleaning? mixed formats?)
- Character encoding (UTF-8 everywhere? legacy encodings?)
- Data ownership (who can read/write/delete?)

### Dependency Assumptions

#### P0 — Always check
- Third-party service availability and SLA

#### P1 — Check for M+
- Library/framework version and API stability
- Internal service availability and response time

#### P2 — Check for L+
- Database engine capabilities and version-specific features
- Browser/client capabilities (JavaScript enabled? modern CSS? WebSocket support?)
- Package registry availability (npm, PyPI, etc.)

### User Assumptions

#### P0 — Always check
- Permission level (admin? regular user? anonymous?)

#### P1 — Check for M+
- User behavior (follows happy path? tries to break things?)
- Input patterns (valid format? reasonable length? correct encoding?)

#### P2 — Check for L+
- Usage volume (concurrent users, request frequency)
- Device capabilities (screen size, processing power, network speed)

#### P3 — Check for XL only
- Technical literacy (understands error messages? can troubleshoot?)

### Ordering Assumptions

#### P0 — Always check
- Implicit sequencing not stated ("obviously X runs before Y")

#### P1 — Check for M+
- Setup/prerequisite steps assumed to be done

#### P2 — Check for L+
- Migration ordering (schema first? data first? code first?)
- Deployment ordering (backend before frontend? feature flag first?)
- Initialization ordering (database seeded? cache warmed? config loaded?)

### Performance Assumptions

#### P1 — Check for M+
- Response time expectations ("this will be fast")

#### P2 — Check for L+
- Throughput capacity ("the database can handle it")
- Scaling behavior ("it'll scale horizontally")

#### P3 — Check for XL only
- Resource consumption ("it won't use much memory")
- Cost assumptions ("this won't be expensive")

## How to Surface Assumptions

Read each statement in the spec. For each one, mentally construct the chain of requirements: