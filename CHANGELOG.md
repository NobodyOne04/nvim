# Changelog

## Unreleased

### Added
- Decision records in `docs/adr/`: twelve ADRs for the config's existing decisions
- ADR files (`.adr`): markdown highlighting, a picker, `]A`/`[A` between them, keys to decide a Proposed ADR, coloured status
- `make check` loads every plugin and opens a file per language; plugin errors fail it
- `CLAUDE.md`: how to work on this repo with Claude Code
- Go debugging (delve), reload of files changed outside nvim (#1)
- Start screen shows the logo and wordmark of the running OS (#1)
- Jupyter notebooks: open, run and edit `.ipynb` (#1)
- tmux navigation: Alt-h/j/k/l across nvim splits and tmux panes (#1)

### Fixed
- Alt-h/j/k/l stops at the screen edge as intended: smart-splits had renamed its options and was wrapping
- snacks.nvim loads with the priority it asks for (1000)

### Changed
- lua_ls: the `globals = { "vim" }` workaround is gone; lazydev already provides the Neovim API
