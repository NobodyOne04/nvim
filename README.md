# nvim

My Neovim config: lazy.nvim, LSP via mason, treesitter, telescope, completion (blink.cmp), Copilot, databases
(dadbod), Python REPL (iron), debugging (dap). Styled to match the archminimal desktop: tokyonight moon with a
cyan accent, transparent background, rounded borders, quiet chrome, an Arch start screen.

- Starts in **~20 ms** (about 65 ms when opening a file); almost everything loads on first use.
- **Neovim 0.12+** recommended (Arch ships 0.12). On 0.11 everything works except treesitter (basic highlighting
  instead), the sticky function header and the undo tree; it tells you once.
- Plugin versions are pinned in `lazy-lock.json`, so every machine gets the same, tested set.

## Install

```bash
git clone git@github.com:NobodyOne04/nvim.git ~/projects/nvim && cd ~/projects/nvim
make install
```

`make install` runs:

| Step | What |
|---|---|
| `make tools` | ripgrep, fd, fzf, git, a C compiler, tree-sitter CLI, node, go, python, lazygit and the formatters (pacman / brew / apt / dnf) |
| `make link` | links this repo to `~/.config/nvim`; an existing config is moved to `~/.config/nvim.bak-<date>`, never deleted |
| `make sync` | installs plugins at the versions in `lazy-lock.json`, removes plugins the config no longer uses, fetches blink.cmp's fuzzy matcher |
| `make lsp` | installs pyright, lua_ls, bashls, ts_ls, gopls and goimports with mason |

Updating an existing install: `git pull && make sync`.

Other targets: `make update` (update plugins, rewrite the lockfile, then commit it), `make check` (headless start,
fails on errors), `make startup` (timing), `make health`, `make unlink` (restore your previous config).

