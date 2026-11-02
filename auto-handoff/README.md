# auto-handoff

auto-handoff is a Claude Code skill. When a session passes a token limit, Claude asks whether you want to hand off. If you type `/handoff`, Claude writes a handoff document, ends the session and opens a new chat on that document in the same terminal window.

## Requirements

You need:

- Claude Code (tested on version 2.1.316)
- `jq`
- zsh or bash

It was tested on macOS with zsh.

## Install

1. Run `npx skills add MarShaikh/claude-skills --skill auto-handoff -g -a claude-code`, or copy this folder to `~/.claude/skills/auto-handoff`.
2. Start Claude Code and type `/auto-handoff`.
3. Open a new terminal window and start Claude Code again.

The installer adds a Stop hook to `~/.claude/settings.json` and backs up the old file first. It also adds a `claude` function to `~/.zshrc` or `~/.bashrc`, and a `/handoff` command if you do not already have one, either on its own or from a plugin. You can run it more than once without making duplicates.

## Change the token limit

The default limit is 150000 tokens. To change it, type `/auto-handoff 120000` with the number you want.

## Known limits

The chat switches only when Claude saves the handoff document with its Write tool. The `/handoff` command included here tells Claude to do that. If you use your own `/handoff` command, check that it does the same.

Claude asks once per session, even if you choose to keep going.

The switch works only in sessions you start with the `claude` command in a terminal, because it relies on the shell function. Sessions started any other way stay open after `/handoff`.

## Remove

To remove auto-handoff, delete:

- the Stop hook entry for `auto-handoff.sh` in `~/.claude/settings.json`
- `~/.claude/hooks/auto-handoff.sh`
- the block that starts `# auto-handoff wrapper` in your shell config
- `~/.claude/handoff-threshold`
- `~/.claude/skills/handoff`, if the installer added it
