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
| Calendar sync | Google Calendar, Outlook, CalDAV, iCal, bidirectional sync, recurring events, availability |
| Conferencing | WebRTC, video call, audio call, screen share, TURN, ICE, signaling, peer connection, media stream |

### Step 2: Domain-Specific Failure Mode Recall

For each identified domain, recall the common failure modes that developers encounter in production but rarely think about during spec writing.

#### Authentication failure modes

##### P0 — Always check
- **Algorithm confusion (JWT)**: Attacker switches from RS256 to HS256 using the public key as HMAC secret
- **Token storage**: Storing JWTs in localStorage exposes them to XSS; httpOnly cookies are safer but require CSRF protection

##### P1 — Check for M+
- **Session fixation**: Attacker sets the session ID before the user logs in, then hijacks it after authentication
- **Brute force on login**: Without rate limiting, attackers can try millions of password combinations
- **Session invalidation on password change**: Existing sessions should be revoked when password changes

##### P2 — Check for L+
- **Password reset race condition**: Two password reset emails in flight — both tokens should be valid, but only the latest should work
- **OAuth state parameter**: Without CSRF protection via the state parameter, attackers can force logins to their own accounts

##### P3 — Check for XL only
- **Refresh token rotation**: If a stolen refresh token is used, the server should detect reuse and revoke the entire family

#### Calendar sync failure modes

##### P0 — Always check
- **Bidirectional sync loop**: When event A is written to calendar B, a webhook from B triggers writing back to A, creating an infinite loop. Spec must describe how synced events are "fingerprinted" (e.g., `extendedProperties`, a custom `X-Source` field, or a `syncedEventId` DB column) so the sync engine can detect and skip events it already wrote.
- **Duplicate event creation**: If a webhook fires twice (retries) or a sync job runs concurrently, the same event gets created twice. Check whether the spec describes idempotency: upsert-by-external-ID rather than blind insert.
- **OAuth token expiry mid-sync**: Long-running sync jobs start with a valid token that expires before the job finishes. The spec should describe proactive token refresh (check `expiry_date` before each batch) and error recovery when a refresh fails (e.g., mark calendar disconnected, notify user).

##### P1 — Check for M+
- **Recurring event exceptions (RECURRENCE-ID / EXDATE)**: Modifications or cancellations of a single instance of a recurring event are represented differently in iCalendar (via `RECURRENCE-ID`) vs. Google Calendar API (`recurringEventId`). Missing this means edited instances revert to the master pattern on next sync.
- **Calendar API rate limits**: Google Calendar API has per-user (1M queries/day) and per-minute quotas; Outlook has similar. Bulk sync on reconnect can exhaust per-minute limits and cause 429 errors. The spec should describe exponential backoff or batch-friendly endpoints (e.g., `events.list` with `syncToken` rather than full re-fetch).
- **Timezone ambiguity on DST boundaries**: Events stored as wall-clock time ("9:00 AM") in a DST-observing timezone can shift by 1 hour after DST changes. All-day events must be stored as `DATE` (not `DATETIME`) to avoid timezone-induced date shifts.

##### P2 — Check for L+
- **Sync token invalidation**: Google Calendar `syncToken` becomes invalid after ~7 days of inactivity or after a full wipe — the API returns HTTP 410 Gone. The spec must handle this by falling back to full re-sync rather than failing silently.
- **Organizer vs. attendee write permissions**: A user can see an event they were invited to, but cannot modify it in the organizer's calendar. Attempting a write returns 403. Specs that sync "all visible events" often miss that attendee events are read-only.

#### Conferencing / WebRTC failure modes

##### P0 — Always check
- **TURN server absence for symmetric NAT**: ICE/STUN alone fails when both peers are behind symmetric NAT (common on mobile networks and corporate firewalls). Without a TURN relay, ~15–20% of calls will silently fail to connect. The spec must either reference a TURN provider (e.g., Twilio TURN, coturn) or acknowledge this as an accepted limitation.
- **Media permission revoked mid-session**: Users can revoke camera/microphone permissions via the browser OS-level prompt while a call is in progress. This fires a `devicechange` event and the track ends — the app must handle `track.onended` and display a recoverable error state rather than silently freezing the remote participant's view.

##### P1 — Check for M+
- **Signaling server as single point of failure**: If the WebSocket signaling channel drops after a peer connection is established, the call continues — but reconnection or new participants are blocked until the socket reconnects. The spec should describe reconnection strategy (exponential backoff, session resumption token) so in-progress calls survive transient server restarts.
- **Codec negotiation mismatch**: Browser support for H.264 hardware encoding varies by OS and GPU; VP8/VP9 are software-only on many devices. Mismatched SDP offers can result in a one-way video stream (audio works, video is black). The spec should define a preferred codec order and fallback.

##### P2 — Check for L+
- **Recording consent and storage compliance**: If the spec includes call recording, many jurisdictions (GDPR, CCPA, state wiretapping laws) require all-party consent before recording starts. Storing recordings in object storage without TTL or access controls is a compliance liability.

#### Payments failure modes

##### P0 — Always check
- **Webhook signature verification**: Without verifying Stripe-Signature, anyone can forge webhook events
- **Race condition: redirect vs webhook**: User lands on success page before webhook confirms payment
- **Currency precision**: Using floats for money causes rounding errors — use integers (cents) or Decimal types

