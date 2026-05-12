
---

## Python Standards

### Type Hints (mandatory)
```python
from typing import Optional, Union, TypeVar, Generic
from collections.abc import Sequence, Mapping, Iterator

def process(items: Sequence[str], limit: Optional[int] = None) -> list[str]:
    ...
```
- All function signatures must have type hints — no bare `def f(x)`
- Use `X | None` (Python 3.10+) over `Optional[X]`
- Use `collections.abc` for abstract types, not `typing.List`
- Run `mypy --strict` in CI — no untyped functions, no `Any` without comment

### Async Python
```python
import asyncio
import httpx

async def fetch_all(urls: list[str]) -> list[dict]:
    async with httpx.AsyncClient(timeout=10.0) as client:
        tasks = [client.get(url) for url in urls]
        responses = await asyncio.gather(*tasks, return_exceptions=True)
    return [r.json() for r in responses if not isinstance(r, Exception)]
```
- Use `asyncio.gather` for concurrent I/O — never `await` in a loop sequentially
- Always set timeouts on async HTTP clients
- `async with` for resource management — never manual open/close

### Error Handling
```python
class OrderNotFoundError(ValueError):
    def __init__(self, order_id: str) -> None:
        super().__init__(f"Order {order_id!r} not found")
        self.order_id = order_id

try:
    order = get_order(order_id)
except OrderNotFoundError:
    return Response(status=404)
```
- Define domain exceptions — never raise `Exception("message")`
- Never bare `except:` — always specify the exception type
- Use context managers for resource cleanup — not try/finally

### Testing (pytest)
```python
import pytest
from unittest.mock import AsyncMock, patch

@pytest.fixture
def order_repo() -> FakeOrderRepository:
    return FakeOrderRepository()

@pytest.mark.asyncio
async def test_create_order_emits_event(order_repo: FakeOrderRepository) -> None:
    service = OrderService(repo=order_repo)
    await service.create(user_id="usr_1", items=["item_a"])
    assert order_repo.events[-1].type == "order.created"
```
- Fixtures for all dependencies — never instantiate in test body
- `pytest.mark.asyncio` for async tests
- Parameterize with `@pytest.mark.parametrize` — no duplicated test logic

### Project Layout
```
src/
  <package>/
    __init__.py
    domain/
    application/
    adapters/
    api/
tests/
  unit/
  integration/
pyproject.toml
```

### Tools
| Tool | Purpose | Config |
|---|---|---|
| `ruff` | Lint + format | `pyproject.toml [tool.ruff]` |
| `mypy --strict` | Type checking | `pyproject.toml [tool.mypy]` |
| `pytest` + `pytest-asyncio` | Testing | `pyproject.toml [tool.pytest]` |
| `httpx` | Async HTTP client | — |
| `pydantic v2` | Data validation / settings | — |
