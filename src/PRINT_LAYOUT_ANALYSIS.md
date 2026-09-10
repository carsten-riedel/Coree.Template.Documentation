# Print layout analysis

Status: decision basis for a future product change

Analyzed product source: `DocTemplate.html` version 3.2.3

Research and validation date: 2026-09-10

## Decision

The product should gain an adaptive CSS print layer in version 3.3.0. It should
remain part of the existing `documentation/css/documentation.css` payload and
should not add another stylesheet, runtime dependency, build mode, or print
button.

The recommended baseline is:

- use `@media print` for print-only presentation;
- use `@page { size: auto; margin: 15mm; }` so the print dialog remains the
  authority for A4, Letter, orientation, and printer choice;
- hide the navbar and copy controls;
- remove the screen card, shadow, rounded corners, page background, fixed content
  width, and scroll behavior;
- keep headings with the first following content instead of forcing every
  section onto a new page;
- wrap long code and unbreakable text rather than clipping it;
- keep table rows, blockquotes, and diagrams together when they fit, while still
  allowing oversized content to continue on another page;
- use a light, high-contrast print palette that does not require background
  graphics;
- apply the packaged light Highlight.js theme to print;
- render Mermaid with its global `neutral` theme so a document opened in dark
  mode still produces a print-oriented diagram.

This is a backward-compatible feature and therefore a minor version under the
repository's versioning rules.

## Current product behavior

The current CSS payload has responsive screen rules but no `@media print` or
`@page` rule. Several existing choices therefore become print defects:

| Current behavior | Print result |
| --- | --- |
| `html` reserves a scrollbar gutter and `pre` uses `overflow-x: auto` | Long code is clipped and Chromium can print a horizontal scrollbar |
| The navbar is sticky and copy buttons are interactive overlays | Both controls appear on paper and consume space |
| The page uses a 58-rem card with outer background, border, radius, and shadow | Paper retains screen chrome and a narrower content column |
| Headings have screen spacing only | A heading can be left alone at the bottom of a page |
| Highlight.js themes are imported only for `screen` | Printed fenced code has no deliberately selected syntax theme |
| Mermaid chooses `dark` or `default` from `prefers-color-scheme` at render time | A page opened in dark mode prints a dark diagram on a light sheet |
| Tables rely on automatic layout | Long tokens can widen cells; repeated headers are not guaranteed |

The 3.2.3 CSS payload is byte-for-byte equivalent after line-ending
normalization to the fully materialized 3.2.1 test workspace, with SHA-256
`FD003460B07DD65E0B19DC7D8580DC3C9BB2D9B7C3B044E0A0C4297451A28154`.
The intervening product changes do not affect layout, so that workspace is a
valid print fixture for the current CSS.

## Empirical baseline

The materialized 3.2.1 `Documentation.html` was printed with Chrome 152 on
Windows under a dark color preference.

The current stylesheet produced a 36-page Letter PDF. Visual inspection found:

1. the navbar and mobile toggle on the first page;
2. visible Copy labels inside code blocks;
3. clipped long code lines and printed horizontal scrollbars;
4. `Future documentation writing guide` alone at the bottom of a page;
5. a dark Mermaid diagram with low-contrast gray labels;
6. a table continuing on the next page without a repeated header row.

A temporary CSS-only prototype removed the screen chrome, kept headings with
following content, and wrapped all observed code and table content. It produced
38 Letter pages and 35 A4 pages. The increased Letter page count is the expected
cost of retaining long code by wrapping it. The same stylesheet adapted to both
physical sizes without a size-specific branch.

Changing only Mermaid's global theme to `neutral` produced a readable diagram
both on the dark screen surface and in the light A4 PDF. It did not change the
page count.

These checks prove the proposed direction in Chromium. They do not establish
pixel-identical pagination across browsers, operating systems, installed fonts,
or printer drivers.

## Required behavior

### Paper and page area

The supported baseline should be A4 and North American Letter in portrait
orientation. A4 is 210 x 297 mm; Letter is 8.5 x 11 inches, or approximately
215.9 x 279.4 mm.[^1] With 15-mm margins, their usable page areas are:

| Paper | Usable width | Usable height |
| --- | ---: | ---: |
| A4 | 180 mm | 267 mm |
| Letter | 185.9 mm | 249.4 mm |

The widths differ by only 5.9 mm, while Letter is 17.6 mm shorter. The layout
must therefore tolerate different break positions rather than trying to preserve
the same page count.

`size: auto` lets the user agent match the selected sheet. CSS cannot reliably
select an `@page size` in response to a paper-width media query; the Paged Media
specification explicitly requires size declarations conditioned on paper size
to be ignored.[^1] A fixed `size: A4` would make European output predictable at
the cost of scaling or mismatching Letter. A fixed `size: Letter` has the inverse
problem.

