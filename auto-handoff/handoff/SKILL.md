---
name: handoff
description: Write a handoff document so a new Claude Code session can continue the current work.
argument-hint: "What the next session will focus on (optional)"
disable-model-invocation: true
---

Write a handoff document that lets a new agent continue this conversation's work without reading the transcript.

Save it as a Markdown file in the operating system's temporary directory, not in the project. Use the Write tool to save it, because the auto-handoff hook looks for a Write call to find the document and open the new session.

Include:

- what the user asked for and what has been done
- the current state, including anything unfinished or untested
- the next steps, in order
- decisions and user preferences from this session that the next agent needs
- skills the next agent should use

Point to commits, files, issues and other documents by path or URL instead of copying their contents. Leave out secrets, such as API keys and passwords, and personal information.

If the user passed arguments, treat them as what the next session will focus on and shape the document around that.
