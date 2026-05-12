# forge

**God-level engineering standards for Claude Code. Install once, works in any project.**

```bash
curl -fsSL https://raw.githubusercontent.com/Malodeity/forge/main/install.sh | bash
# or
npx forge init
```

---

## The Problem

When you open Claude Code in a project, Claude starts from zero every single session.

It doesn't know your architecture. It doesn't know your conventions. It doesn't know which commands run your tests, what your branching strategy is, or that you never want `any` in TypeScript. So it spends tokens exploring files, asking clarifying questions, and re-deriving things it already figured out last session. Then it makes choices that diverge from your patterns because it had no signal.

That token waste compounds. On a typical task:
- 20–30% of tokens go to **discovery** — Claude exploring the codebase to understand context
- 10–15% go to **permission prompts** — Claude asking before every `git diff` and `npm test`
- 8–10% go to **workflow re-derivation** — Claude figuring out how to run tests, lint, and commit each time

Beyond tokens: without explicit standards, Claude defaults to safe-but-mediocre choices. It won't pick CQRS when CQRS is right. It won't set up the Outbox pattern when eventual consistency demands it. It won't apply STRIDE threat modeling before writing a new auth flow. Not because it can't — because it had no signal that you expected that level.

**forge solves both problems at once.**

---

## What It Is

forge is an installable Claude Code configuration package. One command adds it to any project:

- A `CLAUDE.md` file with comprehensive engineering standards that Claude reads at the start of every session
- A `.claude/` directory with pre-approved permissions, automatic hooks, and 11 slash commands
- A `.claudeignore` that filters noise from Claude's context

After installation, every Claude Code session in your project starts fully oriented — no exploration, no re-derivation, no permission prompts for safe operations. And Claude applies senior staff engineer judgment: it knows your architecture patterns, your security checklist, your observability standards, and your hard rules.

---

## How It Works

### 1. CLAUDE.md — Pre-loaded context

Claude Code reads `CLAUDE.md` at the start of every session before processing your first message. forge's `CLAUDE.md` is a dense, structured reference document that encodes everything a senior engineer would bring to the first day on your project.

Instead of:
> Claude explores 15 files → infers the architecture → makes mediocre choices → uses 400 tokens doing it

You get:
> Claude reads one file → has full context → applies the right patterns → 0 exploration tokens

The document is built from a universal base plus auto-detected stack-specific additions. Every section is tables and code blocks — no prose. Dense but scannable in seconds.

### 2. Pre-approved permissions — No prompt overhead

Every `git diff`, `npm test`, `find .`, and `grep` normally triggers a permission prompt. That's a full back-and-forth turn per operation: Claude requests, you approve, Claude proceeds.

forge's `.claude/settings.json` pre-approves ~35 safe, read-only and standard operations so Claude executes them without prompting. Destructive operations (`git push --force origin main`, `rm -rf /`) remain explicitly blocked.

### 3. Automatic hooks — No follow-up steps

After every file edit, a linter runs silently and Claude sees the result. After every session, Claude prints a one-line summary of branch state. These replace the "should I run the linter?" and "let me check git status" turns that happen organically.

### 4. Slash commands — Encoded workflows

Slash commands are markdown files in `.claude/commands/`. They encode full multi-step workflows so Claude executes them with zero discovery. `/ship` doesn't require Claude to figure out your lint/test/commit/push steps — they're already written down.

11 commands cover the full development lifecycle:

| Command | Encodes |
|---|---|
| `/commit` | Conventional commit workflow |
| `/ship` | lint → typecheck → test → commit → push |
| `/review` | Security + logic review checklist |
| `/fix` | Root-cause diagnosis and verify loop |
| `/context` | Full session orientation dump |
| `/design` | System design: components, failure modes, capacity |
| `/arch` | Architecture review: layers, coupling, testability score |
| `/perf` | N+1 detection, query analysis, algorithmic complexity |
| `/security` | Injection scan, auth gaps, secrets, cryptography |
| `/data` | Schema quality, migration safety, pipeline idempotency |
| `/refactor` | Safe incremental refactoring with test verification |

