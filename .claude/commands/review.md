# /review

Review the current diff for security issues and logic bugs.

## Steps

1. `git diff main...HEAD` to get all changes since branch diverged
2. For each changed file, check:

### Security checklist
- [ ] No hardcoded secrets, tokens, passwords, or API keys
- [ ] No SQL built via string concatenation (use parameterized queries)
- [ ] No shell commands built from user input (command injection)
- [ ] No `eval()` or `exec()` on untrusted input
- [ ] No path traversal (user input used in file paths without sanitization)
- [ ] No XSS vectors (unsanitized user data rendered in HTML)
- [ ] Auth/authz checks present where needed
- [ ] Sensitive data not logged

### Logic checklist
- [ ] Error paths handled correctly (no silent swallows)
- [ ] Edge cases: empty input, null/None, zero, large values
- [ ] Off-by-one errors in loops/slices
- [ ] Race conditions in async/concurrent code
- [ ] Resource leaks (unclosed files, DB connections, sockets)
- [ ] Correct use of mutability (no shared mutable state bugs)

## Output format
List each issue as: `[SEVERITY] file:line — description`
Severities: `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`, `INFO`
End with a one-line summary: pass/fail and issue count.
