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
- **Transaction boundary**: when an operation writes to multiple records, tables, or external services, does the spec state whether all writes must succeed atomically? Flag if partial failure (some writes succeed, some fail) is unaddressed — a silent partial update is often worse than a full rollback.

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
- **Permission boundary**: when the spec introduces a new endpoint, mutation, UI action, or data-access path, verify it explicitly states which roles/permission levels are allowed. Flag if the spec assumes new operations inherit permissions from adjacent routes or existing features without stating so — access control is not transitive. Ask: "Is there middleware, a gate check, or a policy rule that enforces this, and does the spec name it?"

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
- **State transition completeness**: when the spec introduces or modifies a status field or state machine (e.g., sync status, verification steps, booking states, modal/UI modes), verify it enumerates all valid transitions and terminal states, and states what happens on invalid or unexpected transitions. Flag if the spec describes only the happy-path transition without addressing intermediate states, stuck states, or failure states — incomplete state machines are a common source of edge-case bugs.

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

Read each statement in the spec. For each one, mentally construct the chain of requirements by routing to the relevant P0 check:

- **New endpoint, action, mutation, or data-access path?** → User P0: which roles are authorized, and is the enforcement mechanism (middleware, gate check, policy rule) named?
- **Status field, state machine, or multi-step flow?** → Ordering P0: are all transitions, failure states, and stuck states enumerated — not just the happy path?
- **Write, sync, or operation that can be retried or run concurrently?** → Data P0: is conflict resolution stated? is the operation safe to re-run without duplicating effects?
- **Operation that writes to multiple records, tables, or external services?** → Data P0: is atomicity required? is partial-failure behavior (some writes succeed, some fail) explicitly addressed?
- **Call to an external service, third-party API, or infrastructure dependency?** → Dependency P0: is the availability assumption stated, and what is the failure path if it's unavailable?
- **New config value, secret, feature flag, or environment variable?** → Environment P0: is it documented and confirmed available in all deployment environments (local, staging, production)?