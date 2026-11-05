-- Look & feel: tokyonight tuned to the archminimal palette (cyan accent,
-- dim chrome), a minimal statusline, buffer tabs, indent guides, scrollbar.

local accent = "#00e5ff"
local danger = "#ff2a6d"
local mute = "#7d8088"
local dim = "#4a4c54"
local faint = "#2e3037"
local panel = "#18191d"

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "moon",
				transparent = true, -- the terminal's background shows through
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = { bold = true },
					functions = { italic = false },
					sidebars = "transparent",
					floats = "transparent",
				},
				on_highlights = function(hl, c)
					-- chrome
					hl.CursorLineNr = { fg = accent, bold = true }
					hl.LineNr = { fg = dim }
					hl.LineNrAbove = { fg = dim }
					hl.LineNrBelow = { fg = dim }
					hl.CursorLine = { bg = "#1f2026" }
					hl.WinSeparator = { fg = faint }
					hl.FloatBorder = { fg = dim }
					hl.FloatTitle = { fg = accent }
					hl.NormalFloat = { bg = "NONE" }
					hl.Visual = { bg = "#1d3a45" }
					hl.Search = { bg = "#1d3a45", fg = accent }
					hl.IncSearch = { bg = accent, fg = panel }
					hl.MatchParen = { fg = accent, bold = true, underline = true }
					-- whitespace markers: visible only when you look for them
					hl.Whitespace = { fg = faint }
					hl.NonText = { fg = faint }
					-- completion menu
					hl.Pmenu = { bg = panel, fg = c.fg }
					hl.PmenuSel = { bg = "#1d3a45", fg = accent }
					hl.PmenuSbar = { bg = panel }
					hl.PmenuThumb = { bg = dim }
					hl.CmpItemAbbrMatch = { fg = accent, bold = true }
					hl.CmpItemAbbrMatchFuzzy = { fg = accent }
					-- telescope
					hl.TelescopeBorder = { fg = dim }
					hl.TelescopePromptBorder = { fg = accent }
					hl.TelescopePromptPrefix = { fg = accent }
					hl.TelescopeSelectionCaret = { fg = accent }
					hl.TelescopeSelection = { bg = "#1d3a45" }
					hl.TelescopeMatching = { fg = accent, bold = true }
					hl.TelescopeTitle = { fg = mute }
					-- indent guides
					hl.IblIndent = { fg = faint, nocombine = true }
					hl.IblScope = { fg = dim, nocombine = true }
					-- diagnostics accents
					hl.DiagnosticError = { fg = danger }
					hl.DiagnosticVirtualTextError = { fg = danger, bg = "NONE" }
				end,
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- statusline: lowercase, no powerline arrows, one cyan accent
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local base = { fg = mute, bg = "NONE" }
			local theme = {
				normal = { a = { fg = accent, bg = "NONE", gui = "bold" }, b = base, c = base },
				insert = { a = { fg = "#9ece6a", bg = "NONE", gui = "bold" } },
				visual = { a = { fg = "#b48ef7", bg = "NONE", gui = "bold" } },
				replace = { a = { fg = danger, bg = "NONE", gui = "bold" } },
				command = { a = { fg = "#e0af68", bg = "NONE", gui = "bold" } },
				inactive = { a = base, b = base, c = base },
			}
			require("lualine").setup({
				options = {
					theme = theme,
					globalstatus = true,
					component_separators = "",
					section_separators = "",
				},
				sections = {
					lualine_a = { { "mode", fmt = string.lower } },
					lualine_b = { { "branch", icon = "" }, "diff" },
					lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " " } } },
					lualine_x = { "diagnostics", { "filetype", colored = false } },
					lualine_y = { "progress" },
					lualine_z = { { "location", color = { fg = mute } } },
				},
			})
		end,
	},

	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
			{ "<leader>e", "<Cmd>bd<CR>", desc = "Delete buffer" },
		},
		opts = {
			options = {
				mode = "buffers",
				numbers = "none",
				diagnostics = "nvim_lsp",
				show_close_icon = false,
				show_buffer_close_icons = false,
				separator_style = { "", "" },
				indicator = { style = "underline" },
				always_show_bufferline = true,
			},
			highlights = {
				buffer_selected = { fg = accent, bold = true, italic = false },
				indicator_selected = { fg = accent, sp = accent },
				fill = { bg = "NONE" },
				background = { fg = mute },
			},
		},
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = { char = "│" },
			whitespace = { remove_blankline_trail = false },
			scope = { enabled = true, show_start = false, show_end = false },
		},
	},

	{
		"petertriho/nvim-scrollbar",
		-- v2 replaces main on 2026-11-16 with a breaking config change; stay on v1
		branch = "v1",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("scrollbar").setup({
				handle = { color = faint },
				marks = { Search = { color = accent }, Error = { color = danger } },
			})
			pcall(function() require("scrollbar.handlers.gitsigns").setup() end)
		end,
	},

	-- NEW: git changes in the sign column + hunk actions
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
			on_attach = function(buf)
				local gs = require("gitsigns")
				local function map(l, r, desc) vim.keymap.set("n", l, r, { buffer = buf, desc = desc }) end
				map("]h", function() gs.nav_hunk("next") end, "Next hunk")
				map("[h", function() gs.nav_hunk("prev") end, "Prev hunk")
				map("<leader>hp", gs.preview_hunk, "Preview hunk")
				map("<leader>hs", gs.stage_hunk, "Stage hunk")
				map("<leader>hr", gs.reset_hunk, "Reset hunk")
				map("<leader>hb", gs.blame_line, "Blame line")
			end,
		},
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix",
			spec = {
				{ "<leader>f", group = "find" },
				{ "<leader>h", group = "git hunk" },
				{ "<leader>c", group = "code" },
				{ "<leader>s", group = "send to repl" },
				{ "<leader>x", group = "diagnostics" },
				{ "<leader>d", group = "debug / db" },
				{ "<leader>b", group = "buffers / breakpoints" },
			},
		},
	},

	-- NEW: small LSP progress spinner in the corner
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = { notification = { window = { winblend = 0, border = "none" } } },
	},

	{
		"folke/todo-comments.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = { { "<leader>td", "<cmd>TodoTelescope<CR>", desc = "Search TODOs" } },
		opts = {},
	},
}
