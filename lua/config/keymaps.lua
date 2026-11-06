-- General keymaps. Plugin keymaps live next to their plugin in lua/plugins/.
local map = vim.keymap.set

-- your scrolling: 10 lines and recenter, 10 columns sideways
map("n", "<C-d>", "10jzz", { desc = "Down 10 lines" })
map("n", "<C-u>", "10kzz", { desc = "Up 10 lines" })
map("n", "<C-l>", "10zl", { desc = "Scroll right" })
map("n", "<C-h>", "10zh", { desc = "Scroll left" })

map("n", "<leader>cp", function()
	vim.fn.setreg("+", vim.fn.expand("%:p"))
	vim.notify("copied " .. vim.fn.expand("%:p"))
end, { desc = "Copy absolute file path" })

-- small quality-of-life additions
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })
map("n", "gl", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Undo tree: every earlier state of the file, even across restarts
-- (undofile is on). Built into Neovim 0.12, no plugin needed.
map("n", "<leader>u", function()
	if vim.fn.has("nvim-0.12") == 0 then
		return vim.notify("the undo tree needs Neovim 0.12+", vim.log.levels.WARN)
	end
	vim.cmd.packadd("nvim.undotree")
	vim.cmd("Undotree")
end, { desc = "Undo tree" })
