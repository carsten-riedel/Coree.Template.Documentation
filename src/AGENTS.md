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

Run `./buildtestingfolder.ps1`. It reads the live version, creates
`./<version>/DocTemplate.html`, and verifies the copy by SHA-256. Versioned
folders are ignored local workspaces. Run the bootstrap prompt against that
copy and validate the result using the checklist inside the product.

## Commits

Commit and push after each coherent, verified product change. Do not commit
generated test folders or mix unfinished work into a product commit. Leave the
tracked working tree clean after pushing.
