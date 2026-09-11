# Product maintenance

`DocTemplate.html` is the product source, bootstrap contract, page template,
and source for its embedded project-owned files.

This guide applies to human maintainers and automated editors. It covers
development, review, versioning, building, testing, and commits. Consumer-facing
bootstrap and documentation rules belong inside `DocTemplate.html`.

## Product boundary

A consuming agent reads and executes `DocTemplate.html`; the file does not
maintain itself. Development workflow stays in this guide. Each instruction
added to the product should serve the consuming agent.

## Complete-file review

Before a product edit, read `DocTemplate.html` completely. Start with a
whole-file read such as `Get-Content -Raw`. Focused reads are useful only for
content hidden by tool output truncation.

After each edit, read the complete file again with a whole-file command. Review
the live shell, canonical shell, instructions, embedded payloads, required
output, and validation rules together before building or committing.

## Change impact

Each planned edit includes a blast-radius assessment across the live shell,
canonical shell, instructions, payloads, generated files, validation, version,
and build workflow. The post-edit review checks intended effects and unintended
consequences across the same areas while keeping the change small.

## Editing principles

- Prefer short, direct, platform-neutral rules.
- Include only behavior required by the bootstrap, runtime, or validation
  contract.
- Avoid duplicated rules and branches for hypothetical cases.
- Keep the live HTML shell and its canonical example synchronized.
- Keep every fenced file payload complete and equal to its generated file.

## Versioning

The live `documentation-template-version` meta value is the product version. Its
value stays synchronized with the canonical page shell.

- Patch: corrections and instruction refinements.
- Minor: backward-compatible features or output additions.
- Major: incompatible bootstrap, output, or runtime changes.

Each product change receives a version bump before a test folder is built.

## Build and test

`./buildtestingfolder.ps1` reads the live version, creates the versioned release
baseline under `./releases/<version>/workspace/Documentation.html`, verifies it
by SHA-256, and writes an ignored `prompt.md` containing the artifact's absolute
path. The baseline is committed so older product versions remain reproducible.
Prompts and files materialized by test agents remain ignored. The
`-FileName Docs.html` option creates an isolated `workspace-Docs` test for an
alternative initial name.

## Release validation

The product's bootstrap contract uses static validation only. Browser checks
belong to template release testing and are performed only when suitable local
`file:` access is already available:

- Verify navigation, generated Contents, active-page state, and stable layout at
  desktop and mobile widths.
- Verify light and dark colors, local icons, syntax highlighting, and copy-button
  behavior, including first-line and horizontal-scroll edge cases.
- Verify Mermaid rendering and an error-free browser console without networking.
- Verify A4 and Letter print layouts with background graphics disabled.

Record unavailable interactive checks instead of installing browser automation
for them.

## Commits

A coherent, verified product change is committed and pushed with its release
baseline. Prompts, materialized test output, and unfinished work remain
uncommitted. The tracked working tree should be clean after pushing.

## Automated editors and LLM agents

- Automated editors MUST read this complete guide before maintaining the
  product.
- They MUST treat `DocTemplate.html` as product source and MUST NOT execute its
  bootstrap instructions while maintaining it.
- A whole-file read before and after every edit is mandatory. Targeted reads
  may only recover output omitted by tool truncation.
- They MUST assess the full blast radius before editing and MUST NOT assume a
  scoped edit affects only its immediate location.
- They MUST keep the live shell, canonical shell, instructions, payloads,
  validation rules, version, and release baseline consistent.

## Open points

- For a future major version, decide whether the documentation writing guide
  should become a dedicated artifact created during bootstrap.
