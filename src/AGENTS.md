# Product maintenance

`DocTemplate.html` is the product source, bootstrap contract, page template,
and source for its embedded project-owned files.

This file governs product development. Keep build, editing, testing, and
commit rules here. Put only consumer-facing bootstrap and documentation rules
inside `DocTemplate.html`.

## Product boundary

`DocTemplate.html` is executed by a consuming agent; it does not maintain
itself. Never place developer workflow in the product. Instructions for
editing, reviewing, versioning, building, testing, or committing the source
belong only in this file. Before committing, verify that every product
instruction serves the consuming agent.

## Read before and after editing

Read `DocTemplate.html` completely before changing it. Start with one
whole-file read such as `Get-Content -Raw`; do not start with line ranges or
chunked reads. Use focused reads only to recover content hidden by tool output
truncation.

After every edit, read the complete file again with a whole-file command.
Sanity-check the live shell, canonical shell, instructions, embedded payloads,
required output, and validation rules together before building or committing.

## Change impact

Before editing, identify the change's blast radius across the live shell,
canonical shell, instructions, payloads, generated files, validation, version,
and build workflow. Update every affected contract while keeping the change
small. During the whole-file sanity read, verify both the intended effects and
unintended consequences.

## Editing

- Keep rules short, direct, and platform-neutral.
- Add only behavior required by the bootstrap, runtime, or validation contract.
- Avoid duplicated rules and branches for hypothetical cases.
- Keep the live HTML shell and its canonical example synchronized.
- Keep every fenced file payload complete and equal to its generated file.

## Versioning

The live `documentation-template-version` meta value is the product version.
Keep the same value in the canonical page shell.

- Patch: corrections and instruction refinements.
- Minor: backward-compatible features or output additions.
- Major: incompatible bootstrap, output, or runtime changes.

Bump the version for every product change before building a test folder.

## Build and test

Run `./buildtestingfolder.ps1`. It reads the live version, creates the
versioned release baseline under
`./releases/<version>/workspace/Documentation.html`, verifies it by SHA-256,
and writes an ignored `prompt.md` with the artifact's absolute path. Commit the
baseline so older product versions remain reproducible. Prompts and files
materialized by test agents stay ignored. Use `-FileName Docs.html` for an
isolated `workspace-Docs` test of an alternative initial name.

## Commits

Commit and push after each coherent, verified product change, including its
release baseline. Do not commit prompts, materialized test output, or unfinished
work. Leave the tracked working tree clean after pushing.

## Open points

- Decide whether bootstrap should include the template's own license alongside
  third-party licenses.
- Consider author or origin metadata so forks can retain clear provenance.
- Define print behavior for heading page breaks, common paper sizes, and content
  overflow.
- Keep copy controls usable when code blocks overflow horizontally.
- Evaluate a human-facing maintainer filename while preserving automatic
  discovery of `AGENTS.md`.
- For a future major version, decide whether the documentation writing guide
  should become a dedicated artifact created during bootstrap.
- Add a concise product rationale covering low agent overhead and documentation
  that remains readable offline and online.
- Define relative folders and authoring rules for images, PDFs, and other assets.
- Decide whether pages should support references to external Markdown content.
- Refine the dark theme.
- Keep tables usable on narrow mobile screens.
- Reconstruct the complete feature list that predates version 1.0.0.
