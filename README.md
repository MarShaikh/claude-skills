# claude-skills

These are the Claude Code skills I use and share. Each folder holds one skill, and its own README or `SKILL.md` explains what it does.

| Skill | What it does |
| --- | --- |
| [auto-handoff](auto-handoff/README.md) | asks whether to hand off when a session passes a token limit, then opens a new chat on the handoff doc in the same terminal window |

## Install a skill

Clone the repo and copy the skill's folder into `~/.claude/skills`:

```sh
git clone https://github.com/MarShaikh/claude-skills
cp -R claude-skills/auto-handoff ~/.claude/skills/
```

To pick up updates with `git pull`, symlink the folder instead of copying it:

```sh
ln -s "$PWD/claude-skills/auto-handoff" ~/.claude/skills/auto-handoff
```

Some skills need a setup step after this. Check the skill's README.
