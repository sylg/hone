# Unknown Unknowns

This is the phase that justifies Hone's existence beyond what a human reviewer can do. A human reviewer catches what they know to look for. An LLM has seen 10,000 similar projects. It knows the failure modes that the developer hasn't encountered yet.

## Process

### Step 1: Domain Identification

Read the spec and identify which domain(s) it operates in. A spec can span multiple domains. Common domains:

| Domain | Signals in spec |
|--------|----------------|
| Authentication | login, session, token, JWT, OAuth, SSO, password, MFA |
| Authorization | roles, permissions, RBAC, ABAC, access control, admin |
| Payments | Stripe, billing, subscription, checkout, invoice, refund |
| File handling | upload, download, storage, S3, CDN, image processing |
| Email/messaging | SMTP, notification, webhook, queue, pub/sub |
| Search | index, Elasticsearch, full-text, ranking, relevance |
| Data pipeline | ETL, migration, import, export, batch processing |
| Real-time | WebSocket, SSE, polling, live update, presence |
| API design | REST, GraphQL, endpoint, versioning, rate limit |
| Database | schema, migration, query, index, ORM, SQL |
| Caching | Redis, Memcached, CDN, invalidation, TTL |
| Deployment | CI/CD, Docker, Kubernetes, rollback, blue-green |
| Frontend | SPA, SSR, hydration, state management, routing |
| Mobile | native, React Native, push notification, offline |
| ML/AI | model, training, inference, embedding, prompt |

### Step 2: Domain-Specific Failure Mode Recall

For each identified domain, recall the common failure modes that developers encounter in production but rarely think about during spec writing.

#### Authentication failure modes

- **Session fixation**: Attacker sets the session ID before the user logs in, then hijacks it after authentication
- **Algorithm confusion (JWT)**: Attacker switches from RS256 to HS256 using the public key as HMAC secret
- **Token storage**: Storing JWTs in localStorage exposes them to XSS; httpOnly cookies are safer but require CSRF protection
- **Password reset race condition**: Two password reset emails in flight — both tokens should be valid, but only the latest should work
- **Brute force on login**: Without rate limiting, attackers can try millions of password combinations
- **Session invalidation on password change**: Existing sessions should be revoked when password changes
- **OAuth state parameter**: Without CSRF protection via the state parameter, attackers can force logins to their own accounts
- **Refresh token rotation**: If a stolen refresh token is used, the server should detect reuse and revoke the entire family

#### Payments failure modes

- **Webhook replay attacks**: Without idempotency keys, a retried webhook processes the same event twice
- **Webhook signature verification**: Without verifying Stripe-Signature, anyone can forge webhook events
- **Race condition: redirect vs webhook**: User lands on success page before webhook confirms payment
- **Currency precision**: Using floats for money causes rounding errors — use integers (cents) or Decimal types
- **Subscription lifecycle gaps**: checkout.session.expired, payment_intent.payment_failed, customer.subscription.deleted are often missed
- **PCI compliance**: Touching raw card numbers puts you in PCI scope — use hosted forms/Checkout to stay out
- **Refund handling**: Partial refunds, double refunds, refund of already-cancelled subscriptions
- **Tax calculation**: Nexus rules, VAT for EU customers, sales tax by US state — gets complex fast
- **Dunning management**: What happens when a subscription payment fails? Retry logic, grace period, account suspension

#### File handling failure modes

- **ZIP bomb / decompression bomb**: A 42KB ZIP can expand to 4.5 PB and crash the server
- **Path traversal**: Filenames like `../../etc/passwd` can escape the upload directory
- **MIME type spoofing**: Checking file extension is not enough — verify magic bytes
- **Image processing DoS**: A specially crafted image can consume extreme memory during resize (pixel flood)
- **Storage cost explosion**: Without file size limits and quotas, storage costs grow unbounded
- **Orphaned files**: If the database record is deleted but the file isn't (or vice versa), you get orphans
- **CDN cache poisoning**: Cached files with wrong content types or headers can serve malicious content

#### Database / migration failure modes

- **Ghost rows during migration**: Rows created during migration may use old schema constraints
- **Lock contention**: ALTER TABLE on a large table can lock it for minutes, causing downtime
- **Backwards-incompatible migration**: Deploying new code that expects new schema before migration completes
- **N+1 queries**: ORM hides the fact that a loop generates 1000 individual queries
- **Connection pool exhaustion**: Long-running transactions hold connections, starving other requests
- **Charset mismatch**: Creating tables with latin1 when application sends UTF-8 causes mojibake
- **Missing indexes on foreign keys**: JOIN performance degrades dramatically without proper indexes

#### Real-time / WebSocket failure modes

