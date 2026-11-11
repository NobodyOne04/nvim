local au = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("archminimal", { clear = true })

-- reopen files where you left them
au("BufReadPost", {
	group = group,
	callback = function(ev)
		local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
		local lines = vim.api.nvim_buf_line_count(ev.buf)
		if mark[1] > 0 and mark[1] <= lines and vim.bo[ev.buf].filetype ~= "gitcommit" then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- reload files changed outside Neovim (git, formatters, Claude Code in the next pane);
-- unsaved buffers are never overwritten, 'autoread' only reloads clean ones
au({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
	group = group,
	callback = function()
		if vim.fn.getcmdwintype() == "" and vim.bo.buftype == "" then vim.cmd("silent! checktime") end
	end,
})

-- keep splits even when the terminal is resized
au("VimResized", { group = group, command = "tabdo wincmd =" })


-- cursor line only in the focused window, so it's clear which split is active
au({ "WinEnter", "BufWinEnter" }, {
	group = group,
	callback = function()
		if vim.bo.buftype == "" then vim.wo.cursorline = true end
	end,
})
au("WinLeave", {
	group = group,
	callback = function()
		if vim.bo.buftype == "" then vim.wo.cursorline = false end
	end,
})

-- close helper windows with q
au("FileType", {
	group = group,
	pattern = { "help", "qf", "checkhealth", "lspinfo", "man", "notify", "nvim-undotree", "grug-far" },
	callback = function(ev)
		vim.bo[ev.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
	end,
})

-- Diagnostics: sign + underline on every affected line; the message itself
-- only on the line the cursor is on. Quiet code, nothing hidden: `gl` shows
-- the full text, \xx lists everything, the statusline counts them.
vim.diagnostic.config({
	severity_sort = true,
	underline = true,
	virtual_text = { current_line = true, prefix = "●", spacing = 2 },
	float = { border = "rounded", source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "󰌵",
		},
	},
})

-- ADR buffers: status keys under <leader>A, ]A/[A between ADRs, coloured status
au({ "BufReadPost", "BufNewFile" }, {
	group = group,
	pattern = "*.adr",
	callback = function(ev) require("config.adr").attach(ev.buf) end,
})
