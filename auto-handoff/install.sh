#!/usr/bin/env bash
# Install auto-handoff for the current user. Safe to run more than once.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
claude_dir="$HOME/.claude"

command -v jq >/dev/null || { echo "auto-handoff needs jq. Install it, then run this again." >&2; exit 1; }

# Hook script
mkdir -p "$claude_dir/hooks"
install -m 755 "$here/hooks/auto-handoff.sh" "$claude_dir/hooks/auto-handoff.sh"
echo "Installed the hook at $claude_dir/hooks/auto-handoff.sh"

# Register the hook as a Stop hook. Writes through a symlinked settings.json.
settings="$claude_dir/settings.json"
[ -f "$settings" ] || echo '{}' > "$settings"
hook_cmd='"$HOME/.claude/hooks/auto-handoff.sh"'
if jq -e --arg c "$hook_cmd" '[.hooks.Stop[]?.hooks[]?.command] | index($c)' "$settings" >/dev/null; then
  echo "The Stop hook is already registered in $settings"
else
  cp "$settings" "$settings.bak-auto-handoff"
  updated=$(jq --arg c "$hook_cmd" '.hooks.Stop += [{hooks: [{type: "command", command: $c}]}]' "$settings")
  printf '%s\n' "$updated" > "$settings"
  echo "Registered the Stop hook in $settings (backup at $settings.bak-auto-handoff)"
fi

# /handoff command, unless the user already has one
if [ -e "$claude_dir/skills/handoff" ] || [ -e "$claude_dir/commands/handoff.md" ]; then
  echo "Kept your existing /handoff command. Make sure it saves the doc with the Write tool."
else
  mkdir -p "$claude_dir/skills"
  cp -R "$here/handoff" "$claude_dir/skills/handoff"
  echo "Installed the /handoff command at $claude_dir/skills/handoff"
fi

# Token limit
if [ -f "$claude_dir/handoff-threshold" ]; then
  echo "Kept your token limit of $(cat "$claude_dir/handoff-threshold")"
else
  echo 150000 > "$claude_dir/handoff-threshold"
  echo "Set the token limit to 150000"
fi

# Shell wrapper that opens the new session in the same window
case "$(basename "${SHELL:-}")" in
  zsh) rc="$HOME/.zshrc" ;;
  bash) rc="$HOME/.bashrc" ;;
  *) rc="" ;;
esac
if [ -z "$rc" ]; then
  echo "Your shell is not zsh or bash. Add the claude function from $here/install.sh to your shell config by hand."
elif grep -q '# auto-handoff wrapper' "$rc" 2>/dev/null; then
  echo "The claude wrapper is already in $rc"
else
  cat >> "$rc" <<'EOF'

# auto-handoff wrapper: when /handoff ends a Claude Code session, the
# auto-handoff hook leaves the doc path in $CLAUDE_HANDOFF_FILE, and this
# starts a new session on that doc in the same window.
claude() {
  local next doc
  next=$(mktemp)
  CLAUDE_HANDOFF_FILE=$next command claude "$@"
  while [ -s "$next" ]; do
    doc=$(cat "$next")
    : > "$next"
    CLAUDE_HANDOFF_FILE=$next command claude "Read the handoff document at $doc and continue from it."
  done
  rm -f "$next"
}
EOF
  echo "Added the claude wrapper to $rc"
fi

echo
echo "Done. Open a new terminal window, or run: source ${rc:-your shell config}"
echo "Then start Claude Code again. Sessions you started before this will not switch."
