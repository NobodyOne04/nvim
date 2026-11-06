-- Jupyter notebooks.
--
--   jupytext.nvim  opens .ipynb as a plain script with `# %%` cell markers and
--                  writes it back into the notebook on save (outputs kept)
--   molten-nvim    runs the code in a real Jupyter kernel; output shows under
--                  each cell, plots included
--   image.nvim     draws those plots in the terminal (Ghostty/kitty protocol)
--
-- Needs `make notebook` once (python host + jupytext CLI) and a kernel for
-- each project venv: `make kernel VENV=path/to/.venv`.
-- Cell helpers and keymaps: lua/config/notebook.lua. Keys live under <leader>j.

local nb = function(fn, ...)
	local args = { ... }
	return function() require("config.notebook")[fn](unpack(args)) end
end

return {
	{
		-- Must be loaded before a notebook is read: it owns BufReadCmd *.ipynb.
		-- Setup only registers that autocmd, so loading at startup is free.
		"GCBallesteros/jupytext.nvim",
		lazy = false,
		opts = { style = "percent", output_extension = "auto" },
		config = function(_, opts)
			require("jupytext").setup(opts)
			require("config.notebook").autocmds()
		end,
	},

	{
		"3rd/image.nvim",
		lazy = true,
		opts = {
			backend = "kitty", -- Ghostty speaks the kitty graphics protocol
			processor = "magick_cli",
			-- Only molten draws images; no inline images in markdown etc.
			integrations = {
				markdown = { enabled = false },
				asciidoc = { enabled = false },
				neorg = { enabled = false },
				rst = { enabled = false },
				typst = { enabled = false },
				html = { enabled = false },
				css = { enabled = false },
			},
			max_width = 100,
			max_height = 20,
			max_height_window_percentage = 50,
			window_overlap_clear_enabled = true, -- hide plots under floats (pickers, hover)
			hijack_file_patterns = {},
		},
	},

	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		build = ":UpdateRemotePlugins",
		dependencies = { "3rd/image.nvim" },
		-- No `cmd` here: molten's commands come from the remote-plugin manifest
		-- (`:UpdateRemotePlugins`) and lazy's stand-ins would replace them.
		init = function()
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_virt_text_output = true -- outputs stay under their cells
			vim.g.molten_virt_lines_off_by_1 = false -- percent cells end on code, not a ``` fence
			vim.g.molten_virt_text_max_lines = 20
			vim.g.molten_auto_open_output = false -- the float only on <leader>jo
			vim.g.molten_wrap_output = true
			vim.g.molten_output_win_max_height = 30
			vim.g.molten_use_border_highlights = true
			vim.g.molten_tick_rate = 150 -- snappier streaming output
			vim.g.molten_enter_output_behavior = "open_and_enter"
		end,
		keys = {
			{ "<leader>ji", nb("init"), desc = "Start kernel" },
			{ "<leader>jr", nb("run_cell"), desc = "Run cell" },
			{ "<leader>jn", nb("run_cell", true), desc = "Run cell, go to next" },
			{ "<leader>ja", nb("run_all"), desc = "Run all cells" },
			{ "<leader>jA", nb("run_above"), desc = "Run cells above + this one" },
			{ "<leader>jb", nb("run_below"), desc = "Run this cell + below" },
			{ "<leader>jl", nb("run_line"), desc = "Run line" },
			{ "<leader>jr", nb("run_visual"), mode = "x", desc = "Run selection" },
			{ "<leader>jo", "<cmd>noautocmd MoltenEnterOutput<cr>", desc = "Open output (enter it)" },
			{ "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide output float" },
			{ "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Delete cell output" },
			{ "<leader>jD", "<cmd>MoltenDelete!<cr>", desc = "Delete all outputs" },
			{ "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Interrupt kernel" },
			{ "<leader>jR", "<cmd>MoltenRestart!<cr>", desc = "Restart kernel (clear outputs)" },
			{ "<leader>jp", "<cmd>MoltenImagePopup<cr>", desc = "Open plot in image viewer" },
			{ "<leader>jc", nb("new_cell", "code"), desc = "New code cell below" },
			{ "<leader>jm", nb("new_cell", "markdown"), desc = "New markdown cell below" },
		},
	},
}
