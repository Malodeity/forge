# /ship

Full pipeline: lint → type-check → test → commit → push.

## Steps

1. **Lint** — run linter, fix any issues before proceeding
   - Python: `ruff check src/ --fix`
   - Node: `npm run lint -- --fix`
2. **Type-check** (if applicable)
   - Python: `mypy src/`
   - TypeScript: `npm run type-check`
3. **Test** — run full test suite, do not proceed if tests fail
   - Python: `python -m pytest tests/ -x -q`
   - Node: `npm test`
4. **Commit** — follow the `/commit` workflow
5. **Push** — `git push -u origin <current-branch>`

## Rules
- Abort at any failing step — do not force through
- Report what failed and why; ask before skipping a step
- Never push a broken build