Landscape should remain a print-dialog choice. Automatically rotating every
document to accommodate one wide table would make ordinary prose waste paper.
A later, explicit authoring convention could introduce a named landscape page
for exceptional tables, but that is outside the generic Markdown baseline.

### Heading and paragraph breaks

The product should not force a page break before every `h1`, `h2`, or `h3`.
Every HTML file already begins with one `h1`, and forced breaks on lower
headings would create large gaps and potentially blank pages.

The correct default is `break-after: avoid-page` on `h1` through `h3`. This asks
the formatter to keep a heading with the first following block. The legacy
`page-break-after: avoid` declaration is a small compatibility fallback; the
CSS Fragmentation specification defines the older page-break properties as
aliases of the modern break properties.[^2]

`orphans: 3` and `widows: 3` on paragraphs and list items improve prose without
creating forced breaks. These values are constraints that a formatter may relax
when necessary to make progress; the CSS model intentionally treats many
avoidance rules as preferences rather than absolute guarantees.[^2]

### Content overflow

Print has no usable horizontal scroll area. Every content category needs an
explicit policy:

| Content | Baseline policy | Remaining limit |
| --- | --- | --- |
| Paragraphs, links, and inline code | `overflow-wrap: anywhere` within the documentation content | A single unbreakable glyph or an authored fixed-width element can still overflow |
| Fenced code | `white-space: pre-wrap`, `overflow-wrap: anywhere`, and `overflow: visible` | Visual line wrapping changes the apparent command layout but preserves all characters |
| Short code blocks | Allow normal pagination | A generic selector cannot know whether a block is short before layout |
| Full-file code payloads | Permit fragmentation across pages | Borders are sliced across fragments; this is preferable to clipping or a mostly blank preceding page |
| Tables | Wrap cell contents and discourage breaks inside rows | Repeated headers remain user-agent-dependent |
| Blockquotes | Discourage an internal page break | An oversized quote must still fragment |
| Mermaid SVG and images | Constrain width to the page and preserve aspect ratio | Replaced elements are effectively atomic; a very tall or dense visual must be split or simplified by its author |

`pre-wrap` preserves source whitespace and allows wrapping. Combined with
`overflow-wrap: anywhere`, it supplies emergency break opportunities for long
paths, URLs, hashes, and commands.[^3] Resetting `overflow` is also important
for pagination: the Fragmentation specification permits user agents to treat
scrollable boxes as monolithic.[^2]

The product should not set `break-inside: avoid-page` on every `.code-block`.
This template intentionally contains complete CSS and JavaScript payloads that
are taller than one page. Keeping all such blocks together is impossible and
can create poor whitespace or engine-specific overflow. Normal fragmentation
after wrapping is the safer global rule.

For tables, semantic `thead` remains useful, but the CSS 2 table model says a
print user agent *may* repeat header rows; it does not require repetition.[^4]
The Chromium test did not repeat the canonical mapping header even with
`display: table-header-group`. Repeated table headers therefore cannot be a
cross-browser acceptance requirement. If they later become mandatory, the
product would need table splitting logic or a controlled PDF renderer.

### Color and themes

Print output should use a white canvas, dark text, visible borders, and an accent
that remains distinguishable in grayscale. It must remain understandable when
the print dialog disables background graphics.

The product should not apply `print-color-adjust: exact` globally.
`print-color-adjust` is only a hint, its initial value is `economy`, and user
preferences take priority.[^5] A sound print layout communicates grouping with
borders, spacing, and type weight so it does not depend on preserved
backgrounds.

The light Highlight.js stylesheet can be reused with a media list:

```css
@import url("../../vendor/css/highlight.github.min.css")
  screen and (prefers-color-scheme: light), print;
```

This adds no asset and ensures the dark syntax theme remains screen-only.
Syntax color is an enhancement; the code must remain readable when printed in
grayscale.

Mermaid needs a separate decision because its theme colors are embedded in the
generated SVG before printing. Print CSS cannot safely restyle every diagram
type, and `filter`-based inversion would behave differently for light and dark
inputs. Mermaid documents `neutral` as its theme for black-and-white printed
documents.[^6] Using it globally is the smallest deterministic solution:

```javascript
theme: 'neutral'
```

A `beforeprint` re-render is less reliable. The HTML standard fires
`beforeprint` before obtaining the physical or PDF representation, but the user
agent may snapshot the state at that point.[^7] Mermaid rendering is
asynchronous, so the event does not provide a dependable wait contract.
Pre-rendering a second hidden diagram would be reliable but would double diagram
rendering and add state management. The tested global neutral theme is the
recommended tradeoff.

### Headers, footers, links, and metadata

The baseline should leave page headers, footers, page numbers, URL, and print
date to the browser print dialog. CSS page-margin boxes now work in modern
Chromium, but Chrome only added them in version 131, and browser-generated
headers can coexist with author-generated margin content.[^8] Depending on them
would weaken the product's browser-neutral contract.

