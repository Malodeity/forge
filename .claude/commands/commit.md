# /commit

Stage and commit changed files with a conventional commit message, then push.

## Steps

1. Run `git status` to see what's changed
2. Run `git diff` to understand the nature of the changes
3. Run `git log --oneline -5` to match this repo's commit style
4. Stage only relevant files — never `git add -A` blindly; exclude `.env`, secrets, lock files unless explicitly changed intentionally
5. Write a commit message in format: `type(scope): short description`
   - Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`
   - Subject line under 72 chars
   - No period at end
6. Commit using a HEREDOC to preserve formatting
7. Push with `git push -u origin <current-branch>`

## Rules
- Never use `--no-verify`
- Never amend a pushed commit
- If pre-commit hook fails, fix the issue then create a NEW commit
- Do not push to `main` or `master` directly
