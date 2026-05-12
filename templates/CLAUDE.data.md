
---

## Data Engineering Addendum

### SQL Performance
```sql
WITH recent_orders AS (
  SELECT user_id, COUNT(*) AS order_count
  FROM orders
  WHERE created_at >= NOW() - INTERVAL '30 days'
    AND deleted_at IS NULL
  GROUP BY user_id
)
SELECT u.id, u.email, r.order_count
FROM users u
JOIN recent_orders r ON r.user_id = u.id
WHERE r.order_count > 5;
```
- `EXPLAIN ANALYZE` every query touching >10K rows before shipping
- `LIMIT` on all user-facing queries — unbounded queries are a DoS vector
- Window functions over self-joins for ranked/running aggregations

### Pipeline Quality Gates
- **Row count check**: output rows within N% of last run — alert on anomalies
- **Null rate check**: key columns have null rate below threshold
- **Freshness check**: data not older than SLA — alert on stale partitions
- **Reconciliation**: total aggregates match between source and warehouse daily

### Streaming Patterns (Kafka / Flink / Spark Streaming)
- **At-least-once** by default; idempotent consumers handle duplicates
- **Exactly-once**: Kafka transactions + idempotent producer for financial events
- **Partition key**: choose for even distribution — user_id hashes evenly; timestamps don't
- **Consumer lag**: alert when consumer lag exceeds 60s
- **Dead letter queue (DLQ)**: route poison messages to DLQ with original headers preserved

### dbt Standards
```yaml
version: 2
models:
  - name: orders
    description: "One row per order, SCD2 with valid_from/valid_to"
    columns:
      - name: order_id
        tests: [unique, not_null]
      - name: status
        tests:
          - accepted_values:
              values: ['pending', 'paid', 'shipped', 'cancelled']
```
- Every model has `unique` + `not_null` tests on primary key
- `ref()` over hardcoded table names — always
- `source()` for raw tables with freshness checks defined

### Storage Sizing
| Data type | Format | When |
|---|---|---|
| Tabular analytics | Parquet + Snappy | Default for warehouse / lake |
| Time series | Parquet partitioned by day | High-volume metrics |
| Documents | JSON Lines (JSONL) | Semi-structured, infrequent query |
| Streaming checkpoint | Avro | Schema evolution in Kafka |
| ML features | Parquet + feature store | Training + serving consistency |
