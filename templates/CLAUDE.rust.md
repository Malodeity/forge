
---

## Rust Standards

### Error Handling
```rust
#[derive(Debug, thiserror::Error)]
pub enum OrderError {
    #[error("order {0} not found")]
    NotFound(String),
    #[error(transparent)]
    Database(#[from] sqlx::Error),
}

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

### Ownership and Borrowing
```rust
fn process(orders: &[Order]) -> Summary { ... }  // borrow, not Vec<Order>
let config = Arc::new(Config::from_env()?);
```
- Cloning is a design choice, not a fix for borrow checker errors
- `Arc<T>` for shared state across async tasks; `Rc<T>` never in async code
- Prefer `&str` over `String` in function parameters

### Async (Tokio)
```rust
let (user_result, orders_result) = tokio::join!(
    fetch_user(ctx, &user_id),
    fetch_orders(ctx, &user_id),
);
let user = user_result.context("fetch user")?;

tokio::task::spawn_blocking(|| expensive_cpu_work()).await?;
```
- `tokio::join!` for concurrent I/O — never `.await` sequentially in a loop
- CPU-bound work goes in `spawn_blocking` — never in the async executor
- Set timeouts with `tokio::time::timeout` — no await without a deadline on external I/O

### Tools
| Tool | Purpose |
|---|---|
| `clippy` | Lint — run `cargo clippy -- -D warnings` in CI |
| `rustfmt` | Format — `cargo fmt --check` in CI |
| `cargo audit` | Vulnerability scanning |
| `nextest` | Faster test runner (`cargo nextest run`) |
| `criterion` | Benchmarking |
