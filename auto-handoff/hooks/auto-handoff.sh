#!/usr/bin/env bash
# Claude Code Stop hook for handing a long session over to a fresh one.
#
# 1. After /handoff writes its doc: save the doc path to $CLAUDE_HANDOFF_FILE
#    and end this Claude Code process, so the `claude` shell function can
#    start a new session on the doc. Does nothing unless Claude was started
#    through that function.
# 2. Otherwise, the first time the context passes the threshold in a session,
#    keep Claude going and have it ask whether to hand off.
#
# Threshold: ~/.claude/handoff-threshold, default 150000 tokens.
set -u

input=$(cat)
session_id=$(jq -r '.session_id' <<<"$input")
transcript=$(jq -r '.transcript_path' <<<"$input")
[ -f "$transcript" ] || exit 0

# File written by the last Write call, if the latest typed prompt was /handoff.
# A /handoff from a plugin is recorded with its prefix, such as
# /mattpocock-skills:handoff, so accept any prefix.
doc=$(jq -rs '
  (map(.type == "user" and .isMeta != true
       and (.message.content | type == "string")) | rindex(true)) as $i
  | if $i != null and (.[$i].message.content | test("<command-name>/([A-Za-z0-9_-]+:)?handoff</command-name>"))
    then [.[$i:][] | select(.type == "assistant") | .message.content[]
          | select(.type == "tool_use" and .name == "Write") | .input.file_path] | last // empty
    else empty end
' "$transcript")

if [ -n "$doc" ]; then
  if [ -n "${CLAUDE_HANDOFF_FILE:-}" ] && [ -n "${CLAUDE_PID:-}" ]; then
    printf '%s' "$doc" > "$CLAUDE_HANDOFF_FILE"
    kill -TERM "$CLAUDE_PID"
  fi
  exit 0
fi

marker="${TMPDIR:-/tmp}/claude-handoff-asked-$session_id"
[ -e "$marker" ] && exit 0

threshold=$(cat "$HOME/.claude/handoff-threshold" 2>/dev/null || echo 150000)
tokens=$(jq -rs '
  [.[] | select(.type == "assistant" and .isSidechain != true and .message.usage != null)]
  | last | .message.usage
  | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0)
' "$transcript" 2>/dev/null)
[ "${tokens:-0}" -ge "$threshold" ] 2>/dev/null || exit 0

touch "$marker"
jq -n --arg t "$tokens" --arg l "$threshold" '{
  decision: "block",
  reason: "The context is at \($t) tokens, past the handoff threshold of \($l). Use AskUserQuestion to ask the user whether to hand off to a new chat or keep going in this one. If they choose to hand off, tell them to type /handoff. Do nothing else."
}'
