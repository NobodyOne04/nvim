# nvim

My Neovim config: lazy.nvim, LSP via mason, treesitter, telescope, completion, Copilot, databases (dadbod),
Python REPL (iron), debugging (dap). Styled to match the archminimal desktop: tokyonight moon with a cyan
accent, transparent background, rounded borders, quiet chrome.

- Starts in **~60 ms** (about 200 ms when opening a file); almost everything loads on first use.
- **Neovim 0.12+** recommended (Arch ships 0.12). On 0.11 everything works except treesitter, which falls back
  to basic highlighting and tells you once.
- Plugin versions are pinned in `lazy-lock.json`, so every machine gets the same, tested set.

## Install

```bash
git clone git@github.com:NobodyOne04/nvim.git ~/projects/nvim && cd ~/projects/nvim
make install
```

`make install` runs:

| Step | What |
|---|---|
| `make tools` | ripgrep, fd, fzf, git, a C compiler, tree-sitter CLI, node, go, python, and the formatters (pacman / brew / apt / dnf) |
| `make link` | links this repo to `~/.config/nvim`; an existing config is moved to `~/.config/nvim.bak-<date>`, never deleted |
| `make sync` | installs plugins at the versions in `lazy-lock.json` |
| `make lsp` | installs pyright, lua_ls, bashls, ts_ls, gopls and goimports with mason |

Other targets: `make update` (update plugins, rewrite the lockfile, then commit it), `make check` (headless start,
fails on errors), `make startup` (timing), `make health`, `make unlink` (restore your previous config).

