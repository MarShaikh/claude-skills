---
name: auto-handoff
description: Set up Claude Code to ask about a handoff when a session passes a token limit, and to open a new chat on the handoff doc in the same terminal window. Also changes the token limit.
argument-hint: "Empty to install, or a token limit such as 120000"
disable-model-invocation: true
---

With no arguments, install auto-handoff. Run `bash install.sh` from this skill's base directory and show the user its output. Then tell them to open a new terminal window, or source the shell config the script names, and restart Claude Code. The current session was not started through the new `claude` wrapper, so it cannot switch.

With a number as the argument, change the token limit. Write the number as a plain integer to `~/.claude/handoff-threshold`, replacing its contents. Convert shorthand such as "120k" to 120000. The new limit applies from the next turn in every session, but a session that has already asked will not ask again.

## How it works

The installer sets up four pieces:

- a Stop hook at `~/.claude/hooks/auto-handoff.sh`, registered in `~/.claude/settings.json`
- a `/handoff` command in `~/.claude/skills/handoff`, unless the user already has one
- the token limit in `~/.claude/handoff-threshold`, 150000 by default
- a `claude` shell function in `~/.zshrc` or `~/.bashrc`

After each turn, the hook reads the context size from the transcript. The first time it passes the limit, the hook has Claude ask whether to hand off. If the user types `/handoff`, Claude writes the doc with the Write tool. The hook then saves the doc path to the file in `$CLAUDE_HANDOFF_FILE` and ends Claude Code with SIGTERM. The shell function sees the path and starts a new session that reads the doc.

The hook uses `jq` and the `CLAUDE_PID` variable that Claude Code sets. It was tested on macOS with zsh and Claude Code 2.1.316.
