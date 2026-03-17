# Migrate Authentication from Sessions to JWT

## Why
Our session-based auth doesn't scale across our new multi-service architecture. Services need to verify identity without hitting the auth database on every request.

## Current State
- Express.js with `express-session` and Redis session store
- Session cookie: `connect.sid`
- Session data stored in Redis with 24h TTL
- ~50 endpoints check `req.session.userId`
- 3 services share the Redis instance for session validation

## Target State
- JWT access tokens (15min TTL) + refresh tokens (7d TTL)
- Access tokens verified locally by each service (no Redis round-trip)
- Refresh tokens stored in database with rotation
- Gradual rollout behind feature flag

## Tasks

### 1. JWT infrastructure
Set up JWT signing/verification with RS256. Generate RSA key pair. Distribute public key to all services. Create shared `@app/auth` library.

### 2. Token endpoints
- POST `/api/auth/login` — returns access + refresh tokens
- POST `/api/auth/refresh` — rotates refresh token, returns new access token
- POST `/api/auth/logout` — revokes refresh token

### 3. Auth middleware migration
Create new JWT middleware that verifies access tokens. Run in parallel with session middleware during transition (check JWT first, fall back to session).

### 4. Client-side token management
Store access token in memory, refresh token in httpOnly cookie. Implement transparent refresh: when access token expires, use refresh token to get a new one before retrying the failed request.

### 5. Service-to-service auth
Services verify JWTs using the public key. No network call needed. Implement key rotation support (accept tokens signed by current or previous key).

### 6. Refresh token rotation
On each refresh, invalidate the old refresh token and issue a new one. If a revoked refresh token is used, invalidate the entire token family (potential theft detected).

### 7. Feature flag rollout
- Phase A: 1% of requests use JWT (monitor error rates)
- Phase B: 10% of requests (monitor latency)
- Phase C: 50% of requests (monitor Redis load reduction)
- Phase D: 100% of requests
- Phase E: Remove session middleware and Redis dependency

### 8. Migrate all 50 endpoints
Replace `req.session.userId` with `req.user.id` from JWT payload. Update tests.

### 9. Monitoring & alerting
Add metrics: token verification latency, refresh rate, revocation rate, auth errors by type. Alert on: auth error rate > 1%, refresh token reuse detected.

### 10. Rollback plan
Feature flag allows instant rollback to sessions. Keep Redis session store running for 30 days after 100% JWT rollout. Document rollback procedure.

## Success Criteria
- All services verify identity via JWT without Redis
- Token refresh is transparent to users
- Zero-downtime migration
- Rollback possible at any phase
