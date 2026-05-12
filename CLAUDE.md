# CLAUDE.md

## Stack
- **Languages:** C#, Node.js, Python, Scala, Java
- **AI/ML:** TensorFlow, PyTorch, Transformers, HuggingFace
- **Reverse Engineering:** C, C++, Assembly, IDA Pro, x64dbg
- **Web:** JavaScript, React, Vue, PHP, REST APIs, WebAssembly
- **Databases:** PostgreSQL, MySQL, MongoDB, Redis, Oracle SQL
- **DevOps:** Docker, AWS, Kubernetes, Linux
- **Frontend:** React, Vue, Nuxt, Three.js

## Architecture
```
src/        application source code
tests/      test files, mirror src/ structure
docs/       architecture decisions, API specs
.claude/    Claude Code config (settings, commands, hooks)
```

## Commands
| Task | Command |
|---|---|
| Run tests (Python) | `python -m pytest tests/ -x -q` |
| Run tests (Node) | `npm test` |
| Lint (Python) | `ruff check src/` |
| Lint (Node/JS) | `npm run lint` |
| Format (Python) | `ruff format src/` |
| Format (Node/JS) | `npm run format` |
| Build | `npm run build` or `python -m build` |
| Type check (Python) | `mypy src/` |
| Type check (TS) | `npm run type-check` |

## Conventions
- **Commits:** `type(scope): message` — types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
- **Branch:** `claude/<slug>` for AI-driven work, `feat/<slug>` for features
- **Naming:** snake_case for Python, camelCase for JS/TS, PascalCase for classes/components
- **Comments:** none by default — only add when the WHY is non-obvious
- **Tests:** one test file per source file, co-located in `tests/`
- **Errors:** fail fast, no silent catches, no empty except blocks

## Hard Rules
- Never force-push `main` or `master`
- Never skip hooks (`--no-verify`)
- Never commit `.env`, secrets, or credentials
- Never add features beyond what the task requires
- Never add error handling for impossible scenarios
- Never use `rm -rf` without explicit user instruction

## Common Patterns

### Python HTTP client
```python
import httpx
resp = httpx.get(url, timeout=10)
resp.raise_for_status()
data = resp.json()
```

### Async Python
```python
import asyncio
async def main():
    result = await some_coroutine()
asyncio.run(main())
```

### Node fetch
```js
const res = await fetch(url);
if (!res.ok) throw new Error(`HTTP ${res.status}`);
const data = await res.json();
```

### Docker one-liner
```bash
docker build -t app . && docker run --rm -p 8080:8080 app
```

## Slash Commands
| Command | What it does |
|---|---|
| `/commit` | Stage, write conventional commit, push |
| `/ship` | lint → test → commit → push |
| `/review` | Security + logic review of current diff |
| `/fix` | Diagnose failing test/lint, fix root cause, verify |
| `/context` | Print branch state, recent commits, open TODOs |
