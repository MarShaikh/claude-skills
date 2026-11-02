#!/usr/bin/env node
// Extract the main content of a web page as Markdown using Defuddle.
//
// Usage:
//   node url-to-markdown.mjs <url> [--json] [--property <name>]
//
// Requires: npm install defuddle linkedom
// Package.json must have "type": "module".

import { parseHTML } from 'linkedom';
import { Defuddle } from 'defuddle/node';

const args = process.argv.slice(2);
const url = args.find((a) => !a.startsWith('--') && a !== getFlagValue('--property'));
const asJson = args.includes('--json');
const property = getFlagValue('--property');

function getFlagValue(flag) {
  const i = process.argv.indexOf(flag);
  return i !== -1 ? process.argv[i + 1] : undefined;
}

if (!url) {
  console.error('Usage: node url-to-markdown.mjs <url> [--json] [--property <name>]');
  process.exit(1);
}

try {
  const res = await fetch(url, {
    headers: { 'User-Agent': 'Mozilla/5.0 (compatible; defuddle-skill)' },
  });
  if (!res.ok) throw new Error(`Fetch failed: ${res.status} ${res.statusText}`);

  const html = await res.text();
  const { document } = parseHTML(html);
  const result = await Defuddle(document, url, { markdown: true });

  if (property) {
    console.log(result[property] ?? '');
  } else if (asJson) {
    // Drop the heavy content field's duplication isn't needed; print everything.
    console.log(JSON.stringify(result, null, 2));
  } else {
    if (result.title) console.log(`# ${result.title}\n`);
    console.log(result.content);
  }
} catch (err) {
  console.error(`Error: ${err.message}`);
  process.exit(1);
}