External URLs should not automatically be appended after every link. This often
duplicates already visible URLs, expands tables, and creates new overflow.
Printed PDFs retain clickable links in capable viewers; paper readers still get
descriptive link text. A future opt-in authoring class could expose selected
URLs if a real need appears.

The existing document title and language remain useful to PDF exporters.
Custom `documentation-template-*` metadata should not be treated as portable
PDF metadata because exporters vary in what they preserve.

## Implementation approaches

| Approach | Strengths | Costs and risks | Fit |
| --- | --- | --- | --- |
| Adaptive CSS in the existing payload | Small, offline, no new files, works from `file:`, user chooses paper | Table-header repetition and complex paged-media features vary by browser | Recommended baseline |
| Separate print stylesheet | Clear separation | Adds a 27th bootstrap file, another live link, payload, mapping, validation rule, and synchronization point | Reject |
| Fixed A4 or Letter profile | Predictable for one target | Wrong default elsewhere; needs user/build choice and duplicated tests | Reject for the generic product |
| JavaScript `beforeprint` adaptation | Can alter content and attempt Mermaid re-rendering | Async timing is not dependable; adds reversible state and failure paths | Reject |
| Vendored Paged.js | Rich pagination and browser preview | Adds a large dependency and DOM transformation; its documented browser route expects another script and commonly a web server[^9] | Possible only for a different publishing product |
| Headless Chromium/Puppeteer export | Reproducible CI PDFs, explicit paper and background settings[^10] | Requires Node/browser tooling and is Chromium-specific | Good optional maintainer test, not runtime |
| WeasyPrint or Prince export | Strong paged-media control, named pages, headers, footers, archival options | Separate renderer installation and behavior; no longer zero-tool direct browsing[^11][^12] | Suitable only if PDF becomes a first-class release artifact |

Paged.js, WeasyPrint, and Prince solve a broader publishing problem. The current
product is a portable local documentation shell. Adding any of them for basic
printing would conflict with its small bootstrap and exact offline file tree.

## Proposed minimal CSS

This is the decision-ready baseline, not an edit already applied to the product:

```css
@page {
  size: auto;
  margin: 15mm;
}

@media print {
  :root {
    color-scheme: light;
    --page-background: #ffffff;
    --surface: #ffffff;
    --text: #111111;
    --muted: #444444;
    --accent: #111111;
    --accent-soft: #eeeeee;
    --border: #999999;
    --code-background: #f4f4f4;
    --shadow: none;
  }

  html,
  body {
    overflow: visible;
    min-height: auto;
    background: #ffffff;
  }

  .documentation-navbar,
  .copy-button {
    display: none !important;
  }

  .page-width {
    width: auto;
    margin: 0;
  }

  .documentation-content {
    margin: 0;
    border: 0;
    border-radius: 0;
    background: #ffffff;
    box-shadow: none;
    padding: 0;
    overflow-wrap: anywhere;
  }

  .documentation-content h1,
  .documentation-content h2,
  .documentation-content h3 {
    break-after: avoid-page;
    page-break-after: avoid;
  }

  p,
  li {
    orphans: 3;
    widows: 3;
  }

  blockquote,
  .mermaid {
    break-inside: avoid-page;
    page-break-inside: avoid;
  }

  pre {
    overflow: visible;
    white-space: pre-wrap;
    overflow-wrap: anywhere;
  }

  .code-block pre {
    padding-right: 1rem;
  }

  thead {
    display: table-header-group;
  }

  tr {
    break-inside: avoid-page;
    page-break-inside: avoid;
  }

  th,
  td {
    overflow-wrap: anywhere;
  }

  img,
  .mermaid svg {
    max-width: 100%;
    height: auto;
  }

  a {
    color: inherit;
    text-decoration: underline;
  }
}
```

The final product edit can remove declarations that prove redundant across the
target browser matrix. The prototype intentionally favors explicit behavior so
each rule can be evaluated independently.

## Validation matrix

Print-media emulation in browser developer tools is useful for inspecting which
CSS rules apply, but it does not prove pagination. Chrome documents it as a CSS
preview mode.[^13] Acceptance therefore needs actual print preview or PDF output.

### Required fixtures

The current long template is a valuable regression fixture because it contains
headings, lists, wide paths, large full-file code blocks, tables, inline code,
blockquotes, and Mermaid. A temporary edge fixture should additionally contain:

- an `h2` positioned near a page end with one following paragraph;
- a two-line paragraph and a long paragraph around page boundaries;
- a single long token, URL, file path, and command;
- one short code block and one block taller than a page;
- a table wider than the page and a table taller than a page;
- a table row taller than the remaining page area;
- light and dark operating-system color preferences;
- a Mermaid diagram with labels and several node colors;
- an image wider than the page and a tall image once asset rules exist.

