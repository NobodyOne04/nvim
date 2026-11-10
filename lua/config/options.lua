local opt = vim.opt

-- numbers & look
opt.number = true
opt.relativenumber = true
opt.cursorline = true           -- only in the focused window (see autocmds.lua)
opt.signcolumn = "yes"          -- no text shifting when diagnostics/git signs appear
opt.termguicolors = true
opt.showmode = false            -- the statusline shows the mode
opt.laststatus = 3              -- one global statusline
opt.cmdheight = 1
opt.pumheight = 12
opt.winborder = "rounded"       -- rounded borders on all floating windows (0.11+)
opt.fillchars = {
	eob = " ",
	vert = "│",
	diff = "╱",
	fold = " ",
	foldopen = "",
	foldclose = "",
	foldsep = " ",
}

-- Whitespace markers for what matters: trailing spaces, tabs mid-line,
-- non-breaking spaces, and lines running past the screen edge (wrap is off).
-- Indentation shows as thin guides (indent-blankline) instead of dots/arrows.
-- For the old look (a dot per space, ↴ at line ends) add: space = "·", eol = "↴"
opt.list = true
opt.listchars = {
	tab = "→ ",
	trail = "•",
	nbsp = "␣",
	extends = "›",
	precedes = "‹",
}

-- Folds follow the syntax tree (set up per file in plugins/treesitter.lua);
-- everything starts open and a folded block keeps its syntax colors.
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldtext = ""

-- editing
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smarttab = true
opt.smartindent = true
opt.wrap = false                -- your <C-h>/<C-l> side-scroll needs this
opt.sidescrolloff = 8
opt.scrolloff = 8
opt.undofile = true             -- undo survives closing the file (\u shows the undo tree)
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"        -- text stays put when a split or list opens below
opt.confirm = true              -- ask instead of failing on :q with changes
opt.inccommand = "split"        -- :%s/old/new previews every change in a split
opt.virtualedit = "block"       -- block selections can go past the end of short lines

-- timing
opt.updatetime = 100
opt.timeoutlen = 400

-- Python is needed only by molten (Jupyter, see lua/plugins/notebook.lua).
-- It gets its own venv from `make notebook`; pointing Neovim straight at it
-- skips the PATH search that cost ~480 ms every time a .py file was opened.
-- Without that venv the provider stays off.
local python_host = vim.fn.stdpath("data") .. "/python-host/bin/python"
if vim.uv.fs_stat(python_host) then
	vim.g.python3_host_prog = python_host
else
	vim.g.loaded_python3_provider = 0
end
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Not enabled: Neovim 0.12's experimental message UI (`require("vim._core.ui2")
-- .enable({})`). It removes "Press ENTER" prompts, but in testing it dropped
-- keystrokes typed while plugin messages arrived. Revisit when it's stable.
