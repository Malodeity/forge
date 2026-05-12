# /security

Deep security audit against the current diff and codebase.

## Steps

### 1. Scan for secrets and credentials
```bash
grep -rn "password\|secret\|token\|api_key\|apikey\|private_key" src/ \
  --include="*.py" --include="*.js" --include="*.ts" \
  | grep -v "test\|spec\|mock\|example\|placeholder" | head -30
```
Flag: any hardcoded credential, even in test fixtures committed to the repo.

### 2. Injection vectors
```bash
# SQL injection
grep -rn "f\".*SELECT\|f'.*SELECT\|+.*WHERE\|\`.*WHERE" src/ | head -20
# Shell injection
grep -rn "os\.system\|subprocess.*shell=True\|exec(\|eval(" src/ | head -20
# Template injection
grep -rn "render_template_string\|Template(\|Markup(" src/ | head -20
```

### 3. Auth / authz gaps
- Find all routes/endpoints — does each have an auth decorator/middleware?
- Find all privileged operations — is the caller's role checked before execution?
- Check JWT handling: expiry enforced? signature verified? algorithm pinned?

### 4. Input validation gaps
- Find all places user input enters the system (HTTP body, query params, headers, file uploads)
- For each, confirm: type validation, length limit, format/range check
- Flag any that go directly to DB, file system, shell, or template engine

### 5. Dependency vulnerabilities
```bash
npm audit --audit-level=high 2>/dev/null || \
pip-audit --desc 2>/dev/null || \
trivy fs . 2>/dev/null || \
echo "Run: npm audit OR pip-audit OR trivy fs ."
```

### 6. Cryptographic weaknesses
- MD5 / SHA1 for password hashing → flag (use bcrypt/argon2)
- DES / 3DES / RC4 for encryption → flag (use AES-256-GCM)
- Hardcoded IV or salt → flag
- `random` for security purposes (not `secrets`/`crypto`) → flag

### 7. SSRF check
```bash
grep -rn "requests\.get\|httpx\.\|fetch(\|axios\." src/ | grep -v test | head -20
```
Flag: user-supplied URLs passed directly to HTTP client without allowlist.

### 8. Output
```
[CRITICAL] file:line — issue + remediation
[HIGH]     ...
[MEDIUM]   ...
[LOW]      ...
```
Summary line: pass/fail, issue count per severity, highest priority fix.
