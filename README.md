# claude-skills

These are the Claude Code skills I use and share. Each folder holds one skill, and its own README or `SKILL.md` explains what it does.

| Skill | What it does |
| --- | --- |
| [auto-handoff](auto-handoff/README.md) | asks whether to hand off when a session passes a token limit, then opens a new chat on the handoff doc in the same terminal window |
| [understand-this-change](understand-this-change/SKILL.md) | teaches you a piece of code, such as a diff an agent just wrote, one question at a time until you understand it |
| [webpage-to-markdown](webpage-to-markdown/SKILL.md) | turns a web page into clean Markdown with Defuddle, without the navigation, ads and other clutter |

## Install skills with npx

The [skills CLI](https://github.com/vercel-labs/skills) installs skills straight from this repo, so you do not need to clone it. It needs Node.js 22.20 or later.

To choose skills from a list:

```sh
npx skills add MarShaikh/claude-skills -g -a claude-code
```

To install one skill without any prompts:

```sh
npx skills add MarShaikh/claude-skills --skill auto-handoff -g -a claude-code -y
```

To install every skill in the repo:

```sh
npx skills add MarShaikh/claude-skills --skill '*' -g -a claude-code -y
```

The `-g` flag installs skills for all your projects instead of only the current one. `-a claude-code` installs them for Claude Code, and `-y` skips the prompts.

These commands help after you install:

- `npx skills add MarShaikh/claude-skills --list` lists the skills in this repo without installing them
- `npx skills update -g` gets newer versions of the skills you installed
- `npx skills remove --global auto-handoff` removes a skill

## Setup after installing

understand-this-change and webpage-to-markdown work as soon as they are installed.

auto-handoff needs one more step. Type `/auto-handoff` in Claude Code, then open a new terminal window. The skills CLI only copies files, and auto-handoff also needs a Stop hook in `~/.claude/settings.json` and a `claude` function in your shell config. Its installer adds both and is safe to run again.

## Install without Node

Clone the repo and copy the skill's folder into `~/.claude/skills`:

```sh
git clone https://github.com/MarShaikh/claude-skills
cp -R claude-skills/auto-handoff ~/.claude/skills/
```

To pick up updates with `git pull`, symlink the folder instead of copying it:

```sh
ln -s "$PWD/claude-skills/auto-handoff" ~/.claude/skills/auto-handoff
```
