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

codex_home="${CODEX_HOME:-$user_home/.codex}"
agents_home="${AGENTS_HOME:-$user_home/.agents}"

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

echo "Installing OpenAI Codex configuration to $codex_home"
echo "Installing shared skills and rules to $agents_home"

mkdir -p "$codex_home" "$agents_home"

install_file "$repo_root/CORE.md" "$codex_home/CORE.md"
install_file "$repo_root/codex/AGENTS.md" "$codex_home/AGENTS.md"

if [ -f "$codex_home/config.toml" ]; then
  install_file "$repo_root/codex/config.toml" "$codex_home/config.claude-shared.example.toml"
  echo "Existing $codex_home/config.toml left unchanged."
  echo "Review $codex_home/config.claude-shared.example.toml if you want the optional fallback settings."
else
  install_file "$repo_root/codex/config.toml" "$codex_home/config.toml"
fi

"$repo_root/scripts/generate-codex-agents.sh" "$codex_home/agents"

install_dir "$repo_root/codex/prompts" "$codex_home/prompts"
install_dir "$repo_root/agents" "$agents_home/agents"
install_dir "$repo_root/skills" "$agents_home/skills"
install_dir "$repo_root/rules" "$agents_home/rules"
install_dir "$repo_root/commands" "$agents_home/commands"

verify_path "$codex_home/CORE.md"
verify_path "$codex_home/AGENTS.md"
verify_path "$codex_home/agents/planner.toml"
verify_path "$codex_home/agents/implementer.toml"
verify_path "$codex_home/prompts/sdd-start.md"
verify_path "$agents_home/skills/execute-plan/SKILL.md"
verify_path "$agents_home/rules/common/output-budget.md"

if [ ! -f "$codex_home/config.toml" ] && [ ! -f "$codex_home/config.claude-shared.example.toml" ]; then
  echo "Missing Codex config or example config under $codex_home" >&2
  exit 1
fi

echo "OpenAI Codex install verified."
echo "Restart Codex to reload global guidance, skills, prompts, and custom agents."
