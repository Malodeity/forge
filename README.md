# malodeity

God-level Claude Code engineering standards. One command installs them into any project.

Covers data engineering · mobile · web backend · AI/ML · system design · security · observability.

---

## Install

**Any project (bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/Malodeity/Malodeity/main/install.sh | bash
```

**Node.js projects:**
```bash
npx malodeity init
```

**Force a specific stack:**
```bash
curl -fsSL .../install.sh | bash -s -- --stack python
# stacks: python · node · mobile · data · universal
```

**Upgrade existing install:**
```bash
npx malodeity update
# or re-run the curl command
```

---

## What gets installed

```
CLAUDE.md                     Engineering standards Claude follows every session
.claude/settings.json         Pre-approved permissions + automatic hooks
.claude/commands/             10 slash commands
.claudeignore                 Noise filter for Claude context
```

### CLAUDE.md covers

| Section | What's inside |
|---|---|
| Architecture Decision Framework | When to use Clean Arch, CQRS, DDD, Event Sourcing, Microservices, BFF |
| System Design Patterns | Circuit breaker, Saga, Outbox, Consistent hashing, Rate limiting, Caching strategies |
| Data Engineering | Schema design, indexing, medallion architecture, SCD2, pipeline idempotency, dbt standards |
| AI/ML Engineering | Feature stores, model serving modes, RAG architecture, prompt engineering, drift detection |
| Security | STRIDE threat model, Zero trust, OWASP Top 10 checklist, secrets management |
| Observability | Structured log format, distributed tracing, RED metrics, SLO template |
| Testing Strategy | Test pyramid, what to mock, contract testing, chaos engineering |
| Performance | Algorithmic complexity, N+1 detection, caching rules, I/O patterns |
| API Design | REST standards, GraphQL rules, gRPC patterns |
| Code Quality | SOLID applied, functional principles, naming rules, abstraction rules |
| Hard Rules | 12 non-negotiable engineering rules |

Stack-specific additions auto-detected and appended:
- **Python**: type hints, async patterns, pytest, ruff/mypy config
- **Node.js**: TypeScript strict, vitest, pino logging, zod validation
- **Mobile**: offline-first, sync strategies, React Native + Flutter patterns
- **Data**: SQL performance, streaming, dbt standards, data quality gates

### Slash commands

| Command | What it does |
|---|---|
| `/commit` | Stage → conventional commit → push |
| `/ship` | lint → test → commit → push (full pipeline) |
| `/review` | Security + logic review of current diff |
| `/fix` | Diagnose failing test or lint error, fix root cause, verify |
| `/context` | Full session orientation: branch, commits, TODOs, diff |
| `/design` | System design analysis: components, failure modes, capacity estimate |
| `/arch` | Architecture review: layer violations, coupling, testability score |
| `/perf` | Performance audit: N+1, unbounded queries, missing indexes, algorithmic complexity |
| `/security` | Deep security audit: injection, auth gaps, secrets, cryptography |
| `/data` | Data engineering review: schema, query quality, migration safety, pipeline idempotency |

### Hooks (automatic)
- **After every file edit**: linter runs silently — Claude sees the result immediately
- **End of session**: prints branch name, last 3 commits, status

---

## Token reduction

Installing malodeity cuts Claude Code token usage by ~58% per task:

| Layer | Mechanism | Saving |
|---|---|---|
| CLAUDE.md | Pre-loaded context — no exploration per session | ~25% |
| Pre-approved permissions | No permission prompt turns | ~12% |
| Slash commands | Encoded workflows — no re-derivation | ~8% |
| Hooks | No manual follow-up steps | ~5% |
| .claudeignore | No accidental large-file reads | ~5% |
| Clear structure | No "where does this go?" questions | ~3% |

---

## How it works

Claude Code reads `CLAUDE.md` at the start of every session. Instead of spending tokens exploring the codebase and re-deriving conventions, it already knows:
- the architecture patterns to follow
- the exact commands to run tests, lint, and build
- the security checklist to apply automatically
- the hard rules that never bend
- what to never do

The slash commands encode complex workflows so `/ship` executes a full lint → test → commit → push pipeline without Claude figuring out the steps.

Pre-approved permissions eliminate the back-and-forth for safe operations like `git diff`, `npm test`, and `find .`.

---

## Stack detection

The installer automatically detects your stack and appends the right additions to `CLAUDE.md`:

| Detected by | Stack | Extra standards |
|---|---|---|
| `package.json` + `react-native`/`expo` | mobile | Mobile patterns |
| `pubspec.yaml` | mobile (Flutter) | Mobile patterns |
| `package.json` | node | TypeScript, vitest, pino |
| `requirements.txt` / `pyproject.toml` + data libs | data | Data engineering |
| `requirements.txt` / `pyproject.toml` | python | Type hints, pytest, ruff |
| `go.mod` | go | Universal base only |
| `Cargo.toml` | rust | Universal base only |
| nothing matched | universal | Universal base only |

---

## License

MIT
