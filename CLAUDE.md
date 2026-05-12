# CLAUDE.md — forge framework repo

This is the **forge** source repo. The installable standards live in `templates/`.

## What this repo is
- `templates/CLAUDE.base.md` — the god-level engineering standards that get installed into user projects
- `templates/CLAUDE.*.md` — stack-specific additions (python, node, mobile, data, go, rust)
- `install.sh` — bash installer (`curl -fsSL ... | bash`)
- `bin/forge.js` — npm CLI (`npx forge init`)
- `.claude/commands/` — slash commands installed into user projects (also used in this repo)
- `templates/settings.json` — `.claude/settings.json` installed into user projects

## Stack
- Bash (install.sh)
- Node.js / CommonJS (bin/forge.js — minimal, no dependencies)
- Markdown (all templates and commands)

## Commands
| Task | Command |
|---|---|
| Make install.sh executable | `chmod +x install.sh` |
| Test install locally | `bash install.sh --dir /tmp/test-project` |
| Test npm CLI locally | `node bin/forge.js init --dir /tmp/test-project` |
| Validate JSON | `python -m json.tool templates/settings.json` |
| Count template lines | `wc -l templates/CLAUDE.base.md` |

## Development conventions
- `install.sh` must be POSIX-compatible bash — no bash 4+ features (`declare -A`, etc.)
- `bin/forge.js` must work with Node.js 18+ and zero npm dependencies
- Templates are markdown — no front-matter, no special syntax
- All download URLs use `${REPO_RAW}` variable — never hardcode paths
- Test with `--dir /tmp/test-<name>` to avoid polluting the repo

## Slash commands available
`/commit` `/ship` `/review` `/fix` `/context` `/design` `/arch` `/perf` `/security` `/data` `/refactor`

## Repo layout
```
templates/          What gets installed into user projects
  CLAUDE.base.md    Universal god-level standards
  CLAUDE.python.md  Python additions
  CLAUDE.node.md    Node.js/TypeScript additions
  CLAUDE.mobile.md  React Native + Flutter additions
  CLAUDE.data.md    Data engineering additions
  CLAUDE.go.md      Go additions
  CLAUDE.rust.md    Rust additions
  settings.json     .claude/settings.json for user projects
.claude/
  settings.json     Config for working on THIS repo
  commands/         Slash commands (installed into user projects too)
bin/
  forge.js          npx CLI entry point
install.sh          Universal bash installer
package.json        npm package manifest
```

## Hard rules
- Never force-push `main`
- Never skip hooks
- Keep `install.sh` idempotent — safe to run twice
- Keep templates under 700 lines total per file — density over length
