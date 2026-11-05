-- Finding, moving and editing text.
return {
	{
		"nvim-telescope/telescope.nvim",
		-- not lazy: the file browser replaces netrw when you run `nvim <dir>`
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			-- NEW: native fzf sorter, much faster on big repos (needs make + cc)
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
		},
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({
				defaults = {
					prompt_prefix = "  › ",
					selection_caret = "▍ ",
					entry_prefix = "  ",
					sorting_strategy = "ascending",
					layout_config = { prompt_position = "top", width = 0.85, height = 0.8, preview_width = 0.55 },
					borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
					file_ignore_patterns = { "%.git/", "node_modules/", "__pycache__/", "%.venv/" },
					path_display = { "truncate" },
				},
				pickers = {
					find_files = { hidden = true },
				},
				extensions = {
					file_browser = { hijack_netrw = true, hidden = { file_browser = true, folder_browser = true } },
				},
			})
			telescope.load_extension("file_browser")
			pcall(telescope.load_extension, "fzf")

			local map = vim.keymap.set
			map("n", "<leader>fb", "<cmd>Telescope file_browser<CR>", { desc = "File browser" })
			map("n", "<C-f>", builtin.live_grep, { desc = "Live grep (project)" })
			map("n", "<C-p>", builtin.find_files, { desc = "Find files" })
			map("n", "<leader>bb", builtin.buffers, { desc = "Buffers" })
			map("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
			map("n", "<leader>fg", function() builtin.live_grep({ search_dirs = { "." } }) end, { desc = "Live grep (cwd)" })
			-- NEW
			map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
			map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
			map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Symbols in file" })
			map("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
		end,
	},

	{
		"gbprod/yanky.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		event = "VeryLazy",
		config = function()
			require("yanky").setup({ highlight = { on_put = true, on_yank = true, timer = 200 } })
			require("telescope").load_extension("yank_history")
			local map = vim.keymap.set
			map("n", "<leader>y", "<cmd>Telescope yank_history<CR>", { desc = "Clipboard history" })
			-- normal AND visual, so every yank/put goes through the history
			map({ "n", "x" }, "y", "<Plug>(YankyYank)")
			map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
			map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
		end,
	},

	{
		"echasnovski/mini.jump2d",
		keys = { { "s", desc = "Jump anywhere" } },
		opts = { mappings = { start_jumping = "s" } },
	},

	{ "echasnovski/mini.ai", event = "VeryLazy", opts = {} },

	{ "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = { check_ts = true, disable_filetype = { "TelescopePrompt", "vim" } },
	},

	{
		"mg979/vim-visual-multi",
		branch = "master",
		event = { "BufReadPost", "BufNewFile" }, -- default keys: <C-n> select word, <C-Down>/<C-Up> add cursor
	},

	{
		"akinsho/git-conflict.nvim",
		version = "*",
		event = "BufReadPre",
		opts = {
			default_mappings = true,
			disable_diagnostics = true,
			highlights = { incoming = "DiffAdd", current = "DiffText" },
		},
	},

	-- NEW: a pretty, navigable list of diagnostics / references / quickfix
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (project)" },
			{ "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Diagnostics (buffer)" },
			{ "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "References / definitions" },
		},
		opts = {},
	},
}
