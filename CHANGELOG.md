# Changelog

## Unreleased

### Added
- Claude Code in nvim (claudecode.nvim): `\a` keys to send code, review its diffs; `\ai` toggles Copilot hints
- ADR files: `gd` on a link opens the ADR it points to, `gpd` peeks it in a float
- ADR files (`.adr`) get a green gavel icon in the file browser, picker and buffer tabs
- Decision records in `docs/adr/`: twelve ADRs for the config's existing decisions
- ADR files (`.adr`): markdown highlighting, a picker, `]A`/`[A` between them, keys to decide a Proposed ADR, coloured status
- `make check` loads every plugin and opens a file per language; plugin errors fail it
- `CLAUDE.md`: how to work on this repo with Claude Code
- Go debugging (delve), reload of files changed outside nvim (#1)
- Start screen shows the logo and wordmark of the running OS (#1)
- Jupyter notebooks: open, run and edit `.ipynb` (#1)
- tmux navigation: Alt-h/j/k/l across nvim splits and tmux panes (#1)

### Fixed
- Claude sees the line under the cursor, not just the file name
- Alt-h/j/k/l stops at the screen edge as intended: smart-splits had renamed its options and was wrapping
- snacks.nvim loads with the priority it asks for (1000)

### Changed
- Markdown and ADR links: the label in the cyan accent, underlined; the path greyed out
- ADRs rewritten in the new template (purpose, technical details, technologies and alternatives), with the implementation details
- lua_ls: the `globals = { "vim" }` workaround is gone; lazydev already provides the Neovim API