---

## What Gets Installed

```
your-project/
├── CLAUDE.md                       ← The standards Claude follows
├── .claudeignore                   ← Noise filter (node_modules, dist, logs, secrets)
└── .claude/
    ├── settings.json               ← Permissions + hooks
    └── commands/
        ├── commit.md
        ├── ship.md
        ├── review.md
        ├── fix.md
        ├── context.md
        ├── design.md
        ├── arch.md
        ├── perf.md
        ├── security.md
        ├── data.md
        └── refactor.md
```

---

## CLAUDE.md Contents

The installed `CLAUDE.md` covers 12 sections drawn from senior staff engineering knowledge:

### Architecture Decision Framework
A decision matrix for when to use Clean Architecture, CQRS, Event Sourcing, DDD, Microservices, BFF, Hexagonal, and Monolith-first — including explicit "avoid when" guidance. Claude picks the right pattern for the problem instead of defaulting to the familiar one.

### System Design Patterns
The full resilience playbook: circuit breaker, bulkhead, retry with jitter, idempotency keys, Outbox pattern, Saga (choreography and orchestration), consistent hashing, backpressure. Plus caching strategy selection table (cache-aside, write-through, write-behind, refresh-ahead).

### Data Engineering
Schema design rules (immutable events, UUID v7, soft deletes, SCD Type 2), indexing strategy (composite index column order, covering indexes, partial indexes), pipeline paradigm selection (ETL vs ELT vs streaming vs Lambda/Kappa), Medallion architecture, dbt standards, data quality gates.

### AI/ML Engineering
Feature store patterns, point-in-time join rules (no leakage), model serving mode selection (batch/real-time/shadow/canary), RAG architecture (chunking, hybrid retrieval, reranking, context budget management), prompt engineering rules (structure, few-shot, temperature), evaluation and drift detection.

### Security
STRIDE threat modeling template, Zero Trust principles, OWASP Top 10 as an actionable checklist (not a reference list), secrets management requirements, input validation rules, output encoding by context.

### Observability
Structured log format (JSON schema with required fields), distributed tracing standards (W3C traceparent, span attributes), RED metrics definition (rate/errors/duration per service), SLO definition template with burn-rate alerting.

### Testing Strategy
Full test pyramid table (unit/integration/contract/E2E/load/chaos) with tools and coverage targets per layer, plus rules: test behavior not implementation, one assertion per test, no `sleep()` in tests, no shared mutable state.

### Performance Engineering
Algorithmic complexity rules, N+1 query patterns, connection pool sizing formula, async vs sync I/O guidance, cursor-based pagination rules, caching layer selection.

### API Design
REST resource naming, HTTP verb semantics, status code mapping, error body format, versioning strategy, cursor pagination schema. GraphQL: DataLoader requirement, depth limiting, persisted queries. gRPC: deadline propagation, proto as source of truth.

### Code Quality
SOLID applied concretely (each principle with a one-line violation detector), functional principles (pure functions, immutability, max 20-line functions), naming conventions, abstraction rules (rule of three).

### Stack-specific additions (auto-detected)
| Stack | Extra standards |
|---|---|
| Python | Type hints (mandatory), async patterns, pytest fixtures, ruff/mypy config |
| Node.js | TypeScript strict config, result types, vitest, pino logging, zod |
| Mobile | Offline-first architecture, sync conflict resolution, React Native + Flutter patterns |
| Data | SQL performance rules, streaming patterns (Kafka), dbt standards, data quality |
| Go | Standard layout, error wrapping, interface design, concurrency with errgroup |
| Rust | Error handling (thiserror + anyhow), ownership rules, async with Tokio, clippy |

### Hard Rules
12 non-negotiable engineering rules in a table with the reason for each — so Claude never has to guess whether you care about them.

---

## Token Reduction

Installing forge cuts token usage by **~58% per task**:

