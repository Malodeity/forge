# Architecture

## Layout

```
src/        source code — organized by domain/feature
tests/      mirrors src/ structure, one test file per source file
docs/       architecture decisions and API specs (this directory)
.claude/    Claude Code config — do not modify during normal development
```

## Principles

- Fail fast — raise errors early, no silent failures
- Flat over nested — prefer shallow module hierarchies
- Explicit over implicit — no magic imports or auto-discovery
- Stateless where possible — functions over classes unless state is essential

## Adding a Feature

1. `src/<domain>/<feature>.py` (or `.js`/`.ts`)
2. `tests/<domain>/test_<feature>.py` (or `.test.js`/`.test.ts`)
3. Export from `src/<domain>/__init__.py` if needed
4. Update `docs/architecture.md` if the change is structural

## Decision Log

| Date | Decision | Reason |
|---|---|---|
| 2026-05-12 | Flat src/ structure | Avoids premature nesting |
