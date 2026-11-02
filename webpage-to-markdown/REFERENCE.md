# Defuddle reference

Advanced usage beyond [SKILL.md](SKILL.md).

## Options passed to `Defuddle(document, url, options)`

| Option | Effect |
|--------|--------|
| `markdown: true` | Return `content` as Markdown instead of cleaned HTML |
| `debug: true` | Verbose logging about extraction decisions |
| `url` (3rd arg) | Base URL — needed to resolve relative links/images correctly |

Always pass the real page URL as the third argument so relative links and image `src` values resolve to absolute URLs in the output.

## DOM backends

- **linkedom** — fast, lightweight, good default for server-side extraction.
- **jsdom** — heavier but more spec-complete; use if linkedom mis-parses a page.

```javascript
// jsdom variant
import { JSDOM } from 'jsdom';
import { Defuddle } from 'defuddle/node';

const dom = new JSDOM(html, { url });
const result = await Defuddle(dom.window.document, url, { markdown: true });
```

## JS-rendered pages (SPAs)

Defuddle only sees the HTML you hand it. If a page renders content with client-side
JavaScript, `fetch()` returns an near-empty shell. Render it first with Playwright:

```bash
npm install playwright defuddle linkedom
npx playwright install chromium
```

```javascript
import { chromium } from 'playwright';
import { parseHTML } from 'linkedom';
import { Defuddle } from 'defuddle/node';

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto(url, { waitUntil: 'networkidle' });
const html = await page.content();
await browser.close();

const { document } = parseHTML(html);
const result = await Defuddle(document, url, { markdown: true });
console.log(result.content);
```

## Batch extraction

Loop over URLs, write one Markdown file each. Keep concurrency low (2–4) to be polite.

```javascript
import { parseHTML } from 'linkedom';
import { Defuddle } from 'defuddle/node';
import { writeFile } from 'node:fs/promises';

const urls = [/* ... */];
for (const url of urls) {
  const html = await fetch(url).then((r) => r.text());
  const { document } = parseHTML(html);
  const { title, content } = await Defuddle(document, url, { markdown: true });
  const slug = (title || url).replace(/[^a-z0-9]+/gi, '-').toLowerCase().slice(0, 60);
  await writeFile(`${slug}.md`, `# ${title}\n\n${content}`);
}
```

## Result object

| Property | Description |
|----------|-------------|
| `content` | Markdown (if `markdown:true`) or cleaned HTML |
| `title` | Article title |
| `description` | Summary / meta description |
| `author` | Author name |
| `published` | Publication date |
| `domain` | Site domain |
| `wordCount` | Word count of extracted content |
| `image` | Main/social image URL |
| `favicon` | Favicon URL |
| `language` | Page language (BCP 47) |
| `metaTags` | Extracted `<meta>` tags |
| `schemaOrgData` | Parsed schema.org JSON-LD |
| `parseTime` | Extraction time in ms |

## Troubleshooting

- **Empty/short `content`** → page is JS-rendered; use the Playwright recipe.
- **Broken relative links/images** → pass the page URL as the third argument.
- **`ERR_REQUIRE_ESM` / import errors** → set `"type": "module"` in `package.json`.
- **403 / blocked** → set a browser-like `User-Agent` header on `fetch`.
