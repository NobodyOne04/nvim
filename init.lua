-- Bootstrapping Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("plugins")

-- Basic settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.clipboard = "unnamedplus"
vim.o.mouse = "a"
vim.o.termguicolors = true

vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.updatetime = 100
vim.opt.list = true
vim.opt.listchars = {
	space = "·", -- Show spaces as dots
	tab = "→ ", -- Show tabs with an arrow
	trail = "•", -- Show trailing spaces
	eol = "↴", -- Show end of line
	nbsp = "␣", -- Show non-breaking spaces
}


-- Enable filetype-specific indenting and plugins
vim.cmd("filetype plugin indent on")

-- Filetype-specific comment strings
vim.api.nvim_set_keymap("n", "<C-d>", "10jzz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-u>", "10kzz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", "10zl", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-h>", "10zh", { noremap = true, silent = true })

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql" },
  callback = function()
    local ok, cmp = pcall(require, "cmp")
    if ok then
      cmp.setup.buffer({
        sources = {
          { name = "vim-dadbod-completion" },
          { name = "buffer" },
        },
      })
    else
      vim.api.nvim_err_writeln("nvim-cmp not found, completion will not work.")
    end
  end,
})