A [Nerd Font](https://www.nerdfonts.com) is needed for icons (`ttf-jetbrains-mono-nerd`; kitty picks up its symbols automatically).
Copilot: run `:Copilot setup` once; the token lives in `~/.config/github-copilot`.

## Layout

```text
init.lua                  leader, then config.* and plugins
lua/config/options.lua    editor options
lua/config/keymaps.lua    general keymaps
lua/config/autocmds.lua   restore cursor, q closes helpers, diagnostics style
lua/config/lazy.lua       lazy.nvim bootstrap
lua/plugins/ui.lua        theme, statusline, bufferline, indent guides, scrollbar, gitsigns, which-key
lua/plugins/editor.lua    telescope, yanky, jump2d, surround, autopairs, multi-cursor, git-conflict, trouble
lua/plugins/coding.lua    completion, snippets, Copilot
lua/plugins/lsp.lua       mason, servers, LSP keymaps, goto-preview, formatting
lua/plugins/treesitter.lua
lua/plugins/tools.lua     dadbod, iron, distant, dap
scripts/install-tools.sh
```

## Keys

Leader is `\` (as before; it was never set explicitly). For Space, change `mapleader` in `init.lua`.

| Keys | Action |
|---|---|
| `<C-p>` / `<C-f>` | find files / live grep (project) |
| `\fg` `\fb` `\fh` | grep in cwd / file browser / help |
| `\fr` `\fd` `\fs` `\fw` | **new:** recent files / diagnostics / symbols / grep word under cursor |
| `\bb` | buffers |
| `<Tab>` / `<S-Tab>` / `\e` | next / previous / delete buffer |
| `s` | jump anywhere (mini.jump2d) |
| `\y` | yank history (works for visual yanks too now) |
| `\cp` | copy the file's absolute path |
| `\td` | TODOs |
| `gd` `gD` `K` | definition / declaration / hover (every language server, including gopls) |
| `\rn` `\ca` `\ch` | rename / code action / toggle inlay hints |
| `gpd` `gpi` `gpr` `gP` | peek definition / implementation / references, close previews |
| `gl` | diagnostics for the line |
| `\cf` or `:Format` | **format** (was `\f`, see below) |
| `\xx` `\xb` `\xr` | **new:** diagnostics list (project / buffer), references (trouble) |
| `]h` `[h` `\hp` `\hs` `\hr` `\hb` | **new:** next/prev git hunk, preview, stage, reset, blame |
| `\db` | database UI |
| `\sc` `\sf` `\sl` `\sq` `\cl` | send motion/selection / file / line to the REPL, quit, clear |
| `\du` `\bp` `F5` `F10` `F11` `F12` | debug UI, breakpoint, continue, step over / into / out |
| `<C-d>` `<C-u>` | 10 lines down / up and recenter |
| `<C-h>` `<C-l>` | scroll 10 columns left / right |
| `<Esc>` | clear search highlight |
| completion | `<C-n>` `<C-p>` select, `<CR>` confirm, `<C-Space>` open, `<C-e>` close, `<C-l>` `<C-h>` jump in snippets |
| Copilot | `<Tab>` accepts |

## What changed in the review

Bugs fixed:

- **Treesitter crashed on any fresh install.** The plugin moved its default branch to an incompatible rewrite,
  the config used the old API, and nothing was pinned. Now: `main` branch with the new API, pinned.
- **Go had no `gd`/`K`/rename mappings.** Keymaps were attached only to the four servers listed in `lsp.lua`;
  gopls was added later. Keymaps now come from an `LspAttach` handler, so every server gets them.
- **Completion was configured twice** (in `init.lua` and `plugins.lua`) with different settings; the copy in
  `init.lua` silently won. Now one setup.
- **lspkind icons never appeared**: lspkind was initialized but not wired into the completion menu.
- **`\f` (format) waited a full second** because `\fb`, `\fh` and `\fg` share the prefix. Formatting moved to
  `\cf`; `:Format` still works.
- **`<C-h>`/`<C-l>` did nothing**: they scroll sideways, but line wrapping was on. Wrapping is now off.
- **Opening a Python file cost ~480 ms**, spent probing Neovim's Python provider, which no plugin uses.
  Unused providers are disabled.
- **nvim-scrollbar would break on 2026-11-16**, when its v2 replaces the main branch. Pinned to `v1`.
- **The Makefile pointed at `./scripts/install-tools.sh`**, but the script was at the repo root; and `make nvim`
  ran `ln -sfn` against an existing `~/.config/nvim` directory, which created `~/.config/nvim/nvim` instead
  of linking. Both fixed (the link step now backs up first).
- **The lockfile pinned 9 of ~40 plugins**, so installs were not reproducible. It now pins all of them.
- **Copilot was an untracked copy** in `pack/`, outside the repo. It is now a normal plugin.
- Smaller: an undefined `highlight` variable in the indent-guide setup; deprecated `vim.loop` and
  `nvim_err_writeln`; `mason.setup()` ran twice; yanky tracked normal-mode yanks only.

Replaced: **formatter.nvim → conform.nvim** (same formatters: pg_format, black, stylua, jq, plus goimports + gofmt
for Go; asynchronous, and it can format a range).

Added: lualine (statusline), gitsigns (git signs and hunks), trouble (diagnostics list), fidget (LSP progress),
telescope-fzf-native (faster sorting), cmp-cmdline (completion on `:` and `/`), cmp_luasnip + friendly-snippets
(snippets in the menu).

Everything else is your plugin set and your keymaps, now lazy-loaded.

## More plugins worth a look (not added)

| Plugin | Why |
|---|---|
| `stevearc/oil.nvim` | edit directories like a buffer (rename/move files with normal editing) |
| `ThePrimeagen/harpoon` (branch `harpoon2`) | pin 4–5 files and jump between them instantly |
| `kdheepak/lazygit.nvim` | full lazygit inside Neovim |
| `MeanderingProgrammer/render-markdown.nvim` | pretty markdown rendering in the buffer |
| `mfussenegger/nvim-dap-python` | ready-made Python debugging for your dap setup (needs `debugpy`) |
| `nvim-neotest/neotest` + `neotest-python` | run and see tests from the editor |