- **Connection limit exhaustion**: Each WebSocket is a persistent connection — servers have limits
- **Reconnection thundering herd**: When server restarts, all clients reconnect simultaneously
- **Message ordering**: Messages can arrive out of order, especially during reconnection
- **Stale connections**: Connections that appear open but are actually dead (half-open)
- **Memory leak from event listeners**: Each connection adds listeners — forgetting to clean up causes leaks
- **Authentication on reconnect**: Token may have expired between disconnect and reconnect

#### API design failure modes

- **Pagination cursor invalidation**: If underlying data changes, offset-based pagination skips or duplicates items
- **Rate limiting across distributed systems**: Rate limiter works on one instance but not behind a load balancer
- **API versioning strategy**: Breaking changes without versioning forces all clients to update simultaneously
- **Unbounded list responses**: Without pagination limits, a single request can return millions of rows
- **CORS misconfiguration**: Wildcard origins in production expose the API to any domain
- **Content negotiation**: Not specifying Accept/Content-Type headers leads to format mismatches

#### Search failure modes

- **Accent folding**: Users searching "café" won't find "cafe" without Unicode normalization
- **Index drift**: Search index falls out of sync with primary database
- **Query injection**: User search terms interpreted as query syntax (Elasticsearch query DSL injection)
- **Relevance tuning**: Default relevance scoring rarely matches user expectations — needs tuning
- **Highlighting with HTML**: Search result highlighting can inject HTML if not escaped

#### Email / notification failure modes

- **Email deliverability**: Sending from a new domain without SPF/DKIM/DMARC goes straight to spam
- **Bounce handling**: Hard bounces should remove the address; soft bounces should retry
- **Notification fatigue**: Without frequency capping, users get overwhelmed and disable all notifications
- **Template injection**: User-controlled content in email templates can inject HTML/CSS
- **Timezone handling**: Scheduling notifications in "user's timezone" requires knowing their timezone

#### Frontend failure modes

- **Hydration mismatch**: Server-rendered HTML doesn't match client-rendered HTML, causing flicker
- **Bundle size creep**: Each new dependency adds to load time — tree-shaking doesn't always work
- **Memory leaks from subscriptions**: WebSocket, EventSource, or setInterval not cleaned up on unmount
- **Stale closure bugs**: React hooks capturing old state values in callbacks
- **Flash of unstyled content**: CSS-in-JS solutions can cause FOUC on initial load
- **Accessibility regressions**: Dynamic content updates not announced to screen readers

### Step 3: Cross-Reference with Spec

For each failure mode recalled:
1. Check if the spec addresses it (explicitly or implicitly)
2. If addressed → skip
3. If not addressed → present as T4 question

### Step 4: Present as Questions

Each unknown unknown is presented as a T4 question via `AskUserQuestion`:

```
AskUserQuestion({
  questions: [{
    header: "T4 Unknown [1/~5]",
    question: "JWT tokens are vulnerable to algorithm confusion attacks. An attacker can switch from RS256 to HS256, using your public key as the HMAC secret, and forge any token they want. Your spec doesn't pin the verification algorithm. Did you know about this?",
    options: [
      { label: "Add to spec", description: "Pin algorithm to RS256 in JWT verification config" },
      { label: "Out of scope for v1", description: "Accept risk — document as known vulnerability" },
      { label: "Need to research", description: "Add spike task to understand JWT security best practices" },
      { label: "Tell me more", description: "Explain this in more detail before I decide" }
    ],
    multiSelect: false
  }]
})
```

### Step 5: Process Responses

- **"Add to spec"** → Record as new task or constraint to add
- **"Out of scope for v1"** → Record as documented non-goal with risk acknowledgment
- **"Need to research"** → Record as spike/research task
- **"Tell me more"** → Explain in detail (2-3 paragraphs, concrete example, link to further reading if available), then re-ask the original question

## Output Format

For each unknown unknown surfaced:

```
🪙 ── Unknown: [Short title] ───────────────────────────────────────────

   📍  Domain: [which domain]
   ❓  [T4] [Question text]

   [2-3 sentence explanation of the failure mode]
   [Concrete example of what goes wrong]

   Developer response: [Add to spec / Out of scope / Research / Tell me more]

   Risk:     [████░░░░░░] [critical/high/medium/low]
   Action:   [What was decided]
─────────────────────────────────────────────────────────────────────────
```

## Scoring

Unknown unknowns are T4 questions (weight: 4x). They contribute heavily to the confidence score. A review that surfaces 4 unknown unknowns the developer didn't know about is categorically more valuable than one that only found gaps in what was already written.

Track:
- Total unknown unknowns surfaced
- How many the developer knew about vs. didn't
- How many were added to spec vs. deferred vs. out-of-scope
