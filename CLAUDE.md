# CLAUDE.md: Neovim config

My Neovim config (lazy.nvim), same on a Mac and an Arch desktop. `~/.config/nvim` is a symlink to this
repo, so **the checked-out branch is the editor I'm using right now**: a feature branch left checked out
is what every nvim I open runs, and it never reaches the other machine. `README.md` is for me (install,
keys, notebooks, past reviews); this file is for you.

## Map: where a change goes

| Change | File |
|---|---|
| leader (`\`, kept from the old config) | `init.lua` |
| options, providers (python host) | `lua/config/options.lua` |
| keymaps not tied to a plugin | `lua/config/keymaps.lua` |
| autocmds, diagnostics look | `lua/config/autocmds.lua` |
| lazy.nvim bootstrap/setup | `lua/config/lazy.lua` |
| Jupyter cell helpers (`# %%`) | `lua/config/notebook.lua` |
| plugin specs, by theme | `lua/plugins/{core,editor,coding,lsp,treesitter,ui,tools,notebook,tmux}.lua` |
| colours, start screen, statusline | `lua/plugins/ui.lua` (palette locals at the top; `on_highlights`) |
| language server list | `lua/plugins/lsp.lua` `servers` **and** `Makefile` `SERVERS` (keep both in sync) |
| treesitter parsers | `lua/plugins/treesitter.lua` `parsers` (also read by `scripts/ts-install.lua`) |
| formatter | `lua/plugins/lsp.lua` conform `formatters_by_ft`, plus the tool in `scripts/install-tools.sh` |

A plugin's keymaps live in its spec (`keys = {…}`), not in `keymaps.lua`. New `<leader>` group: add it to
which-key's `spec` in `ui.lua`.

## Rules

- **Lazy-load** everything that can (`keys`, `cmd`, `ft`, `event`). Startup is ~25 ms; keep it there
  (`make startup`). `lazy = false` only when it must exist at start (colorscheme, snacks, oil, smart-splits,
  jupytext); say why in a comment.
- **Keys:** before binding, check for clashes: `nvim --headless "+verbose map <key>" +qa`, the which-key
  groups, tmux (`~/projects/tmux/conf/keys.conf`) and Ghostty. Taken on purpose: `s` (mini.jump2d),
  `<C-h>/<C-l>` (side scroll; in insert: snippet jump), `<Tab>` (next buffer; in insert: Copilot),
  `]]`/`[[` (LSP word jumps), Alt-h/j/k/l (smart-splits ↔ tmux panes), `<C-p>` find files, `<C-f>` grep.
- **Look:** one cyan accent `#00e5ff`, transparent backgrounds, rounded borders, quiet UI. Reuse the palette
  locals in `ui.lua`; a new plugin's highlights go in tokyonight's `on_highlights`.
- **Both OSes:** `vim.fn.has("mac")`; the OS logo logic is in `ui.lua` (`detect_os`).
- **Plugin options get renamed upstream** and old keys are silently ignored (smart-splits `at_edge` was
  ignored for weeks). After adding or updating a plugin, look at `:checkhealth <plugin>`.
- Plugin changes: commit `lazy-lock.json` with them. New/changed key: update the README keys table in the
  same commit. Comment the why, briefly.

## Test

```sh
make check      # 1) plain start  2) scripts/check.lua: every plugin loaded + one file per language;
                #    errors fail (it captures vim.notify, which is silent headless)
make startup    # 5 timed starts
nvim --headless "+checkhealth <name>" "+w! /path/out.txt" +qa!   # health report to a file
```

## Gotchas (each cost time once)

1. **Headless hides errors.** lazy.nvim and plugins report through `vim.notify`, which prints nothing with
   `--headless`; a plain `nvim --headless +qa` passes with a broken lazy-loaded plugin. Use `make check`.
2. `--startuptime /dev/stdout` prints nothing headless: use `make startup` (writes to a temp file).
3. Lazy-loaded plugins aren't set up until triggered: `"+Lazy! load all"` before inspecting one headless.
4. LSP needs a moment: in a headless test, `vim.defer_fn(…, 8000)` before reading `vim.diagnostic.get(0)`.
5. molten's commands come from `:UpdateRemotePlugins` (`make notebook`); don't give it a `cmd` lazy trigger.
   The python host is `~/.local/share/nvim/python-host` (set in `options.lua`; without it the provider is off).
6. nvim-treesitter is on the `main` branch (Neovim 0.12+ API). Never use the old
   `require("nvim-treesitter.configs")` setup.
7. `:checkhealth` noise to ignore: optional tools (java, php, julia, luarocks), Snacks image checks
   (no terminal headless), jupytext's health crash (a bug in the plugin).

## Workflow

- Changes go through the `github-flow` skill: branch, `CHANGELOG.md` line, PR (opened in the browser),
  I merge. Never commit or push to `main`.
- Because the checkout is the live config: after pushing a branch, switch back to `main` unless I'm trying
  the change out; after a merge, `git switch main && git pull`.
- After a merge, remind me to `git pull` on the other machine and `make sync` if `lazy-lock.json` changed.
- Ask before `make install`, `make tools`, `make link`/`unlink`, `make update` (rewrites the lockfile), or
  touching `~/.local/share/nvim/lazy` (installed plugin code).
