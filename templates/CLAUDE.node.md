
---

## Node.js / TypeScript Standards

### TypeScript Config (strict)
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext"
  }
}
```
- `strict: true` is non-negotiable — no `any` without a `// eslint-disable` comment explaining why
- `noUncheckedIndexedAccess` prevents silent `undefined` from array access
- ESM (`NodeNext`) by default — no CommonJS in new code

### Async Patterns
```typescript
const [user, orders] = await Promise.all([
  fetchUser(userId),
  fetchOrders(userId),
]);

for await (const batch of db.streamQuery(sql)) {
  await processBatch(batch);
}
```
- `Promise.all` for independent concurrent operations — never `await` in a loop
- Streams for data >10K rows — `for await...of` on async iterators
- Never `catch (e: any)` — type your errors or use a result type

### Error Handling
```typescript
type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E };

async function createOrder(input: CreateOrderInput): Promise<Result<Order>> {
  const validation = validateInput(input);
  if (!validation.ok) return { ok: false, error: validation.error };
  const order = await repo.save(Order.create(input));
  return { ok: true, value: order };
}
```
- Domain errors as typed unions — not thrown exceptions on expected failures
- Reserve `throw` for truly exceptional, unrecoverable conditions
- Always handle promise rejections — `unhandledRejection` = production incident

### Testing
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('OrderService.create', () => {
  let repo: FakeOrderRepository;
  beforeEach(() => { repo = new FakeOrderRepository(); });

  it('emits order.created event on success', async () => {
    const svc = new OrderService(repo);
    await svc.create({ userId: 'usr_1', items: ['item_a'] });
    expect(repo.events.at(-1)?.type).toBe('order.created');
  });
});
```
- Vitest over Jest for new projects — faster, ESM native
- `vi.mock` for external modules; inject fakes for domain dependencies

### Tools
| Tool | Purpose |
|---|---|
| `vitest` | Testing (fast, ESM) |
| `eslint` + `@typescript-eslint` | Linting |
| `prettier` | Formatting |
| `zod` | Runtime schema validation |
| `pino` | Structured JSON logging |