##### P1 — Check for M+
- **Webhook replay attacks**: Without idempotency keys, a retried webhook processes the same event twice
- **Subscription lifecycle gaps**: checkout.session.expired, payment_intent.payment_failed, customer.subscription.deleted are often missed
- **PCI compliance**: Touching raw card numbers puts you in PCI scope — use hosted forms/Checkout to stay out

##### P2 — Check for L+
- **Refund handling**: Partial refunds, double refunds, refund of already-cancelled subscriptions
- **Dunning management**: What happens when a subscription payment fails? Retry logic, grace period, account suspension

##### P3 — Check for XL only
- **Tax calculation**: Nexus rules, VAT for EU customers, sales tax by US state — gets complex fast

#### File handling failure modes

##### P0 — Always check
- **Path traversal**: Filenames like `../../etc/passwd` can escape the upload directory
- **MIME type spoofing**: Checking file extension is not enough — verify magic bytes

##### P1 — Check for M+
- **ZIP bomb / decompression bomb**: A 42KB ZIP can expand to 4.5 PB and crash the server
- **Image processing DoS**: A specially crafted image can consume extreme memory during resize (pixel flood)
- **Storage cost explosion**: Without file size limits and quotas, storage costs grow unbounded

##### P2 — Check for L+
- **Orphaned files**: If the database record is deleted but the file isn't (or vice versa), you get orphans
- **CDN cache poisoning**: Cached files with wrong content types or headers can serve malicious content

#### Database / migration failure modes

##### P0 — Always check
- **Backwards-incompatible migration**: Deploying new code that expects new schema before migration completes
- **Lock contention**: ALTER TABLE on a large table can lock it for minutes, causing downtime

##### P1 — Check for M+
- **Missing state transition constraints**: Features that introduce a status or state field (e.g., invite: `pending → accepted → expired`; verification: `pending → verified → revoked`; fraud rule: `draft → active → disabled`; reset token: `active → used`) rarely specify which transitions are valid or where they are enforced. Without guards, an `accepted` invite can be re-accepted, or a `used` token reused. The spec should enumerate valid transitions for each status field and identify the enforcement layer: DB `CHECK` constraint, application-level guard function, or idempotent upsert. Also check whether orphaned records in intermediate states (e.g., an invite stuck in `processing` for > 1 hour) are handled.
- **Ghost rows during migration**: Rows created during migration may use old schema constraints
- **N+1 queries**: ORM hides the fact that a loop generates 1000 individual queries
- **Connection pool exhaustion**: Long-running transactions hold connections, starving other requests

##### P2 — Check for L+
- **Charset mismatch**: Creating tables with latin1 when application sends UTF-8 causes mojibake
- **Missing indexes on foreign keys**: JOIN performance degrades dramatically without proper indexes

#### Real-time / WebSocket failure modes

##### P0 — Always check
- **Connection limit exhaustion**: Each WebSocket is a persistent connection — servers have limits
- **Reconnection thundering herd**: When server restarts, all clients reconnect simultaneously

##### P1 — Check for M+
- **Message ordering**: Messages can arrive out of order, especially during reconnection
- **Stale connections**: Connections that appear open but are actually dead (half-open)

##### P2 — Check for L+
- **Memory leak from event listeners**: Each connection adds listeners — forgetting to clean up causes leaks
- **Authentication on reconnect**: Token may have expired between disconnect and reconnect

#### API design failure modes

##### P0 — Always check
- **Unbounded list responses**: Without pagination limits, a single request can return millions of rows
- **CORS misconfiguration**: Wildcard origins in production expose the API to any domain

##### P1 — Check for M+
- **Pagination cursor invalidation**: If underlying data changes, offset-based pagination skips or duplicates items
- **Rate limiting across distributed systems**: Rate limiter works on one instance but not behind a load balancer
- **API versioning strategy**: Breaking changes without versioning forces all clients to update simultaneously

##### P2 — Check for L+
- **Content negotiation**: Not specifying Accept/Content-Type headers leads to format mismatches

#### Search failure modes

##### P0 — Always check
- **Index drift**: Search index falls out of sync with primary database
- **Query injection**: User search terms interpreted as query syntax (Elasticsearch query DSL injection)

##### P1 — Check for M+
- **Accent folding**: Users searching "café" won't find "cafe" without Unicode normalization
- **Relevance tuning**: Default relevance scoring rarely matches user expectations — needs tuning

##### P2 — Check for L+
- **Highlighting with HTML**: Search result highlighting can inject HTML if not escaped

#### Email / notification failure modes

##### P0 — Always check
- **Email deliverability**: Sending from a new domain without SPF/DKIM/DMARC goes straight to spam
- **Bounce handling**: Hard bounces should remove the address; soft bounces should retry

##### P1 — Check for M+
- **Notification fatigue**: Without frequency capping, users get overwhelmed and disable all notifications
- **Template injection**: User-controlled content in email templates can inject HTML/CSS

##### P2 — Check for L+
- **Timezone handling**: Scheduling notifications in "user's timezone" requires knowing their timezone

#### Frontend failure modes

##### P0 — Always check
- **Hydration mismatch**: Server-rendered HTML doesn't match client-rendered HTML, causing flicker
- **Memory leaks from subscriptions**: WebSocket, EventSource, or setInterval not cleaned up on unmount

##### P1 — Check for M+
- **Bundle size creep**: Each new dependency adds to load time — tree-shaking doesn't always work
- **Stale closure bugs**: React hooks capturing old state values in callbacks

##### P2 — Check for L+
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