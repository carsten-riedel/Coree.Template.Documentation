# Coree.Template.Documentation

A portable template for static, offline documentation.

## Getting started

The template is available in [`src/DocTemplate.html`](src/DocTemplate.html).
It contains the bootstrap instructions and embedded file payloads for creating
the documentation site. Follow those instructions to generate the required
local assets before viewing the finished site in a browser.

## Build a test folder

Run `src/buildtestingfolder.ps1` to read the template version from the HTML
metadata and copy the current template to `src/<version>/DocTemplate.html`.
The versioned folder can then be used as an isolated target for testing the
agent bootstrap prompt. Generated version folders are local test workspaces
and are ignored by Git.

Product maintenance rules are defined in [`src/AGENTS.md`](src/AGENTS.md).

## License

This project is licensed under the [MIT License](LICENSE).
Third-party dependencies retain their respective licenses as documented in
the template.
