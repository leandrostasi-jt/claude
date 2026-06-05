#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
timestamp="$(date +%Y%m%d%H%M%S)"

case "$(uname -s)" in
  Darwin|Linux)
    user_home="${HOME:?HOME is required}"
    ;;
  CYGWIN*|MINGW*|MSYS*)
    user_home="${HOME:-${USERPROFILE:?HOME or USERPROFILE is required}}"
    ;;
  *)
    echo "Unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

claude_home="${CLAUDE_HOME:-$user_home/.claude}"

install_file() {
  local src="$1"
  local dst="$2"
  local dst_dir

  dst_dir="$(dirname "$dst")"
  mkdir -p "$dst_dir"

  if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
    cp "$dst" "$dst.bak.$timestamp"
    echo "Backed up $dst to $dst.bak.$timestamp"
  fi

  cp "$src" "$dst"
}

install_dir() {
  local src="$1"
  local dst="$2"

  mkdir -p "$dst"
  cp -R "$src"/. "$dst"/
}

verify_path() {
  local path="$1"

  if [ ! -e "$path" ]; then
    echo "Missing expected path: $path" >&2
    return 1
  fi
}

echo "Installing Claude Code configuration to $claude_home"

mkdir -p "$claude_home"

install_file "$repo_root/CORE.md" "$claude_home/CORE.md"
install_file "$repo_root/CLAUDE.md" "$claude_home/CLAUDE.md"
install_file "$repo_root/claude-code/settings.json" "$claude_home/settings.json"
install_file "$repo_root/claude-code/keybindings.json" "$claude_home/keybindings.json"

install_dir "$repo_root/agents" "$claude_home/agents"
install_dir "$repo_root/skills" "$claude_home/skills"
install_dir "$repo_root/rules" "$claude_home/rules"
install_dir "$repo_root/commands" "$claude_home/commands"

verify_path "$claude_home/CORE.md"
verify_path "$claude_home/CLAUDE.md"
verify_path "$claude_home/agents/planner.md"
verify_path "$claude_home/skills/execute-plan/SKILL.md"
verify_path "$claude_home/rules/common/output-budget.md"
verify_path "$claude_home/commands/create-plan.md"
verify_path "$claude_home/settings.json"
verify_path "$claude_home/keybindings.json"

echo "Claude Code install verified."
echo "Restart Claude Code to reload agents, skills, commands, and settings."
