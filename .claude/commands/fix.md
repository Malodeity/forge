# /fix

Diagnose a failing test or lint error, fix the root cause, and verify.

## Steps

1. Run the failing command to capture the exact error output
   - Tests: `python -m pytest tests/ -x -q` or `npm test`
   - Lint: `ruff check src/` or `npm run lint`
2. Read the error message fully — identify file, line, and error type
3. Read the failing code at that location
4. Identify root cause — do not treat symptoms
5. Apply the minimal fix — do not refactor surrounding code
6. Re-run the failing command to confirm it passes
7. Run the full test suite to check for regressions
8. If the fix requires touching more than 3 files, pause and explain the scope before proceeding

## Rules
- Fix root cause, not symptom
- No drive-by refactors
- If the test itself is wrong, flag it and ask before changing the test
- If the fix is unclear after 2 attempts, stop and explain what you found
