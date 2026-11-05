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

-- keep splits even when the terminal is resized
au("VimResized", { group = group, command = "tabdo wincmd =" })

-- close helper windows with q
au("FileType", {
	group = group,
	pattern = { "help", "qf", "checkhealth", "lspinfo", "man", "notify" },
	callback = function(ev)
		vim.bo[ev.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
	end,
})

-- diagnostics: compact, sorted, rounded floats
vim.diagnostic.config({
	severity_sort = true,
	virtual_text = { prefix = "●", spacing = 2 },
	float = { border = "rounded", source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "󰌵",
		},
	},
})
