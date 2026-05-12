# /data

Data engineering review — schema quality, pipeline correctness, query performance.

## Steps

### 1. Schema audit
Read migration files or ORM models. Check:
- Primary keys: UUID (v7 preferred) or auto-increment? Document the reason.
- Soft deletes present? (`deleted_at` column)
- Temporal tracking? (`created_at`, `updated_at` on every table)
- Missing indexes on FK columns? (always index foreign keys)
- Enum types: DB-native enum vs string with check constraint? (string+check is more evolvable)

### 2. Query review
Find all raw SQL or ORM query definitions:
```bash
grep -rn "SELECT\|\.query(\|\.filter(\|\.where(" src/ --include="*.py" --include="*.js" --include="*.ts" | head -40
```
For each query check:
- LIMIT present on user-facing queries?
- N+1 pattern? (query in loop)
- Missing index on WHERE/JOIN/ORDER BY columns?
- `SELECT *` instead of explicit columns?
- Unbounded date ranges?

### 3. Pipeline idempotency check
```bash
grep -rn "INSERT INTO\|\.insert(" src/ | grep -v "ON CONFLICT\|upsert\|ignore" | head -20
```
Flag: inserts without upsert / idempotency key — running pipeline twice will create duplicates.

### 4. Data quality checks
Find where data enters the system. For each ingestion point:
- Is schema validated on arrival?
- Are null rates checked?
- Is row count anomaly detection in place?
- What happens to malformed records? (DLQ vs silent drop)

### 5. Migration safety
```bash
find . -name "*.sql" -o -name "migrations/" | head -20
```
Check recent migrations for:
- Dropping or renaming columns (breaking change for running app)
- Adding NOT NULL without default (blocks migration on non-empty table)
- Full-table locks (e.g., adding index without CONCURRENTLY)
- Missing rollback migration

### 6. Data freshness
- Are pipelines monitored for staleness?
- Is there an alert if a partition isn't updated within SLA?
- Are consumer lag metrics available for streaming pipelines?

### 7. Output
```
[CRITICAL] file:line — issue (data loss / corruption risk)
[HIGH]     — performance or consistency risk
[MEDIUM]   — quality or maintainability risk
[LOW]      — informational
```
Top 3 highest-priority fixes with exact remediation steps.