### Required outputs

Test at least:

| Browser | Paper | Color preference | Background graphics |
| --- | --- | --- | --- |
| Chromium family | A4 portrait | light and dark | off, then on |
| Chromium family | Letter portrait | light and dark | off, then on |
| Firefox | A4 portrait | light and dark | off |
| Firefox | Letter portrait | light and dark | off |

Chrome and Firefox both support the basic `@page` rule, while more advanced page
features have historically varied.[^8] Safari should be added when a macOS test
host is available, but it should not block a Windows-only development cycle.

### Acceptance criteria

- The printed page contains no navbar, collapse toggle, dropdown, or copy button.
- The output is light and readable regardless of the operating-system theme.
- A4 and Letter retain the user-selected physical size and orientation.
- No paragraph, URL, table cell, or code line is clipped horizontally.
- No scrollbar is visible in print.
- A heading is not left at the page bottom without following content when a
  legal break can avoid it.
- Short rows, blockquotes, and diagrams are not split when they fit on a page.
- Content taller than a page remains present and continues rather than
  overflowing or disappearing.
- The Mermaid smoke diagram remains legible in dark-screen and print contexts.
- Syntax highlighting remains readable with background graphics disabled and in
  grayscale.
- Links remain recognizable as links without printing every target URL.
- Browser console and print generation report no missing local assets.
- No assertion depends on an exact page count, repeated table headers, or
  pixel-identical breaks across engines.

An automated Chromium smoke test may generate A4 and Letter PDFs using
`page.pdf()` with explicit formats, `printBackground: false`, and
`preferCSSPageSize: false`.[^10] It should check page dimensions, text presence,
and obvious overflow indicators. Visual review remains necessary for clipping,
spacing, diagram contrast, and page-break quality.

## Product blast radius for implementation

A 3.3.0 implementation should touch only the places that define or verify the
new contract:

1. live and canonical `documentation-template-version` values;
2. the light Highlight.js import and print rules in the
   `documentation.css` payload;
3. the Mermaid theme in the `documentation.js` payload;
4. one concise print rule in `Visual and interaction rules`;
5. print checks in the validation checklist;
6. the 3.3.0 release baseline produced by `buildtestingfolder.ps1`.

The required 26-file tree, filenames, loader order, third-party versions,
licenses, acquisition routes, page array, and HTML shell do not need to change.
That boundary keeps the implementation small and prevents print support from
becoming a second product mode.

## Sources

[^1]: [W3C CSS Paged Media Module Level 3](https://www.w3.org/TR/css-page-3/), especially the `size` property, standard A4 and Letter dimensions, and paper-size media-query restriction.
[^2]: [W3C CSS Fragmentation Module Level 3](https://www.w3.org/TR/css-break-3/), covering `break-*`, `widows`, `orphans`, legacy aliases, monolithic scroll containers, and constraint relaxation.
[^3]: [W3C CSS Text Module Level 3](https://www.w3.org/TR/css-text-3/), covering `white-space: pre-wrap` and `overflow-wrap`.
[^4]: [W3C CSS 2.1 table model](https://www.w3.org/TR/CSS2/tables.html), `table-header-group` and optional repetition by print user agents.
[^5]: [W3C CSS Color Adjustment Module Level 1](https://www.w3.org/TR/css-color-adjust-1/), `print-color-adjust` and user preference precedence.
[^6]: [Mermaid theme configuration](https://mermaid.js.org/config/theming), describing the `neutral` print-oriented theme.
[^7]: [WHATWG HTML Standard: printing](https://html.spec.whatwg.org/multipage/timers-and-user-prompts.html#printing), `beforeprint`, print snapshot state, and `afterprint`.
[^8]: [Chrome for Developers: CSS page margin boxes](https://developer.chrome.com/blog/print-margins), basic `@page` support, Chrome 131 margin boxes, and browser headers and footers.
[^9]: [Paged.js getting started](https://pagedjs.org/en/documentation/2-getting-started-with-paged.js/), browser polyfill, module, command-line routes, and documented browser requirements.
[^10]: [Puppeteer `PDFOptions`](https://pptr.dev/api/puppeteer.pdfoptions), paper format, backgrounds, CSS page-size precedence, and PDF options.
[^11]: [WeasyPrint documentation](https://doc.courtbouillon.org/weasyprint/stable/), its HTML/CSS-to-PDF renderer and paged-media capabilities.
[^12]: [Prince paged-media documentation](https://www.princexml.com/doc/paged/), named pages, pagination, regions, and PDF-oriented controls.
[^13]: [Chrome DevTools: emulate CSS media type](https://developer.chrome.com/docs/devtools/rendering/emulate-css), print media emulation for CSS inspection.
