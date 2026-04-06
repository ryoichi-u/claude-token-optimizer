#!/bin/bash
set -euo pipefail

# Claude Token Optimizer — Installer
# Copies selected command files to a target project's .claude/commands/ directory.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMANDS_DIR="$SCRIPT_DIR/commands"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Defaults
MODE="all"
TARGET_DIR="."

usage() {
  cat <<'USAGE'
Usage: ./install.sh [OPTIONS] [--target <project-path>]

Options:
  --all          Install all commands (default)
  --pick         Interactively select which commands to install
  --target PATH  Target project directory (default: current directory)
  --list         List available commands and exit
  -h, --help     Show this help

Examples:
  ./install.sh --target ~/my-project
  ./install.sh --pick --target ~/my-project
  ./install.sh --list
USAGE
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)    MODE="all"; shift ;;
    --pick)   MODE="pick"; shift ;;
    --list)   MODE="list"; shift ;;
    --target) TARGET_DIR="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# Resolve target
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
  echo "Error: Target directory does not exist: $TARGET_DIR"
  exit 1
}
DEST="$TARGET_DIR/.claude/commands"

# List available commands
list_commands() {
  echo "Available commands:"
  echo ""
  for f in "$COMMANDS_DIR"/*.md; do
    name="$(basename "$f" .md)"
    desc="$(grep '^description:' "$f" | head -1 | sed 's/^description: *//')"
    printf "  %-20s %s\n" "/$name" "$desc"
  done
}

if [[ "$MODE" == "list" ]]; then
  list_commands
  exit 0
fi

echo "Claude Token Optimizer — Installer"
echo "==================================="
echo ""
echo "Target: $TARGET_DIR"
echo ""

# Ensure destination exists
mkdir -p "$DEST"

# Collect files to install
declare -a TO_INSTALL=()

if [[ "$MODE" == "all" ]]; then
  for f in "$COMMANDS_DIR"/*.md; do
    TO_INSTALL+=("$f")
  done
elif [[ "$MODE" == "pick" ]]; then
  list_commands
  echo ""
  echo "Enter command names to install (space-separated, without /):"
  echo "Example: token-audit optimize-context tool-diet"
  echo ""
  read -r -p "> " selections
  for name in $selections; do
    f="$COMMANDS_DIR/${name}.md"
    if [[ -f "$f" ]]; then
      TO_INSTALL+=("$f")
    else
      echo "Warning: $name not found, skipping"
    fi
  done
fi

if [[ ${#TO_INSTALL[@]} -eq 0 ]]; then
  echo "No commands selected. Exiting."
  exit 0
fi

# Install
installed=0
skipped=0

for f in "${TO_INSTALL[@]}"; do
  name="$(basename "$f")"
  dest_file="$DEST/$name"

  if [[ -f "$dest_file" ]]; then
    echo "  [skip] $name (already exists)"
    ((skipped++))
  else
    cp "$f" "$dest_file"
    echo "  [install] $name"
    ((installed++))
  fi
done

# Copy learning log template if not present
LOG_CANDIDATES=(
  "$TARGET_DIR/docs/context-optimization-log.jsonl"
  "$TARGET_DIR/.claude/context-optimization-log.jsonl"
)

log_exists=false
for lf in "${LOG_CANDIDATES[@]}"; do
  if [[ -f "$lf" ]]; then
    log_exists=true
    break
  fi
done

if ! $log_exists; then
  mkdir -p "$TARGET_DIR/docs"
  cp "$TEMPLATES_DIR/context-optimization-log.jsonl" "$TARGET_DIR/docs/context-optimization-log.jsonl"
  echo "  [create] docs/context-optimization-log.jsonl (learning log template)"
fi

echo ""
echo "Done! Installed: $installed, Skipped: $skipped"
echo ""
echo "Usage in Claude Code:"
for f in "${TO_INSTALL[@]}"; do
  name="$(basename "$f" .md)"
  echo "  /$name"
done
