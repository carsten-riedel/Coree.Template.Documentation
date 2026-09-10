# Coree.Template.Documentation

A portable template for static, offline documentation.

## Getting started

The template is available in [`src/DocTemplate.html`](src/DocTemplate.html).
It contains the bootstrap instructions and embedded file payloads for creating
the documentation site. Follow those instructions to generate the required
local assets before viewing the finished site in a browser.

## Build a test folder

Run `src/buildtestingfolder.ps1` to read the template version from the HTML
metadata and create `src/<version>/workspace/<filename>`. It also writes a
copy-ready `src/<version>/prompt.md` containing the artifact's absolute path.
Generated version folders are local test workspaces and are ignored by Git.

Pass an alternative initial name when testing filename-independent bootstrap:
`src/buildtestingfolder.ps1 -FileName Documentation.html`.

Product maintenance guidance for human and automated editors is defined in
[`src/MAINTAINING.md`](src/MAINTAINING.md). [`src/AGENTS.md`](src/AGENTS.md)
retains automatic discovery for agent tooling.

## License

This project is licensed under the [MIT License](LICENSE).
Third-party dependencies retain their respective licenses as documented in
the template.
