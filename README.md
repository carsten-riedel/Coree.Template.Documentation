# DocShell

DocShell is a single-file, AI-optimized template for portable static documentation.

## Why use it?

The central idea is a dual-use documentation artifact: a very thin HTML frame
around native Markdown. The authored documentation remains plain Markdown in a
`text/markdown` block, which is the natural format for an LLM or agent to read,
write, compare, and extend. The HTML contributes only the portable frame,
metadata, and local runtime needed to present that same content to people.

This keeps formatting waste small when the artifact is supplied as context to
an LLM or agent. The model does not need to consume a second, verbose HTML
representation of every paragraph, table, link, or code block. At the same
time, the authored state remains human-visible: a browser renders the same
Markdown into a normal documentation page instead of requiring a separate
conversion step or source format.

The template therefore turns one portable source artifact into a complete
documentation site that an agent can bootstrap without a project-specific
build system. It opens directly from a folder, remains readable offline, and
can still provide optional online links when a project has them.

The practical benefit is a small, reproducible handoff: one artifact can be
read by an agent, reviewed by a person, attached to a release, and archived
without losing the relationship between source content and rendered content.
No server, package manager, CDN, or runtime network connection is required for
the finished site.

This is useful when documentation must travel with a repository, release
artifact, support bundle, or shared folder. It avoids turning documentation into
another application that needs to be installed, built, hosted, or kept in sync
with a separate service.

## One artifact, two readers

Documentation increasingly has two readers with different natural tools. An
LLM or agent works best with the compact authored Markdown it can reason about
directly. A person usually wants to open a page in a browser and inspect the
rendered result without learning a documentation toolchain.

Those needs often lead to an unnecessary choice: provide machine-friendly
Markdown and lose immediate human visibility, or provide rendered HTML and
make the model carry a large amount of presentation markup. This template keeps
both views in one artifact. The Markdown is the content; the HTML is a thin
presentation envelope around it.

The important property is not that the output happens to be HTML. It is that
the content an agent reads and the content a person sees are the same authored
state. There is no separate HTML export that can drift from the Markdown, and
no requirement to spend context on a second representation of the same
information.

## What it provides

### For agents

- One clearly identified HTML artifact contains the bootstrap contract.
- Documentation content stays in native Markdown instead of being duplicated as
  verbose generated HTML.
- The authored Markdown and the human-facing rendered page come from the same
  artifact, reducing format drift during agent edits.
- The contract defines the output tree, pinned dependencies, licenses,
  validation rules, and cleanup requirements.
- Project-owned runtime files are embedded as copy-ready payloads, so the agent
  does not need to invent a project-specific layout.
- Versioned baselines make the exact template used for a test or release
  reproducible.

### For people

- The finished site is ordinary HTML that opens directly from a local folder.
- The visible page is the rendered form of the Markdown an agent works with;
  there is no hidden documentation source that people cannot inspect.
- Pages use familiar Markdown authoring while retaining navigation, diagrams,
  code examples, links, images, and print support.
- The same documentation can remain useful offline and expose optional online
  destinations when those are explicitly configured.
- The visual shell stays consistent across pages without requiring a framework
  or a documentation hosting service.

## Feature inventory

### Authoring and navigation

- Dual-use pages: native Markdown for AI/agent workflows and browser-rendered
  HTML for human workflows.
- GFM-style Markdown pages rendered locally in the browser.
- A registered page array drives the Documentation menu and generated Contents
  lists.
- Current-page labels, icons, active states, and document titles are applied by
  the runtime.
- Optional external destinations are separated into an Online menu.
- A root-level `assets/` directory supports relative images and other local
  resources.

### Presentation and interaction

- Responsive Bootstrap navigation with desktop and mobile layouts.
- Light and dark modes based on the user's color-scheme preference.
- Markdown tables retain their semantics and scroll horizontally inside a
  responsive wrapper on narrow screens.
- Common code highlighting plus local PowerShell and DOS/CMD grammars.
- Copy controls for fenced code blocks.
- Mermaid diagrams rendered locally with strict security settings.
- Print layout with navigation and interactive controls removed, 15 mm page
  margins, readable code wrapping, and dark-mode-independent print colors.

### Packaging and maintenance

- Pinned Bootstrap, Bootstrap Icons, ClipboardJS, Highlight.js, Marked, and
  Mermaid distributions.
- Third-party license files and a generated notices file.
- No CDN, runtime package installation, server, remote font, or runtime API is
  required by the finished site.
- Cross-platform path and cleanup rules for Windows, Linux, and macOS hosts.
- A PowerShell test-folder generator that creates versioned release baselines
  and copy-ready prompts.

## How the handoff works

1. The template version is read from the live HTML metadata.
2. An agent reads the complete artifact and follows its bootstrap contract.
3. The agent creates the two-page shell, local runtime, vendored browser files,
   licenses, and an empty `assets/` directory.
4. The agent validates the file set, payloads, metadata, local references, and
   cleanup result.
5. Later authoring tasks add real pages and assets without changing the shared
   shell.

The template intentionally keeps the initial result small. It does not invent
project content, download sample images, or create a documentation build
system merely to display the generated pages.

## Authoring example

Local images use relative paths from the root-level `assets/` directory:

```markdown
![Architecture overview](./assets/architecture-overview.png)
```

Other local resources can be linked in the same way:

```markdown
[Open the reference PDF](./assets/reference.pdf)
```

Because every HTML page stays at the documentation root, these paths work when
the site is opened directly from a local folder.

## Boundaries

This project is a portable static documentation package, not a CMS, search
service, live API client, or general-purpose site generator. Dynamic data,
authentication, server-side rendering, and reliable forced downloads require a
different delivery model.

The repository history begins with the initial template commit and does not
contain a reliable pre-1.0 development chronology. The feature list above is
therefore a verified capability list, not an invented historical reconstruction.

## Getting started

The DocShell source is available in [`src/DocTemplate.html`](src/DocTemplate.html).
It contains the bootstrap instructions and embedded file payloads for creating
the documentation site. Follow those instructions to generate the required
local assets before viewing the finished site in a browser.

## Build a test folder

Run `src/buildtestingfolder.ps1` to read the template version from the HTML
metadata and create the tracked release baseline at
`src/releases/<version>/workspace/DocShell.html`. It also writes a
copy-ready `src/releases/<version>/prompt.md` containing the artifact's absolute
path. Prompts and materialized test output remain local and ignored by Git.

Pass an alternative initial name when testing filename-independent bootstrap:
`src/buildtestingfolder.ps1 -FileName Docs.html` creates
`src/releases/<version>/workspace-Docs/Docs.html` and `prompt-Docs.md`.

Product maintenance guidance for human and automated editors is defined in
[`src/MAINTAINING.md`](src/MAINTAINING.md). [`src/AGENTS.md`](src/AGENTS.md)
retains automatic discovery for agent tooling.

## License

This project is licensed under the [MIT License](LICENSE).
Third-party dependencies retain their respective licenses as documented in
the template.
