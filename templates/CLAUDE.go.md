
---

## Go Standards

### Project Layout (standard Go)
```
cmd/<app>/main.go     # entry point only
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
```
- `fmt.Errorf("context: %w", err)` at every layer boundary
- `errors.Is` / `errors.As` for inspection — never string-match error messages
- Never `panic` in library code — only in `main` for unrecoverable startup failures

### Concurrency
```go
g, ctx := errgroup.WithContext(ctx)
g.Go(func() error { return fetchUser(ctx, id) })
g.Go(func() error { return fetchOrders(ctx, id) })
if err := g.Wait(); err != nil {
    return fmt.Errorf("concurrent fetch: %w", err)
}
```
- `sync.WaitGroup` for fire-and-forget; `errgroup` when errors matter
- Always drain channels before returning — leaking goroutines are a memory leak
- `context.Context` is the first argument to every function that does I/O

### Tools
| Tool | Purpose |
|---|---|
| `golangci-lint` | Lint (errcheck, staticcheck, gosec) |
| `go test -race` | Race condition detection — run in CI always |
| `govulncheck` | Vulnerability scanning |
| `testcontainers-go` | Integration tests with real deps |
