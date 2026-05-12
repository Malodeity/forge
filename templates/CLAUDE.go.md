
---

## Go Standards

### Project Layout (standard Go)
```
cmd/
  <app>/
    main.go           # entry point only — wire deps and start
internal/
  domain/             # types, interfaces, domain logic
  app/                # use cases
  adapters/           # DB, HTTP clients, queue
  api/                # HTTP handlers, middleware
  config/             # env parsing
pkg/                  # reusable, importable by external packages
go.mod
go.sum
```
- `internal/` enforced by the compiler — use it for everything not meant for external import
- `cmd/` contains `main.go` only — no business logic in main
- Interfaces defined where they are used, not where they are implemented

### Error Handling
```go
// Wrap errors with context at every layer boundary
func (r *orderRepo) FindByID(ctx context.Context, id string) (*Order, error) {
    var o Order
    err := r.db.QueryRowContext(ctx, query, id).Scan(&o.ID, &o.Status)
    if errors.Is(err, sql.ErrNoRows) {
        return nil, ErrNotFound{ID: id}
    }
    if err != nil {
        return nil, fmt.Errorf("orderRepo.FindByID %s: %w", id, err)
    }
    return &o, nil
}

// Sentinel errors for domain conditions
var ErrNotFound = errors.New("not found")
type ErrNotFound struct{ ID string }
func (e ErrNotFound) Error() string { return fmt.Sprintf("order %q not found", e.ID) }
```
- `fmt.Errorf("context: %w", err)` at every layer boundary — never discard or silently swallow
- `errors.Is` / `errors.As` for inspection — never string-match error messages
- Sentinel errors or typed error structs for domain conditions
- Never `panic` in library code — only in `main` for unrecoverable startup failures

### Interfaces and Dependency Injection
```go
// Define interface at point of use
type OrderRepository interface {
    FindByID(ctx context.Context, id string) (*Order, error)
    Save(ctx context.Context, o *Order) error
}

type OrderService struct {
    repo OrderRepository  // injected, not constructed here
}
```
- Keep interfaces small — one or two methods is ideal
- Accept interfaces, return concrete types (Go proverb)
- Wire dependencies in `main.go` or a dedicated `wire.go` — not in constructors

### Context
```go
func (s *OrderService) Create(ctx context.Context, input CreateInput) (*Order, error) {
    // Pass ctx to every I/O call — no background context inside methods
    return s.repo.Save(ctx, order)
}
```
- `context.Context` is the first argument to every function that does I/O
- Never store context in a struct — pass it per-call
- Set deadlines at the service entry point; propagate through the call chain

### Concurrency
```go
// Use errgroup for concurrent fan-out with error propagation
g, ctx := errgroup.WithContext(ctx)
g.Go(func() error { return fetchUser(ctx, id) })
g.Go(func() error { return fetchOrders(ctx, id) })
if err := g.Wait(); err != nil {
    return fmt.Errorf("concurrent fetch: %w", err)
}
```
- `sync.WaitGroup` for fire-and-forget goroutines; `errgroup` when errors matter
- Always drain channels before returning — leaking goroutines are a memory leak
- Prefer channels over mutexes for communicating between goroutines
- `sync.Mutex` only for protecting shared memory; keep critical sections small

### Testing
```go
func TestOrderService_Create(t *testing.T) {
    t.Parallel()
    repo := &fakeOrderRepo{}
    svc := NewOrderService(repo)

    order, err := svc.Create(context.Background(), CreateInput{UserID: "usr_1"})
    require.NoError(t, err)
    assert.Equal(t, "pending", order.Status)
    assert.Len(t, repo.saved, 1)
}
```
- `t.Parallel()` on every unit test — fast tests should run concurrently
- Fake implementations over mocks — fake structs are type-safe and readable
- `testify/require` for fatal assertions, `testify/assert` for non-fatal
- `testcontainers-go` for DB integration tests — never sqlite as a postgres stand-in

### Tools
| Tool | Purpose |
|---|---|
| `golangci-lint` | Lint (runs errcheck, staticcheck, gosec, and more) |
| `go test -race` | Race condition detection — run in CI always |
| `go vet` | Suspicious code patterns |
| `govulncheck` | Vulnerability scanning |
| `testify` | Assertions |
| `testcontainers-go` | Integration tests with real deps |
