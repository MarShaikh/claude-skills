---
name: markdown-files
description: Layout rules for writing or editing a Markdown file, such as an Obsidian note, runbook, README, ADR or doc. Use whenever creating or changing a .md file.
---

Markdown is read in a renderer: Obsidian, GitHub or an editor preview. Lay the file out so it reads well there, and let the renderer do the wrapping. The prose itself follows the writing style in the global `CLAUDE.md`.

## Line breaks

Write each paragraph, list item and blockquote paragraph as one line, however long. Obsidian shows every newline as a break, so a hard-wrapped paragraph renders as ragged short lines.

Separate paragraphs, lists, tables, headings and code blocks with one blank line.

When editing a file that already hard-wraps every paragraph at a fixed width, such as a repository doc, match its wrapping so the file stays consistent.

## Tables

Keep each cell to a short phrase, so every row scans on one line.

- When a cell needs a sentence of explanation, write that row as a short subsection with a heading and a paragraph, and keep the table for the rows that fit.
- When a cell needs a long literal value, such as a digest, full URL or command, put the value in a code block under the table and refer to it from the cell.
- Write each cell's value in full rather than "same" or "as above", so a row reads on its own.

## Steps

Give each numbered step one action. Split a step that joins 2 actions into 2 steps. Use numbered lists only for steps that must happen in order.

## Code blocks

Write one command per line, exactly as it runs in sequence. A command that changes the shell, such as `sudo -i` or `cd`, goes on its own line before the commands that depend on it. Tag each block with its language, such as `bash`, `json` or `text`.

## Before finishing

Read the file as it will render and check:

- every paragraph and list item is a single line, unless the file already hard-wraps
- every table row scans on one line
- every code block runs top to bottom as written
