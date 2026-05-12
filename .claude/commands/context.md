# /context

Dump current repository state so a new session can orient instantly.

## Steps

Run these commands and present the output:

```bash
git branch --show-current
git log --oneline -10
git status --short
git diff --stat HEAD~1
grep -r "TODO\|FIXME\|HACK\|XXX" src/ --include="*.py" --include="*.js" --include="*.ts" -n 2>/dev/null | head -20
```

## Output format

```
Branch: <name>
Last 10 commits:
<log>

Uncommitted changes:
<status>

Recent diff summary:
<diff stat>

Open TODOs:
<grep results>
```

This gives any new Claude session full orientation in one command with zero file exploration.
