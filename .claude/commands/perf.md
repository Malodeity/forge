# /perf

Performance audit — find bottlenecks before production finds them.

## Steps

### 1. Find N+1 queries
```bash
grep -rn "for\|forEach\|map" src/ | grep -i "await\|query\|find\|fetch" | head -30
```
Flag: any DB/API call inside a loop without explicit batching.

### 2. Find unbounded queries
```bash
grep -rn "findAll\|SELECT \*\|\.all()\|limit(None)" src/ | head -20
```
Flag: any query without a LIMIT clause on user-facing paths.

### 3. Find synchronous I/O on async paths
```bash
grep -rn "readFileSync\|execSync\|spawnSync" src/ | head -20
```
Flag: sync I/O in async functions blocks the event loop.

### 4. Find missing indexes (from query patterns)
Scan query files for WHERE/JOIN/ORDER BY columns — cross-reference against schema.
Flag: columns used in predicates without index definitions.

### 5. Find missing caching
Identify hot paths (called on every request) that:
- Query the same data repeatedly without caching
- Compute expensive aggregations without memoization
- Call external APIs without response caching

### 6. Algorithmic review
For each non-trivial algorithm:
- State current time complexity
- Identify if a better algorithm exists
- Flag O(n²) or worse in loops over user-controlled data

### 7. Memory profiling hints
```bash
grep -rn "\.map(.*\.map\|\.filter(.*\.filter" src/ | head -20
```
Flag: creating multiple intermediate arrays on large datasets — use streaming or single-pass.

### 8. Output
```
[CRITICAL] file:line — description (estimated impact)
[HIGH]     ...
[MEDIUM]   ...
[LOW]      ...
```
End with: top 3 fixes ranked by estimated latency/throughput improvement.
