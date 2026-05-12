# /arch

Review existing code for architectural quality. Identify violations and recommend targeted fixes.

## Steps

### 1. Map the current architecture
```bash
find src/ -type f | head -60   # get the shape
git log --oneline -10           # recent change velocity
```
Identify: layers present, dependency directions, coupling points, shared state.

### 2. Check layer boundaries
- Does the domain layer import from infrastructure? (violation)
- Do controllers call repositories directly, bypassing use cases? (violation)
- Is business logic in route handlers or middleware? (violation)
- Are domain types leaking into API responses without mapping? (violation)

### 3. Check coupling
- Shared database tables between bounded contexts → tight coupling
- Direct synchronous calls to >3 other services → fan-out coupling
- Circular dependencies between modules → design smell

### 4. Check extensibility
- Is new behavior added by modification or extension?
- Are abstractions used at integration points (DB, HTTP, queue)?
- Would changing the database require touching domain logic?

### 5. Check testability
- Can domain logic be tested without spinning up infra?
- Are dependencies injected or hardcoded?
- Are side effects isolated from pure logic?

### 6. Score each dimension
| Dimension | Score (1–5) | Key Issue |
|---|---|---|
| Layer separation | | |
| Coupling | | |
| Testability | | |
| Extensibility | | |
| Consistency | | |

### 7. Top 3 recommendations
Ranked by impact/effort ratio. Each with:
- What the violation is
- Where it appears (file:line)
- Concrete fix (code snippet if helpful)
- Estimated effort (hours)

## Output
Score table + top 3 recommendations + one-sentence overall verdict.