A [Nerd Font](https://www.nerdfonts.com) is needed for icons (`ttf-jetbrains-mono-nerd`; kitty picks up its symbols automatically).
Copilot: run `:Copilot setup` once; the token lives in `~/.config/github-copilot`.

## Layout

```text
init.lua                  leader, then config.* and plugins
lua/config/options.lua    editor options (folds, whitespace markers, splits)
lua/config/keymaps.lua    general keymaps, undo tree
lua/config/autocmds.lua   restore cursor, active-window cursor line, q closes helpers, diagnostics style
lua/config/lazy.lua       lazy.nvim bootstrap
lua/plugins/ui.lua        theme, start screen + notifications + prompts (snacks), statusline, bufferline,
                          indent guides, scrollbar, gitsigns, which-key, color swatches
lua/plugins/editor.lua    telescope, oil, yanky, jump2d, surround, autopairs, guess-indent, multi-cursor,
                          git-conflict, trouble, grug-far, sessions
lua/plugins/coding.lua    completion (blink.cmp), lazydev, Copilot
lua/plugins/lsp.lua       mason, servers, LSP keymaps, goto-preview, formatting
lua/plugins/treesitter.lua parsers, syntax folds, sticky function header
lua/plugins/tools.lua     dadbod, iron, distant, dap
scripts/                  install-tools.sh, mason-install.lua, blink-fuzzy.lua
```

## Keys

Leader is `\` (as before; it was never set explicitly). For Space, change `mapleader` in `init.lua`.
Press `\` and wait to see every leader key.

| Keys | Action |
|---|---|
| `nvim` (no file) | start screen: `f` find, `g` grep, `r` recent, `e` files, `s` restore session, `G` lazygit, `c` config, `q` quit; `1`–`5` open a recent file |
| `<C-p>` / `<C-f>` | find files / live grep (project) |
| `\fg` `\fh` `\fr` `\fd` `\fs` `\fw` `\fk` | grep in cwd / help / recent files / diagnostics / symbols / word under cursor / **keymaps** |
| `-` | **file browser** (oil) on the current file's folder: edit names and `:w` to rename, move, create, delete (to trash) |
| `\fb` | the same file browser in a float (`q` closes, `g?` help, `gp` preview, `<C-s>`/`<C-x>` open in split) |
| `\bb` | buffers |
| `<Tab>` / `<S-Tab>` / `\e` | next / previous buffer / close buffer (**now keeps your splits**) |
| `s` | jump anywhere (mini.jump2d) |
| `\y` | yank history |
| `\cp` | copy the file's absolute path |
| `\td` | TODOs |
| `\rp` / `\rw` | **search & replace in the project** (grug-far; in visual mode `\rp` uses the selection) / for the word under the cursor |
| `\u` | **undo tree** (Neovim 0.12, built in) |
| `za` `zc` `zo` `zM` `zR` | **folds** by syntax: toggle / close / open / close all / open all |
| `\gg` / `\gl` | **lazygit** in a float / git history of this file |
| `\qs` / `\ql` / `\qd` | **restore session** for this folder / last session / don't save this one |
| `\n` | notification history |
| `gd` `gD` `K` | definition / declaration / hover (every language server) |
| `\rn` `\ca` `\ch` | rename (in a small box at the cursor) / code action (in a picker) / toggle inlay hints |
| `]]` `[[` | **next / previous use** of the word under the cursor (all uses are highlighted) |
| `gpd` `gpi` `gpr` `gP` | peek definition / implementation / references, close previews |
| `gl` | diagnostics for the line |
| `\cf` or `:Format` | format |
| `\ct` | toggle the sticky function header |
| `\xx` `\xb` `\xr` | diagnostics list (project / buffer), references (trouble) |
| `]h` `[h` `\hp` `\hs` `\hr` `\hb` | next/prev git hunk, preview, stage, reset, blame |
| `\db` | database UI |
| `\sc` `\sf` `\sl` `\sq` `\cl` | send motion/selection / file / line to the REPL, quit, clear |
| `\du` `\bp` `F5` `F10` `F11` `F12` | debug UI, breakpoint, continue, step over / into / out |
| `<C-d>` `<C-u>` | 10 lines down / up and recenter |
| `<C-h>` `<C-l>` | scroll 10 columns left / right |
| `<Esc>` | clear search highlight |
| completion | `<C-n>` `<C-p>` select, `<CR>` confirm, `<C-Space>` open / docs, `<C-e>` close, `<C-b>` `<C-f>` scroll docs, `<C-l>` `<C-h>` jump in snippets, `<C-k>` signature |
| Copilot | `<Tab>` accepts |

## Design pass (November 2026)

Look:

- **Start screen** with the Arch logo in the desktop's cyan, the wordmark, shortcuts, recent files and startup time.
- **Whitespace**: indentation is drawn as thin guides, for tabs too (Go, Makefiles), instead of an arrow per tab
  and a dot per space. Trailing spaces, mid-line tabs and lines running past the edge are still marked.
  For the old dots, add `space = "·", eol = "↴"` to `listchars` in `options.lua`.
- **Diagnostics**: signs and underlines on every affected line; the message only on the line you're on.
- **Statusline**: OS logo (Arch / Apple, as in the zsh prompt), `recording @q` while recording a macro (there was
  no indicator before), search count, language server names.
- **Folds** follow the syntax tree; a folded block keeps its colors. Cursor line only in the focused split.
- Completion menu, docs and signature help, notifications, the rename box and code-action picker all share the
  same rounded, cyan-accented style. `#rrggbb` colors get a swatch.

Same number of plugins (47), more features, faster start:

| Change | Why |
|---|---|
| nvim-cmp + cmp-nvim-lsp, -buffer, -path, -cmdline, cmp_luasnip, LuaSnip, lspkind → **blink.cmp** | one plugin instead of eight; native fuzzy matcher that forgives typos; docs and function signature while you type |
| telescope-file-browser → **oil.nvim** | edit folders like text; telescope no longer loads at startup |
| + **snacks.nvim** | start screen, notifications, rename box, picker for code actions, buffer delete that keeps splits, highlight + jump between uses of a word, lazygit float, fast big files |
| + **nvim-treesitter-context** | sticky function / class header while scrolling |
| + **grug-far.nvim** | project-wide search & replace with a live preview |
| + **guess-indent.nvim** | new lines match each file's indentation (tabs in Go, 2 or 4 spaces elsewhere) |
| + **persistence.nvim** | sessions per folder |
| + **lazydev.nvim** | Neovim API types and completion when editing this config |
| + **mini.hipatterns** | color swatches |
| built into Neovim 0.12, no plugin | undo tree (`\u`) |
| + parsers | QML (Quickshell), Terraform/HCL, go.mod, git commit/rebase/config, diff, ini, xml, csv, ssh config |

Fixed:

- **Several icons were empty**: error / warning / info signs in the sign column, the git "deleted line" sign, the
  branch icon. The characters had been lost when the files were written; they're now in place.
- mini.nvim moved to the `nvim-mini` GitHub organisation; specs updated (`make sync` switches existing clones).

Tested on Arch (Neovim 0.12.6, upgrade from the previous config with `make sync`, screenshots in kitty) and macOS
(Neovim 0.11.2).

## More plugins worth a look (not added)

| Plugin | Why |
|---|---|
| `yamlls` + `b0o/SchemaStore.nvim` | completion and validation for Kubernetes, docker-compose, GitHub Actions YAML |
| `ThePrimeagen/harpoon` (branch `harpoon2`) | pin 4–5 files and jump between them instantly |
| `MeanderingProgrammer/render-markdown.nvim` | pretty markdown rendering in the buffer |
| `mfussenegger/nvim-dap-python` | ready-made Python debugging for your dap setup (needs `debugpy`) |
| `nvim-neotest/neotest` + `neotest-python` | run and see tests from the editor |
| Neovim 0.12 `ui2` | new message UI without "Press ENTER"; experimental, and in testing it dropped keystrokes typed while messages arrived, so it's off |

## Earlier review (November 2026)

- Treesitter crashed on fresh installs (plugin moved to an incompatible rewrite, old API, nothing pinned): now
  `main` branch with the new API, pinned.
- Go had no `gd`/`K`/rename: keymaps now come from an `LspAttach` handler, so every server gets them.
- Completion was configured twice; lspkind icons never showed; `\f` (format) waited a full second (moved to `\cf`);
  `<C-h>`/`<C-l>` did nothing (wrap was on); opening a Python file cost ~480 ms (unused providers disabled);
  nvim-scrollbar pinned to `v1` before its breaking v2; Makefile paths and the link step fixed; lockfile pins
  everything; Copilot is a managed plugin.
