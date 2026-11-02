---
name: webpage-to-markdown
description: Extract the main content of any web page as clean Markdown, stripping nav, ads, and clutter, using Defuddle. Use when the user wants to convert a URL or webpage to markdown, clip/save an article, scrape readable content, or extract page metadata (title, author, published date).
---

# Webpage to Markdown

Convert any web page link into clean Markdown using [Defuddle](https://www.npmjs.com/package/defuddle), which extracts the main article content and strips navigation, ads, sidebars, and comments.

Pick the method by need:

| Need | Method |
|------|--------|
| Quick one-off, no install | Hosted service (`defuddle.md`) |
| Local files or scripting in a shell | CLI (`npx defuddle`) |
| Programmatic / batch / custom processing | Node library |

## Quick start (hosted, zero install)

Prepend `defuddle.md/` to any URL to get Markdown back:

```bash
curl https://defuddle.md/https://example.com/article
```

Returns Markdown with a YAML frontmatter block (`title`, `source`, `language`, `word_count`). Use this when you just need the content fast and the page is publicly reachable.

## CLI

```bash
# Parse a URL to markdown (stdout)
npx defuddle parse https://example.com/article --markdown

# Save markdown to a file
npx defuddle parse https://example.com/article -m -o article.md

# Full JSON with metadata + content
npx defuddle parse https://example.com/article --json

# Extract one property only
npx defuddle parse https://example.com/article --property title
```

Flags: `-m`/`--markdown` (markdown output), `-o <file>` (write to file), `-j`/`--json` (JSON with metadata), `-p <name>`/`--property` (single field), `-l <code>`/`--lang` (preferred language, BCP 47), `--debug`.

Source can be a URL **or** a local `.html` file path. Install globally with `npm install -g defuddle` if used often.

## Node library

Use for batch jobs, post-processing, or integrating into an app. Defuddle needs a DOM, so pair it with `linkedom` (lightweight) or `jsdom`.

```bash
npm install defuddle linkedom
```

Requires `"type": "module"` in `package.json`. See [scripts/url-to-markdown.mjs](scripts/url-to-markdown.mjs) for a ready-to-run script:

```bash
node scripts/url-to-markdown.mjs https://example.com/article > article.md
```

Core API:

```javascript
import { parseHTML } from 'linkedom';
import { Defuddle } from 'defuddle/node';

const html = await fetch(url).then(r => r.text());
const { document } = parseHTML(html);
const result = await Defuddle(document, url, { markdown: true });
// result.content is Markdown when markdown:true; otherwise cleaned HTML
```

## Result properties

`content` (markdown or cleaned HTML), `title`, `description`, `author`, `published`, `domain`, `wordCount`, `image`, `favicon`, `language`, `metaTags`, `schemaOrgData`, `parseTime`.

## Notes

- Defuddle works on the **rendered HTML it is given** — JS-heavy SPAs that load content client-side may yield little. For those, fetch with a headless browser first, then pass the rendered HTML to `Defuddle`.
- Authenticated/paywalled pages won't extract unless you supply authenticated HTML.
- See [REFERENCE.md](REFERENCE.md) for the JS-rendered-page recipe and advanced options.
