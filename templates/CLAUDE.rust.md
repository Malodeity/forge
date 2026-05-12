
---

## Rust Standards

### Project Layout
```
src/
  main.rs or lib.rs   # entry / public API
  domain/             # types, traits, pure logic
  application/        # use cases, orchestration
  adapters/           # DB, HTTP, queue implementations
  api/                # axum/actix handlers
  config.rs           # env parsing (config crate)
Cargo.toml
Cargo.lock            # always commit for binaries; gitignore for libraries
```

### Error Handling
```rust
// Domain errors as enums — exhaustive matching
#[derive(Debug, thiserror::Error)]
pub enum OrderError {
    #[error("order {0} not found")]
    NotFound(String),
    #[error("insufficient inventory for item {item_id}: need {needed}, have {available}")]
    InsufficientInventory { item_id: String, needed: u32, available: u32 },
    #[error(transparent)]
    Database(#[from] sqlx::Error),
}

// Application layer uses anyhow for context propagation
pub async fn create_order(input: CreateInput) -> anyhow::Result<Order> {
    let order = repo.save(Order::new(input))
        .await
        .context("failed to persist order")?;
    Ok(order)
}
```
- `thiserror` for library/domain errors — typed, matchable
- `anyhow` for application/binary error propagation — context chain
- Never `.unwrap()` or `.expect()` outside of tests — use `?` operator
- Use `?` at every fallible call site — explicit error propagation is the contract

### Ownership and Borrowing
```rust
// Prefer borrowing over cloning on hot paths
fn process(orders: &[Order]) -> Summary { ... }  // borrow, not Vec<Order>

// Clone explicitly and deliberately — not to satisfy the compiler
let name = user.name.clone();  // only when you actually need an owned copy

// Use Arc<T> for shared ownership across async boundaries
let config = Arc::new(Config::from_env()?);
```
- Cloning is a design choice, not a fix for borrow checker errors
- `Arc<T>` for shared state across async tasks; `Rc<T>` never in async code
- Prefer `&str` over `String` in function parameters; return `String` when ownership needed

### Async (Tokio)
```rust
// Spawn concurrent tasks with explicit error handling
let (user_result, orders_result) = tokio::join!(
    fetch_user(ctx, &user_id),
    fetch_orders(ctx, &user_id),
);
let user = user_result.context("fetch user")?;
let orders = orders_result.context("fetch orders")?;

// Never block in async context
tokio::task::spawn_blocking(|| expensive_cpu_work()).await?;
```
- `tokio::join!` for concurrent I/O — never `.await` sequentially in a loop
- CPU-bound work goes in `spawn_blocking` — never in the async executor
- Set timeouts with `tokio::time::timeout` — no await without a deadline on external I/O

### Traits and Generics
```rust
// Define abstractions as traits — inject via generics or dyn Trait
#[async_trait]
pub trait OrderRepository: Send + Sync {
    async fn find_by_id(&self, id: &str) -> Result<Order, OrderError>;
    async fn save(&self, order: &Order) -> Result<(), OrderError>;
}

// Generic when the trait is used in hot path; dyn when flexibility > perf
pub struct OrderService<R: OrderRepository> { repo: R }
// or
pub struct OrderService { repo: Box<dyn OrderRepository> }
```
- `Send + Sync` bounds on trait objects used across async tasks
- `#[async_trait]` for async methods in traits (until `async fn` in traits is stable)
- Prefer generics over `dyn Trait` in performance-critical code

### Testing
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn create_order_emits_event() {
        let repo = FakeOrderRepository::new();
        let svc = OrderService::new(repo.clone());
        svc.create(CreateInput { user_id: "usr_1".into() }).await.unwrap();
        assert_eq!(repo.events().len(), 1);
        assert_eq!(repo.events()[0].kind, EventKind::OrderCreated);
    }
}
```
- `#[tokio::test]` for async tests
- Fake implementations via `Arc<Mutex<Vec<_>>>` for shared state inspection
- `cargo test -- --test-threads=1` only when tests have unavoidable shared state
- `sqlx::test` for database integration tests with automatic migrations

### Tools
| Tool | Purpose |
|---|---|
| `clippy` | Lint — run `cargo clippy -- -D warnings` in CI |
| `rustfmt` | Format — `cargo fmt --check` in CI |
| `cargo audit` | Vulnerability scanning |
| `cargo deny` | License + dependency policy |
| `nextest` | Faster test runner (`cargo nextest run`) |
| `criterion` | Benchmarking |

### Performance
- Profile before optimizing — `cargo flamegraph` or `samply`
- `#[inline]` only when benchmarks show benefit — trust the compiler
- Avoid allocations in hot loops — use `&str`, slices, and stack-allocated types
- `SmallVec` or `ArrayVec` for small collections with known bounded size
- SIMD via `std::simd` (nightly) or `packed_simd`/`wide` for vectorizable workloads