| Layer | How it reduces tokens | Saving |
|---|---|---|
| CLAUDE.md | Claude reads 1 file instead of exploring 10–20 to understand context | ~25% |
| Pre-approved permissions | Eliminates prompt turns for safe operations | ~12% |
| Slash commands | Eliminates workflow re-derivation each session | ~8% |
| Hooks | Eliminates "should I lint?" follow-up steps | ~5% |
| .claudeignore | Prevents reading node_modules, dist, lock files | ~5% |
| Clear structure | Eliminates "where does this go?" questions | ~3% |
| **Total** | | **~58%** |

The 25% from CLAUDE.md is the biggest lever. Discovery is the largest token sink in any sufficiently complex project.

---

## Install

### Any project (universal)
```bash
curl -fsSL https://raw.githubusercontent.com/Malodeity/forge/main/install.sh | bash
```

### Node.js projects (npm)
```bash
npx forge init
```

### Force a specific stack
```bash
# Available: python · node · mobile · data · go · rust · universal
curl -fsSL .../install.sh | bash -s -- --stack python
```

### Pin to a specific version
```bash
# Use a release tag — safe for production projects
curl -fsSL https://raw.githubusercontent.com/Malodeity/forge/v1.0.0/install.sh | bash

# Or with the env var
MALODEITY_VERSION=v1.0.0 bash install.sh

# npm
npx forge@1.0.0 init
```

### Upgrade
```bash
# Pull latest standards into existing install
npx forge update
# or
curl -fsSL .../install.sh | bash  # idempotent — safe to re-run
```

### Install into a specific directory
```bash
bash install.sh --dir /path/to/my-project
```

---

## Stack Auto-detection

The installer examines your project root and picks the right template:

| Detected by | Stack | Additions |
|---|---|---|
| `package.json` + `react-native` / `expo` | mobile (React Native) | Mobile patterns |
| `pubspec.yaml` | mobile (Flutter) | Mobile patterns |
| `package.json` | node | TypeScript, vitest, pino |
| `pyproject.toml` / `requirements.txt` + data libs | data | Data engineering + Python |
| `pyproject.toml` / `requirements.txt` | python | Type hints, pytest, ruff |
| `go.mod` | go | Go layout, error handling, concurrency |
| `Cargo.toml` | rust | Ownership, thiserror, Tokio |
| `pom.xml` / `build.gradle` | java | Universal base |
| `*.csproj` | dotnet | Universal base |
| Nothing matched | universal | Universal base only |

Override detection at any time with `--stack`.

---

## CI / Validation

Every PR to this repo runs:

| Check | What it validates |
|---|---|
| JSON validity | `templates/settings.json` and `.claude/settings.json` parse correctly |
| ShellCheck | `install.sh` passes static analysis |
| Install smoke test × 5 | Universal, python, node, mobile stacks + npm CLI |
| Required sections | Installed `CLAUDE.md` contains all 12 key sections |
| Template size guard | No template exceeds 700 lines |
| Idempotency | Running install twice doesn't double the content |

---

## Versioning

forge uses semantic versioning:

- **Patch** (`v1.0.x`): corrections to existing standards, wording improvements
- **Minor** (`v1.x.0`): new sections, new stack templates, new slash commands
- **Major** (`vX.0.0`): breaking changes to the `CLAUDE.md` structure or command interface

Pin to a minor version for stability: `MALODEITY_VERSION=v1.2.0`

---

## Contributing

The standards in `templates/CLAUDE.base.md` represent real-world senior engineering judgment, not textbook best practices. Contributions must be:

1. **Specific** — "prefer X over Y when Z" not "use good patterns"
2. **Actionable** — Claude must be able to apply it directly
3. **Token-efficient** — tables and bullets, not prose
4. **Justified** — explain why in the PR description, not in the file

To add a new stack template:
1. Create `templates/CLAUDE.<stack>.md`
2. Add detection logic to `install.sh` `detect_stack()`
3. Add install case to `install_claude_md()`
4. Add a test in `.github/workflows/validate.yml`

---

## License

MIT
