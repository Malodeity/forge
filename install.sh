#!/usr/bin/env bash
# malodeity — God-level Claude Code engineering standards
# Usage: curl -fsSL https://raw.githubusercontent.com/Malodeity/Malodeity/main/install.sh | bash
# Or:    bash install.sh [--dir /path/to/project] [--stack python|node|mobile|data]
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/Malodeity/Malodeity/main"
TARGET_DIR="."
FORCE_STACK=""

# ── colours ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'
YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

log()  { echo -e "${BLUE}[malodeity]${NC} $*"; }
ok()   { echo -e "  ${GREEN}✓${NC} $*"; }
warn() { echo -e "  ${YELLOW}!${NC} $*"; }
err()  { echo -e "  ${RED}✗${NC} $*" >&2; exit 1; }

# ── arg parsing ───────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --dir)   TARGET_DIR="$2"; shift 2 ;;
    --stack) FORCE_STACK="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: install.sh [--dir PATH] [--stack python|node|mobile|data]"
      exit 0 ;;
    *) err "Unknown argument: $1" ;;
  esac
done

cd "$TARGET_DIR"

# ── downloader ────────────────────────────────────────────────────────────────
download() {
  local url="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if command -v curl &>/dev/null; then
    curl -fsSL "$url" -o "$dest" || err "Failed to download $url"
  elif command -v wget &>/dev/null; then
    wget -q "$url" -O "$dest" || err "Failed to download $url"
  else
    err "curl or wget is required"
  fi
}

download_text() {
  local url="$1"
  if command -v curl &>/dev/null; then
    curl -fsSL "$url" || err "Failed to fetch $url"
  else
    wget -q "$url" -O - || err "Failed to fetch $url"
  fi
}

# ── stack detection ───────────────────────────────────────────────────────────
detect_stack() {
  if [[ -n "$FORCE_STACK" ]]; then echo "$FORCE_STACK"; return; fi

  if [[ -f "pubspec.yaml" ]]; then echo "mobile-flutter"
  elif [[ -f "package.json" ]]; then
    if grep -q '"react-native"' package.json 2>/dev/null || \
       grep -q '"expo"' package.json 2>/dev/null; then
      echo "mobile-rn"
    else
      echo "node"
    fi
  elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || \
       [[ -f "setup.py" ]] || [[ -f "setup.cfg" ]]; then
    if grep -qiE "dbt|airflow|spark|pandas|polars|sqlalchemy" \
         requirements.txt pyproject.toml 2>/dev/null; then
      echo "data"
    else
      echo "python"
    fi
  elif [[ -f "go.mod" ]]; then echo "go"
  elif [[ -f "Cargo.toml" ]]; then echo "rust"
  elif ls ./*.csproj ./*.sln 2>/dev/null | head -1 &>/dev/null; then echo "dotnet"
  elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]] || \
       [[ -f "pom.xml" ]]; then echo "java"
  else echo "universal"
  fi
}

# ── install CLAUDE.md ─────────────────────────────────────────────────────────
install_claude_md() {
  local stack="$1"
  local tmp
  tmp=$(mktemp)

  # Base template
  download_text "${REPO_RAW}/templates/CLAUDE.base.md" > "$tmp"

  # Stack-specific addition
  case "$stack" in
    python)          download_text "${REPO_RAW}/templates/CLAUDE.python.md" >> "$tmp" ;;
    node)            download_text "${REPO_RAW}/templates/CLAUDE.node.md"   >> "$tmp" ;;
    mobile-rn)       download_text "${REPO_RAW}/templates/CLAUDE.mobile.md" >> "$tmp" ;;
    mobile-flutter)  download_text "${REPO_RAW}/templates/CLAUDE.mobile.md" >> "$tmp" ;;
    data)            download_text "${REPO_RAW}/templates/CLAUDE.data.md"   >> "$tmp"
                     download_text "${REPO_RAW}/templates/CLAUDE.python.md" >> "$tmp" ;;
  esac

  # Merge or install
  if [[ -f "CLAUDE.md" ]]; then
    warn "Existing CLAUDE.md found — prepending malodeity standards"
    local existing
    existing=$(cat CLAUDE.md)
    cat "$tmp" > CLAUDE.md
    echo "" >> CLAUDE.md
    echo "---" >> CLAUDE.md
    echo "" >> CLAUDE.md
    echo "$existing" >> CLAUDE.md
  else
    mv "$tmp" CLAUDE.md
  fi

  rm -f "$tmp"
  ok "CLAUDE.md installed (stack: $stack)"
}

# ── install .claude/ ──────────────────────────────────────────────────────────
install_claude_dir() {
  mkdir -p .claude/commands

  # Settings
  download "${REPO_RAW}/templates/settings.json" ".claude/settings.json"
  ok ".claude/settings.json"

  # Commands
  local commands=(commit ship review fix context design arch perf security data)
  for cmd in "${commands[@]}"; do
    download "${REPO_RAW}/.claude/commands/${cmd}.md" ".claude/commands/${cmd}.md"
  done
  ok ".claude/commands/ (${#commands[@]} commands)"
}

# ── install .claudeignore ─────────────────────────────────────────────────────
install_claudeignore() {
  if [[ -f ".claudeignore" ]]; then
    warn ".claudeignore already exists — skipping (manual merge if needed)"
  else
    download "${REPO_RAW}/.claudeignore" ".claudeignore"
    ok ".claudeignore"
  fi
}

# ── main ──────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${BOLD}malodeity${NC} — God-level Claude Code engineering standards"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  log "Detecting stack in $(pwd)..."
  local stack
  stack=$(detect_stack)
  log "Stack detected: ${BOLD}${stack}${NC}"
  echo ""

  install_claude_md "$stack"
  install_claude_dir
  install_claudeignore

  echo ""
  echo -e "${GREEN}${BOLD}✓ Installation complete${NC}"
  echo ""
  echo "Files installed:"
  echo "  CLAUDE.md"
  echo "  .claude/settings.json"
  echo "  .claude/commands/{commit,ship,review,fix,context,design,arch,perf,security,data}"
  echo "  .claudeignore"
  echo ""
  echo "Slash commands available in Claude Code:"
  echo "  /commit   Stage + conventional commit + push"
  echo "  /ship     lint → test → commit → push"
  echo "  /review   Security + logic review of diff"
  echo "  /fix      Diagnose failing test/lint, fix root cause"
  echo "  /context  Print full session orientation"
  echo "  /design   System design analysis"
  echo "  /arch     Architecture review"
  echo "  /perf     Performance audit"
  echo "  /security Deep security audit"
  echo "  /data     Data engineering review"
  echo ""
  echo -e "Start ${BOLD}claude${NC} in this directory. Claude will follow the standards."
  echo ""
}

main
