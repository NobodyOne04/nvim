local opt = vim.opt

-- numbers & look
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"          -- no text shifting when diagnostics/git signs appear
opt.termguicolors = true
opt.showmode = false            -- the statusline shows the mode
opt.laststatus = 3              -- one global statusline
opt.cmdheight = 1
opt.pumheight = 12
opt.winborder = "rounded"       -- rounded borders on all floating windows (0.11+)
opt.fillchars = { eob = " ", vert = "│", fold = " " }

-- whitespace markers (kept from your config; colored very dim by the theme)
opt.list = true
opt.listchars = {
	space = "·",
	tab = "→ ",
	trail = "•",
	eol = "↴",
	nbsp = "␣",
}

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
opt.undofile = true             -- undo survives closing the file
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.confirm = true              -- ask instead of failing on :q with changes

-- timing
opt.updatetime = 100
opt.timeoutlen = 400

-- No plugin here needs Neovim's remote-plugin providers; probing Python alone
-- cost ~480 ms every time a .py file was opened.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
