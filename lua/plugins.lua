return {
	"folke/lazy.nvim",
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		config = function()
			require("lsp") -- your LSP setup
		end,
	},
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim" }, -- must declare
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "pyright", "ts_ls", "lua_ls", "bashls" },
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},
	{
		"tpope/vim-dadbod",
		dependencies = {
			"kristijanhusak/vim-dadbod-ui",
			"kristijanhusak/vim-dadbod-completion",
		},
		config = function()
			-- Keybinding to open DBUI
			vim.keymap.set("n", "<Leader>db", ":DBUI<CR>", { noremap = true, silent = true })

			-- Optional: Auto-close DBUI when quitting Neovim
			vim.g.db_ui_auto_execute_table_helpers = 1
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "python" },
				highlight = { enable = true },
			})
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("dapui").setup()
		end,
	},
	{
		"nvim-neotest/nvim-nio",
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({
				extensions = {
					file_browser = {
						hijack_netrw = true,
					},
				},
			})
			telescope.load_extension("file_browser")

			-- Mapping for calling the TFB window.
			vim.api.nvim_set_keymap("n", "<leader>fb", ":Telescope file_browser<CR>", { noremap = true, silent = true })
			-- 🔍 Live grep (search text in all files)
			vim.keymap.set("n", "<C-f>", builtin.live_grep, { desc = "Live Grep (search text in all files)" })
			-- 📄 Find files by name
			vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find Files (by name)" })
			-- 🗂️ List open buffers
			vim.keymap.set("n", "<leader>bb", builtin.buffers, { desc = "Find Buffers (open files)" })
			-- 📚 Search Neovim help
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help (Neovim docs)" })
			-- 🔎 Live grep (current folder only)
			vim.keymap.set("n", "<leader>fg", function()
				builtin.live_grep({ search_dirs = { "." } })
			end, { desc = "Live Grep (current folder only)" })
		end,
	},
	{
		"echasnovski/mini.jump2d",
		config = function()
			require("mini.jump2d").setup({
				mappings = {
					start_jumping = "s", -- Press s to jump
				},
			})
		end,
	},
	{
		"echasnovski/mini.ai",
		config = function()
			require("mini.ai").setup()
		end,
	},
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "moon", -- Options: "night", "moon", "day", "storm"
				transparent = true, -- Set to false if you want a solid background
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = { bold = true },
					functions = { italic = false },
				},
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({
				indent = { highlight = highlight, char = "│" }, -- Customize the indent character
				whitespace = {
					highlight = highlight,
					remove_blankline_trail = false,
				},
				scope = { enabled = true },
			})
		end,
	},
	{
		"mhartington/formatter.nvim",
		config = function()
			require("formatter").setup({
				filetype = {
					sql = {
						function()
							return {
								exe = "pg_format",
								args = {},
								stdin = true,
							}
						end,
					},
					python = {
						function()
							return {
								exe = "black", -- Python
								args = { "--fast", "-" },
								stdin = true,
							}
						end,
					},
					lua = {
						function()
							return {
								exe = "stylua", -- Lua
								args = { "-" },
								stdin = true,
							}
						end,
					},
					json = {
						function()
							return {
								exe = "jq", -- JSON
								args = { "." },
								stdin = true,
							}
						end,
					},
				},
			})
			vim.api.nvim_set_keymap("n", "<leader>f", ":Format<CR>", { noremap = true, silent = true })
		end,
	},
	{
		"chipsenkbeil/distant.nvim",
		config = function()
			require("distant"):setup()
		end,
	},
	{
		"petertriho/nvim-scrollbar",
		config = function()
			require("scrollbar").setup()
		end,
	},
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		config = function()
			require("git-conflict").setup({
				default_mappings = true,
				disable_diagnostics = true,
				highlights = {
					incoming = "DiffAdd",
					current = "DiffText",
				},
			})
		end,
	},
	{
		"rmagatti/goto-preview",
		config = function()
			require("goto-preview").setup({
				width = 120,
				height = 25,
				default_mappings = true,
			})
		end,
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					numbers = "none",
					diagnostics = "nvim_lsp",
					show_close_icon = false,
					show_buffer_close_icons = false,
					separator_style = "thin",
					always_show_bufferline = true,
				},
			})

			-- 🔥 Buffer navigation keymaps
			vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
			vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
			vim.keymap.set("n", "<leader>e", "<Cmd>bd<CR>", { desc = "Delete buffer" })
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true, -- enable Treesitter integration
				disable_filetype = { "TelescopePrompt", "vim" },
			})
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({})
			-- 🔍 Keymap to search TODOs with Telescope
			vim.keymap.set("n", "<leader>td", "<cmd>TodoTelescope<CR>", { desc = "Search TODOs" })
		end,
	},
	{
		"onsails/lspkind.nvim",
		event = "VeryLazy",
		config = function()
			require("lspkind").init({
				mode = "symbol_text", -- Options: 'text', 'text_symbol', 'symbol_text', 'symbol'
				preset = "default",
				symbol_map = {
					Text = "󰉿",
					Method = "󰆧",
					Function = "󰊕",
					Constructor = "",
					Field = "󰜢",
					Variable = "󰀫",
					Class = "󰠱",
					Interface = "",
					Module = "",
					Property = "󰜢",
					Unit = "󰑭",
					Value = "󰎠",
					Enum = "",
					Keyword = "󰌋",
					Snippet = "",
					Color = "󰏘",
					File = "󰈙",
					Reference = "󰈇",
					Folder = "󰉋",
					EnumMember = "",
					Constant = "󰏿",
					Struct = "󰙅",
					Event = "",
					Operator = "󰆕",
					TypeParameter = "",
				},
			})
		end,
	},
	{
		"gbprod/yanky.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("yanky").setup({
				highlight = {
					on_put = true,
					on_yank = true,
				},
			})
			require("telescope").load_extension("yank_history")

			-- 🔥 Keybindings
			vim.keymap.set(
				"n",
				"<leader>y",
				"<cmd>Telescope yank_history<CR>",
				{ desc = "Clipboard history (yanky)", noremap = true, silent = true }
			)
			vim.keymap.set("n", "p", "<Plug>(YankyPutAfter)")
			vim.keymap.set("n", "P", "<Plug>(YankyPutBefore)")
			--vim.keymap.set("n", "gp", "<Plug>(YankyGPutAfter)")
			--vim.keymap.set("n", "gP", "<Plug>(YankyGPutBefore)")
			vim.keymap.set("n", "y", "<Plug>(YankyYank)")
		end,
	},
	{
		"mg979/vim-visual-multi",
		branch = "master",
	},
	{
		"Vigemus/iron.nvim",
		config = function()
			local iron = require("iron.core")

			iron.setup({
				config = {
					repl_definition = {
						python = {
							command = { "ipython" },
						},
					},
					repl_open_cmd = "vertical botright 60 split",
				},
				keymaps = {
					send_motion = "<leader>sc",
					visual_send = "<leader>sc",
					send_file = "<leader>sf",
					send_line = "<leader>sl",
					cr = "<leader>s<cr>",
					interrupt = "<leader>s<space>",
					exit = "<leader>sq",
					clear = "<leader>cl",
				},
				highlight = {
					italic = true,
				},
				ignore_blank_lines = true,
			})
		end,
	},
	{
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({})
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
}
