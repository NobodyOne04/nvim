-- Finding, moving and editing text; files; sessions.
local function telescope(picker, opts)
	return function() require("telescope.builtin")[picker](opts) end
end

return {
	-- Telescope now loads on first use (it no longer has to open directories;
	-- oil does that), which takes it off the startup path.
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- native fzf sorter, much faster on big repos (needs make + cc)
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
		},
		keys = {
			{ "<C-p>", telescope("find_files"), desc = "Find files" },
			{ "<C-f>", telescope("live_grep"), desc = "Live grep (project)" },
			{ "<leader>bb", telescope("buffers"), desc = "Buffers" },
			{ "<leader>fh", telescope("help_tags"), desc = "Help" },
			{ "<leader>fg", telescope("live_grep", { search_dirs = { "." } }), desc = "Live grep (cwd)" },
			{ "<leader>fr", telescope("oldfiles"), desc = "Recent files" },
			{ "<leader>fd", telescope("diagnostics"), desc = "Diagnostics" },
			{ "<leader>fs", telescope("lsp_document_symbols"), desc = "Symbols in file" },
			{ "<leader>fw", telescope("grep_string"), desc = "Grep word under cursor" },
			{ "<leader>fk", telescope("keymaps"), desc = "Keymaps" },
		},
		config = function()
			local telescope_ = require("telescope")
			telescope_.setup({
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
				pickers = { find_files = { hidden = true } },
			})
			pcall(telescope_.load_extension, "fzf")
		end,
	},

	-- Directories as editable buffers: rename, move, create or delete files by
	-- editing lines, then :w. `-` opens the parent folder, `nvim .` opens here.
	-- Replaces telescope-file-browser (\fb still opens a file browser).
	{
		"stevearc/oil.nvim",
		lazy = false, -- must be loaded to open directories (`nvim .`)
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
			{ "<leader>fb", function() require("oil").open_float() end, desc = "File browser" },
		},
		opts = {
			default_file_explorer = true,
			delete_to_trash = true, -- deleted lines go to the trash, not straight to oblivion
			columns = { "icon" },
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name) return name == ".." or name == ".git" end,
			},
			float = { padding = 3, max_width = 100, max_height = 32 },
			keymaps = {
				-- keep your global keys working inside oil
				["<C-p>"] = false, -- find files
				["<C-h>"] = false, ["<C-l>"] = false, -- side scroll
				["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open in vertical split" },
				["<C-x>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in horizontal split" },
				["gp"] = "actions.preview",
				["gR"] = "actions.refresh",
				["q"] = { "actions.close", mode = "n" },
			},
		},
	},

	{
		"gbprod/yanky.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>y",
				function()
					require("telescope").load_extension("yank_history")
					vim.cmd("Telescope yank_history")
				end,
				desc = "Clipboard history",
			},
		},
		config = function()
			require("yanky").setup({ highlight = { on_put = true, on_yank = true, timer = 200 } })
			local map = vim.keymap.set
			-- normal AND visual, so every yank/put goes through the history
			map({ "n", "x" }, "y", "<Plug>(YankyYank)")
			map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
			map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
		end,
	},

	-- mini.nvim moved to the nvim-mini organisation
	{
		"nvim-mini/mini.jump2d",
		keys = { { "s", desc = "Jump anywhere" } },
		opts = { mappings = { start_jumping = "s" } },
	},

	{ "nvim-mini/mini.ai", event = "VeryLazy", opts = {} },

	{ "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

	-- Detects each file's indentation (tabs in Go and Makefiles, 2 or 4 spaces
	-- elsewhere) so new lines match the file instead of the global default.
	{ "NMAC427/guess-indent.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },

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

	-- a navigable list of diagnostics / references / quickfix
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

	-- Search and replace across the project, with a live preview of every change.
	{
		"MagicDuck/grug-far.nvim",
		cmd = "GrugFar",
		keys = {
			{ "<leader>rp", function() require("grug-far").open() end, desc = "Replace in project" },
			{ "<leader>rp", function() require("grug-far").with_visual_selection() end, mode = "x", desc = "Replace selection in project" },
			{
				"<leader>rw",
				function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end,
				desc = "Replace word under cursor in project",
			},
		},
		opts = { headerMaxWidth = 80 },
	},

	-- Sessions: remembers open files per folder; \qs brings them back.
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
		keys = {
			{ "<leader>qs", function() require("persistence").load() end, desc = "Restore session (this folder)" },
			{ "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
			{ "<leader>qd", function() require("persistence").stop() end, desc = "Don't save this session" },
		},
	},
}
