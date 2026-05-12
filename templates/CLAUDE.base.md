# Engineering Standards

> Installed by [forge](https://github.com/Malodeity/forge). Run `npx forge update` to upgrade.

## Philosophy
- Correctness > performance > elegance — in that order, always
- Every abstraction must reduce net complexity; if it doesn't, delete it
- Explicit over implicit; boring over clever; simple over novel
- Build for the reader, not the writer
- YAGNI — build what's needed now, defer generalization until the third occurrence

---

## Architecture Decision Framework

| Pattern | Use When | Skip When |
|---|---|---|
| **Clean Architecture** | Complex domain, system lives >3 years, multiple teams | Simple CRUD, scripts, short-lived tools |
| **Hexagonal (Ports & Adapters)** | Multiple I/O adapters, high testability required | Single adapter, simple apps |
| **Domain-Driven Design** | Rich domain logic, multiple bounded contexts | Simple domains, data-centric apps |
| **CQRS** | Read/write asymmetry >5:1, complex projections, scaling mismatch | Simple models, low traffic |
| **Event Sourcing** | Audit trail required, temporal queries, event replay needed | Simple state, no history requirements |
| **Microservices** | Independent deploys critical, teams >8, >10K rps per service | Greenfield, <5 engineers, shared DB |
| **Monolith-first** | Greenfield, single team, <50K rps total | Legacy with separate release cycles |
| **Event-driven** | Loose coupling, async acceptable, fan-out patterns | Strong consistency required |
| **BFF (Backend for Frontend)** | Multiple clients with divergent data shapes | Single client, uniform API |

### Bounded Context Rules
- Each bounded context owns its data — no cross-context DB joins
- Communicate across contexts via events or anti-corruption layer (ACL)
- Shared kernel only for stable, low-churn domain concepts
- Ubiquitous language per context — the same word can mean different things in different contexts

---

## System Design Patterns

### Resilience
- **Circuit breaker**: open after N failures, half-open probe, close after M successes — never skip on internal services
- **Bulkhead**: separate thread/connection pools per downstream — one slow dependency cannot starve others
- **Retry with jitter**: `min(cap, base × 2^attempt) + random(0, jitter)` — always add jitter to prevent thundering herd
- **Timeout**: set at every network call — no call without a deadline, no exceptions
- **Idempotency**: assign idempotency keys at the client boundary; deduplicate on the server by key

### Data Consistency
- **Outbox pattern**: write domain event to DB in the same transaction as state change → async relay to broker
- **Saga (choreography)**: each service emits events, downstream reacts — use for simple, linear flows
- **Saga (orchestration)**: central coordinator emits commands — use for complex flows needing visibility
- **Compensating transactions**: always define the compensation for every Saga step before implementing the step
- **Eventual consistency**: acceptable for read replicas, caches, search indexes — never for financial state

### Scalability
- **Consistent hashing**: for cache/shard distribution — minimizes key movement on node changes
- **Sharding key**: choose based on access pattern cardinality — avoid monotonic keys (hotspot) and low-cardinality keys
- **Read replicas**: route reads to replicas, writes to primary — use read-your-writes consistency where needed
- **Rate limiting**: token bucket for burst tolerance; leaky bucket for steady throughput — apply at gateway + service
- **Backpressure**: queues must have bounded capacity with explicit rejection — unbounded queues hide overload

### Caching
| Strategy | When | Invalidation |
|---|---|---|
| Cache-aside (lazy) | General reads, tolerate slight staleness | TTL + explicit evict on write |
| Write-through | Read-heavy, freshness critical | Synchronous write |
| Write-behind | Write-heavy, eventual consistency OK | Async background flush |
| Read-through | Transparent to caller | TTL managed by cache |
| Refresh-ahead | Predictable access patterns, low latency required | Proactive refresh before TTL |

- Cache stampede protection: probabilistic early expiry or mutex-based refresh
- Monitor hit rate — below 80% signals wrong key design or TTL mismatch
- Never cache authentication or authorization decisions longer than token TTL

---

## Data Engineering

### Schema Design
- **Immutable events first** — append-only event log; derive all state as projections
- **Surrogate keys** — UUIDs (v7 for sortability) over auto-increment in distributed systems
- **Soft deletes** — `deleted_at TIMESTAMP NULL`; hard delete only when compliance mandates
- **Temporal tables** — `valid_from`, `valid_to` for slowly changing dimensions (SCD Type 2)
- **Schema evolution** — additive changes only; never rename or drop columns in-place; use migrations

### Indexing
- Composite index column order: equality predicates → range predicates → sort columns
- Covering indexes for hot queries — include all projected columns to avoid heap fetch
- Partial indexes for sparse predicates: `WHERE deleted_at IS NULL`, `WHERE status = 'active'`
- Monitor index bloat and unused indexes — unused indexes cost write performance for free

### Pipelines
| Paradigm | When | Pattern |
|---|---|---|
| **ETL** | Legacy systems, on-prem, low data volume | Extract → Transform → Load |
| **ELT** | Cloud warehouse, raw storage cheap | Extract → Load raw → Transform in-warehouse |
| **Streaming** | Sub-minute latency required | Event → Process → Sink (Kafka/Flink) |
| **Lambda** | Both batch accuracy and stream speed needed | Batch layer + speed layer + serving layer |
| **Kappa** | Streaming sufficient for all queries | Single stream processing layer |

- **Idempotent pipelines**: same input always produces same output — use upsert, not insert
- **Watermarking**: track progress in a checkpoint table — not in-memory state
- **Data contracts**: producers own schema; consumers validate at ingestion boundary
- **Schema registry**: enforce Avro/Protobuf schema compatibility before publish

### Data Warehouse
- **Medallion architecture**: Bronze (raw) → Silver (cleaned/typed) → Gold (aggregated/business-ready)
- **Fact table grain**: define explicitly — one row per what? Never mix grains in one table
- **SCD Type 2**: new row per change with `valid_from`/`valid_to` — always prefer over in-place update
- **Star schema**: facts with FK to dimensions — optimized for OLAP query patterns
- **Partition pruning**: partition large tables by date; queries must always include partition predicate

---

## AI/ML Engineering

### Feature Engineering
- **Feature store**: decouple feature computation from training and serving — one definition, two uses
- **Point-in-time joins**: use only features available at prediction time — no future leakage
- **Feature versioning**: features are code — version, test, monitor, and deprecate them deliberately
- **Embedding caching**: cache embeddings for stable inputs (product descriptions, articles) — never recompute at query time

### Model Serving
| Mode | When | Notes |
|---|---|---|
| **Batch** | Non-latency sensitive, high volume | Nightly/hourly, write to feature store |
| **Real-time sync** | <100ms SLA, low volume | Model as microservice |
| **Real-time async** | <1s SLA, high volume | Queue → worker → result store |
| **Shadow mode** | Validating new model | Run alongside prod, compare, no user impact |
| **Canary** | Gradual rollout | Route N% of traffic, monitor, expand or rollback |

### RAG Architecture
- **Chunking**: semantic/paragraph chunking > fixed-size for accuracy; fixed-size for throughput
- **Embedding consistency**: use identical model at index time and query time — mixing models silently degrades recall
- **Hybrid retrieval**: dense (vector) + sparse (BM25) retrieval outperforms either alone
- **Cross-encoder reranking**: rerank top-K retrieval results before passing to LLM — measurably improves relevance
- **Context budget**: score, rank, and trim chunks to fit within context window; most relevant first
- **Chunked vs full-doc**: store both chunk embedding and full-doc reference — retrieve chunks, return doc context

### Prompt Engineering
- System prompt structure: `[Role] + [Constraints] + [Output format]` — no prose, no fluff
- Structured output: always request JSON schema; validate schema before parsing
- Few-shot: 3-5 diverse, representative examples — cover edge cases, not just happy path
- Chain-of-thought: prepend "think step by step" for reasoning; omit for classification/extraction
- Temperature: `0.0` for deterministic tasks; `0.7–1.0` for generation; never >1.0 in production
- Token budget: estimate input tokens before sending — fail fast on oversized inputs

### ML Evaluation & Operations
- **Offline eval**: establish baseline (accuracy, F1, latency, cost) before any deployment
- **Online eval**: log predictions + ground truth → compute production metrics continuously
- **Data drift**: monitor input distributions (KL divergence, PSI) — alert on drift >threshold
- **Concept drift**: monitor prediction distribution + downstream business metrics
- **Retraining trigger**: scheduled (weekly baseline) + event-driven (drift detected)

---

## Security

### Threat Model (STRIDE per component)
- **Spoofing**: authenticate every request — no implicit trust between services in same network
- **Tampering**: sign payloads at boundaries; verify checksums on file/event ingestion
- **Repudiation**: immutable append-only audit log for all state-changing operations
- **Information disclosure**: least-privilege DB credentials; no secrets in logs, errors, or responses
- **Denial of service**: rate limiting + circuit breakers on all public and internal endpoints
- **Elevation of privilege**: enforce authorization at every layer — not just the edge gateway

### Security Standards
- **Zero trust**: authenticate + authorize every request regardless of network origin or caller identity
- **Secrets management**: vault (HashiCorp Vault / AWS Secrets Manager / GCP Secret Manager) — never `.env` files in repo
- **Input validation**: validate at every system boundary — type, length, format, range, encoding
- **Output encoding**: context-specific (HTML encode for HTML, parameterize for SQL, escape for shell)
- **SQL**: parameterized queries / prepared statements only — string concatenation is never acceptable
- **Dependency scanning**: pin versions; run `npm audit` / `pip-audit` / `trivy` in CI; patch monthly

### OWASP Top 10 Checklist
1. **Broken access control** → every endpoint has explicit authz check, not just authn
2. **Cryptographic failures** → TLS 1.2+ everywhere; bcrypt/argon2 for passwords; AES-256 at rest
3. **Injection** → parameterized queries; no `eval`; no shell commands from user input
4. **Insecure design** → threat model before implementing security-sensitive features
5. **Security misconfiguration** → no default credentials; suppress verbose errors in prod; set security headers
6. **Vulnerable components** → automated scanning in CI + dependency update PRs
7. **Auth failures** → MFA; account lockout; short JWT TTL; secure session management
8. **Software integrity** → verify supply chain; SBOM; signed packages; no `curl | bash` in prod pipelines
9. **Logging gaps** → log authn events, authz failures, input validation failures with context
10. **SSRF** → allowlist outbound destinations; block RFC-1918 ranges from user-supplied URLs

---

## Observability

### Structured Logging Format
```json
{
  "ts": "2026-01-01T00:00:00.000Z",
  "level": "INFO",
  "service": "orders-api",
  "version": "1.4.2",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "msg": "order.created",
  "order_id": "ord_abc123",
  "user_id": "usr_xyz789",
  "duration_ms": 47
}
```
- Always include: `ts`, `level`, `service`, `trace_id`, `msg`
- Never log: passwords, tokens, full card numbers, PII fields, full request bodies
- Log at boundaries: incoming request, outgoing call result, DB query (with `duration_ms`)
- Log levels: DEBUG (dev only), INFO (business events), WARN (degraded, recoverable), ERROR (requires action)

### Distributed Tracing
- Propagate `traceparent` header (W3C Trace Context) across all service calls — no custom headers
- Create spans for: HTTP calls, DB queries, cache ops, queue publish/consume, LLM calls
- Span attributes: resource IDs, operation name, HTTP status, DB table, error type
- Sampling: 100% for errors; 10% for success in high-volume paths; 100% for P99 tail latency analysis

### Metrics (RED per service + USE per resource)
- **Rate**: requests/sec per endpoint, per status code family
- **Errors**: error rate (4xx client errors vs 5xx server errors separately)
- **Duration**: P50 / P95 / P99 latency — alert on P99, never on average
- **Utilization**: CPU%, memory%, connection pool saturation
- **Saturation**: queue depth, thread pool queue length, DB connection wait time
- **Errors (infra)**: disk errors, packet loss, OOM kills

### SLO Template
```yaml
name: api-availability
target: 99.9%         # 43.8 min/month error budget
window: 30d
good_events: http_requests{status!~"5.."}
total_events: http_requests
alert:
  - window: 1h
    burn_rate: 14.4x  # Page immediately — consumes 2% budget in 1h
  - window: 6h
    burn_rate: 6x     # Ticket — worth investigating
```

---

## Testing Strategy

| Layer | Scope | Tools | Target coverage |
|---|---|---|---|
| **Unit** | Pure functions, domain logic, algorithms | pytest, jest, vitest | 80%+ of domain |
| **Integration** | DB, external adapters, cache, queues | testcontainers, supertest | All adapters |
| **Contract** | API schema between producer/consumer | pact, schemathesis | All service boundaries |
| **E2E** | Critical user journeys only (3–5 paths) | playwright, cypress | Golden paths |
| **Load** | Throughput, latency under sustained load | k6, locust | Before every release |
| **Chaos** | Resilience: kill deps, inject latency, partition | toxiproxy, chaos-mesh | Quarterly |

### Testing Rules
- Test behavior, not implementation — tests must survive refactors without changes
- One logical assertion per test — failure message must point to the exact problem
- Arrange → Act → Assert — explicit structure in every test
- No `sleep()` / `time.sleep()` in tests — use fake clocks or deterministic async patterns
- Seed test data explicitly per test — no shared mutable state between tests
- Mock at the boundary only (external APIs, DB) — never mock internal functions

---

## Performance Engineering

### Algorithmic
- State time and space complexity before writing any non-trivial algorithm
- Prefer O(n log n) over O(n²) — built-in sorts (Timsort, pdqsort) almost always win
- Hash maps for O(1) lookup over linear scans on any hot path
- Streaming / lazy evaluation for large datasets — never load all rows into memory
- Bloom filters for membership checks before expensive lookups

### I/O
- Connection pool size: `(cpu_cores × 2) + effective_spindle_count` as starting baseline
- Async I/O for I/O-bound work; thread pools for CPU-bound work — never mix
- Batch writes: coalesce small writes — N+1 queries are always a bug, not an optimization
- Cursor-based pagination for large datasets; offset only for small stable tables under 10K rows

### Caching Rules
- Cache at the lowest-cost layer: in-process (L1) → shared cache (L2) → CDN (L3)
- TTL based on acceptable staleness — no infinite TTLs in production
- Never cache authorization decisions beyond token validity period
- Monitor hit rate — below 80% means wrong key strategy or TTL too aggressive

---

## API Design

### REST Standards
- Resources are nouns, plural: `/orders`, `/orders/{id}`, `/orders/{id}/items`
- HTTP verbs: GET (idempotent read), POST (create), PUT (full replace), PATCH (partial), DELETE
- Status codes:
  - `200` OK, `201` Created, `204` No Content
  - `400` Bad Request, `401` Unauthenticated, `403` Unauthorized, `404` Not Found
  - `409` Conflict, `422` Validation Failed, `429` Rate Limited
  - `500` Internal Error, `502` Bad Gateway, `503` Unavailable
- Error body: `{"error": {"code": "VALIDATION_FAILED", "message": "...", "fields": [{"field": "email", "issue": "invalid format"}]}}`
- Versioning: URL prefix `/v1/`, `/v2/` for breaking changes — never version in header by default
- Pagination: `?cursor=<opaque_token>&limit=N` → return `{"data": [...], "next_cursor": "...", "has_more": true}`

### GraphQL
- Use when multiple clients need flexible, divergent data shapes
- DataLoader for every relation — no N+1 queries, no exceptions
- Query depth limit + complexity scoring — enforce before hitting resolvers
- Persisted queries in production — smaller payloads, cache-friendly
- Mutations return the modified resource — no void mutations

### gRPC
- Default for internal service-to-service communication — typed, efficient, streaming native
- Always set client deadline — propagate deadline through call chain
- `.proto` files are source of truth — version in repo, generate code in CI
- Use streaming for: large paginated responses, real-time feeds, bidirectional sessions

---

## Code Quality

### SOLID Applied
- **SRP**: one reason to change — if you need "and" to describe the purpose, split it
- **OCP**: extend via composition, not inheritance modification — prefer strategy/decorator
- **LSP**: subtypes fully substitutable — type-checking the subtype in a condition violates this
- **ISP**: small focused interfaces — a class should not implement methods it doesn't need
- **DIP**: depend on abstractions at module boundaries — inject concrete implementations

### Functional Principles
- Pure functions by default — same input, same output, no side effects
- Immutability first — mutate only when performance measurements demand it
- Functions ≤20 lines — if longer, it has multiple responsibilities
- Railway-oriented error handling: propagate errors as values, chain operations cleanly
- Avoid shared mutable state — if unavoidable, use explicit synchronization primitives

### Naming
- Functions: `verb + noun` — `createOrder`, `fetchUser`, `validatePayload`
- Booleans: `is_`, `has_`, `can_`, `should_` prefix always
- Constants: `SCREAMING_SNAKE_CASE`
- Avoid: `data`, `info`, `stuff`, `temp`, `obj`, `result`, `thing` — name the domain concept

### Abstraction Rules
- **Rule of three**: abstract on third repetition, not second — duplication is cheaper than wrong abstraction
- Measure net complexity before and after abstracting — abstraction that adds complexity is a liability
- Premature abstraction is worse than duplication — patterns emerge, they are not designed upfront

---

## Hard Rules

| Rule | Why |
|---|---|
| Never force-push `main`/`master` | Destroys shared history |
| Never skip hooks (`--no-verify`) | Bypasses quality gates |
| Never commit secrets, `.env`, credentials | Permanent exposure risk |
| Never add features beyond the task scope | Scope creep compounds |
| Never add error handling for impossible scenarios | Dead code misleads |
| Never use bare `except:` / `.catch(() => {})` | Silent failures are the worst failures |
| Never hardcode environment-specific values | Breaks deployability |
| Never `TODO` in production code | Create a ticket instead |
| Never commit commented-out code | Git history is the undo button |
| Never `print()` / `console.log()` debug in commits | Use structured logging |
| Never N+1 queries | Use eager loading, DataLoader, or batching |
| Never synchronous I/O on the async hot path | Blocks the event loop / thread pool |
