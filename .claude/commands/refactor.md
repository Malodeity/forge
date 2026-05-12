# /refactor

Safe, incremental refactoring. Each step is independently verifiable — no big-bang rewrites.

## Prerequisite check
Before touching a single line, run the test suite and confirm it passes:
```bash
python -m pytest tests/ -x -q 2>/dev/null || npm test 2>/dev/null
```
If tests are failing before you start, stop and use `/fix` first. Never refactor on a red suite.

## Step 1 — Name the refactor type
State which type this is:
- **Extract function**: move logic into a named function
- **Extract module**: move a group of functions to a new file
- **Rename**: rename a symbol consistently across the codebase
- **Inline**: collapse an unnecessary indirection
- **Move**: relocate a function/class to a more appropriate module
- **Decompose conditional**: replace complex boolean logic with named predicates
- **Replace magic value**: replace hardcoded literal with a named constant
- **Introduce parameter object**: collapse N related params into one typed struct/dataclass
- **Replace inheritance with composition**: decouple via dependency injection

## Step 2 — Scope it
```bash
grep -rn "<symbol>" src/ tests/
```
List every file that will change. If >5 files, pause and confirm scope with user before proceeding.

## Step 3 — Make one atomic change
Apply the smallest possible change that is complete on its own. Do not mix refactor types in one step.

Rules:
- No behavior change — refactoring must not alter observable output
- No new features or bug fixes in the same commit
- Preserve all existing function signatures unless the refactor explicitly changes them
- Update all call sites in the same commit — no partial renames

## Step 4 — Verify
```bash
python -m pytest tests/ -x -q 2>/dev/null || npm test 2>/dev/null
```
Tests must pass after every step. If they fail, revert the step and diagnose before continuing.

Also run type checker if applicable:
```bash
mypy src/ 2>/dev/null || npx tsc --noEmit 2>/dev/null
```

## Step 5 — Commit atomically
Each refactor type is one commit. Commit message format:
```
refactor(scope): describe what was restructured

No behavior change. Tests pass.
```

## Step 6 — Repeat for next change
Do not compound multiple refactor types into one step. Slow is safe.

## Hard rules
- Never refactor and fix a bug in the same commit
- Never rename and move in the same commit — rename first, then move
- Never change a public API signature without updating all callers in the same commit
- If a refactor requires touching tests, the tests must still test the same behavior
- Stop immediately if confidence drops — partial refactors are worse than no refactor
