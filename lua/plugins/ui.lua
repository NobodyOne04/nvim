-- Look & feel: tokyonight tuned to the archminimal palette (cyan accent, dim
-- chrome), a start screen, a minimal statusline, buffer tabs, indent guides,
-- scrollbar, and notifications / prompts / pickers in the same style.

local accent = "#00e5ff"
local danger = "#ff2a6d"
local mute = "#7d8088"
local dim = "#4a4c54"
local faint = "#2e3037"
local panel = "#18191d"
local raised = "#1f2026" -- cursor line, folds, sticky context
local selected = "#1d3a45" -- cyan-tinted selection

-- Which OS we're on: "mac", "arch" or "linux" (any other distro).
local function detect_os()
	if vim.fn.has("mac") == 1 then return "mac" end
	local f = io.open("/etc/os-release")
	local release = f and f:read("*a") or ""
	if f then f:close() end
	return release:find("arch") and "arch" or "linux"
end
local os_name = detect_os()

-- The OS logo, as in the zsh prompt: Arch on Arch, Apple on macOS.
local function os_logo()
	return ({ mac = "\u{f179}", arch = "\u{f303}" })[os_name] or "\u{f17c}"
end

-- Pad every line to the same width, so centering keeps the art's shape.
local function art(lines)
	local w = 0
	for _, l in ipairs(lines) do w = math.max(w, #l) end
	for i, l in ipairs(lines) do lines[i] = l .. string.rep(" ", w - #l) end
	return table.concat(lines, "\n")
end

-- Start screen header: the logo of the OS we're running on. The wordmark
-- under it is a separate, quieter section.
local logos = {
	arch = art({
		[[      /\      ]],
		[[     /  \     ]],
		[[    /\   \    ]],
		[[   /      \   ]],
		[[  /   ,,   \  ]],
		[[ /   |  |  -\ ]],
		[[/_-''    ''-_\]],
	}),
	mac = art({
		[[        .:']],
		[[    __ :'__]],
		[[ .'`__`-'__``.]],
		[[:__________.-']],
		[[:_________:]],
		[[ :_________`-;]],
		[[  `.__.-.__.']],
	}),
	linux = art({
		[[    .--.]],
		[[   |o_o |]],
		[[   |:_/ |]],
		[[  //   \ \]],
		[[ (|     | )]],
		[[/'\_   _/`\]],
		[[\___)=(___/]],
	}),
}
local os_header = logos[os_name]

-- Wordmark under the logo: the config name on Arch, the platform elsewhere.
local function os_wordmark()
	if os_name == "arch" then return "archminimal" end
	if os_name == "mac" then
		return vim.uv.os_uname().machine == "arm64" and "apple silicon" or "intel mac"
	end
	local f = io.open("/etc/os-release")
	local release = f and f:read("*a") or ""
	if f then f:close() end
	return (release:match('\nNAME="?([^"\n]+)') or release:match('^NAME="?([^"\n]+)') or "linux"):lower()
end
-- Letter-spaced, matching the dashboard's quiet title style.
local wordmark = os_wordmark():gsub(".", "%0 "):sub(1, -2)

local function pick(name, opts)
	return function() require("telescope.builtin")[name](opts) end
end

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
					hl.CursorLine = { bg = raised }
					hl.WinSeparator = { fg = faint }
					hl.StatusLine = { fg = mute, bg = "NONE" } -- empty bar under the start screen
					hl.StatusLineNC = { fg = dim, bg = "NONE" }
					hl.FloatBorder = { fg = dim }
					hl.FloatTitle = { fg = accent }
					hl.NormalFloat = { bg = "NONE" }
					hl.Visual = { bg = selected }
					hl.Search = { bg = selected, fg = accent }
					hl.IncSearch = { bg = accent, fg = panel }
					hl.CurSearch = { bg = accent, fg = panel }
					hl.MatchParen = { fg = accent, bold = true, underline = true }
					hl.Folded = { bg = raised }
					-- ADR status word (config/adr.lua): open in the accent, decided ones quieter
					hl.AdrProposed = { fg = accent, bold = true }
					hl.AdrAccepted = { fg = c.green, bold = true }
					hl.AdrRejected = { fg = danger }
					hl.AdrDeprecated = { fg = mute, italic = true }
					hl.AdrSuperseded = { fg = mute, italic = true }
					hl.FoldColumn = { fg = dim }
					-- whitespace markers: visible only when you look for them
					hl.Whitespace = { fg = faint }
					hl.NonText = { fg = faint }
					-- LSP: other uses of the word under the cursor
					hl.LspReferenceText = { bg = "#262830" }
					hl.LspReferenceRead = { bg = "#262830" }
					hl.LspReferenceWrite = { bg = "#262830", underline = true, sp = dim }
					hl.LspInlayHint = { fg = dim, italic = true }
					-- completion menu (blink.cmp) and the native popup menu
					hl.Pmenu = { bg = panel, fg = c.fg }
					hl.PmenuSel = { bg = selected, fg = accent }
					hl.PmenuSbar = { bg = panel }
					hl.PmenuThumb = { bg = dim }
					hl.BlinkCmpMenu = { bg = panel }
					hl.BlinkCmpMenuBorder = { fg = dim, bg = panel }
					hl.BlinkCmpMenuSelection = { bg = selected, bold = true }
					hl.BlinkCmpLabelMatch = { fg = accent, bold = true }
					hl.BlinkCmpLabelDescription = { fg = mute }
					hl.BlinkCmpKind = { fg = mute }
					hl.BlinkCmpDoc = { bg = panel }
					hl.BlinkCmpDocBorder = { fg = dim, bg = panel }
					hl.BlinkCmpDocSeparator = { fg = faint, bg = panel }
					hl.BlinkCmpSignatureHelp = { bg = panel }
					hl.BlinkCmpSignatureHelpBorder = { fg = dim, bg = panel }
					hl.BlinkCmpSignatureHelpActiveParameter = { fg = accent, bold = true, underline = true }
					-- telescope
					hl.TelescopeBorder = { fg = dim }
					hl.TelescopePromptBorder = { fg = accent }
					hl.TelescopePromptPrefix = { fg = accent }
					hl.TelescopeSelectionCaret = { fg = accent }
					hl.TelescopeSelection = { bg = selected }
					hl.TelescopeMatching = { fg = accent, bold = true }
					hl.TelescopeTitle = { fg = mute }
					-- start screen
					hl.SnacksDashboardHeader = { fg = accent }
					hl.SnacksDashboardIcon = { fg = accent }
					hl.SnacksDashboardKey = { fg = accent, bold = true }
					hl.SnacksDashboardDesc = { fg = c.fg }
					hl.SnacksDashboardFile = { fg = c.fg }
					hl.SnacksDashboardDir = { fg = dim }
					hl.SnacksDashboardTitle = { fg = mute }
					hl.SnacksDashboardFooter = { fg = dim }
					hl.SnacksDashboardSpecial = { fg = mute }
					-- notifications, prompts, pickers
					hl.SnacksNotifierBorderInfo = { fg = dim }
					hl.SnacksNotifierTitleInfo = { fg = accent }
					hl.SnacksNotifierIconInfo = { fg = accent }
					hl.SnacksNotifierBorderWarn = { fg = dim }
					hl.SnacksNotifierBorderError = { fg = danger }
					hl.SnacksNotifierTitleError = { fg = danger }
					hl.SnacksNotifierIconError = { fg = danger }
					hl.SnacksInputBorder = { fg = accent }
					hl.SnacksInputTitle = { fg = accent }
					hl.SnacksInputIcon = { fg = accent }
					hl.SnacksPickerBorder = { fg = dim }
					hl.SnacksPickerTitle = { fg = accent }
					hl.SnacksPickerMatch = { fg = accent, bold = true }
					hl.SnacksPickerPrompt = { fg = accent }
					-- sticky function header (treesitter-context)
					hl.TreesitterContext = { bg = raised }
					hl.TreesitterContextLineNumber = { fg = dim, bg = raised }
					hl.TreesitterContextBottom = { underline = true, sp = faint }
					-- file browser
					hl.OilDir = { fg = accent }
					hl.OilDirIcon = { fg = accent }
					-- indent guides
					hl.IblIndent = { fg = faint, nocombine = true }
					hl.IblScope = { fg = dim, nocombine = true }
					-- diagnostics accents
					hl.DiagnosticError = { fg = danger }
					hl.DiagnosticVirtualTextError = { fg = danger, bg = "NONE" }
					hl.DiagnosticVirtualLinesError = { fg = danger }
				end,
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- Start screen, notifications, prompts, and small helpers, one plugin.
	{
		"folke/snacks.nvim",
		lazy = false,
		priority = 1000, -- snacks asks for 1000 (:checkhealth snacks)
		keys = {
			{ "<leader>e", function() Snacks.bufdelete() end, desc = "Delete buffer (keeps the window)" },
			{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
			{ "<leader>gl", function() Snacks.lazygit.log_file() end, desc = "Git history of this file" },
			{ "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification history" },
			{ "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next use of this word (LSP)" },
			{ "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Previous use of this word (LSP)" },
		},
		opts = {
			bigfile = { enabled = true }, -- huge files open fast (heavy features off)
			input = { enabled = true }, -- rename & other prompts in a small box at the cursor
			notifier = { enabled = true, style = "compact", timeout = 3000 },
			picker = { enabled = true, ui_select = true }, -- code actions & choices in a picker
			words = { enabled = true }, -- highlight other uses of the word under the cursor
			lazygit = { configure = true },
			styles = {
				input = { relative = "cursor", row = -3, col = 0, width = 44 },
				notification = { wo = { winblend = 0, wrap = true } },
			},
			dashboard = {
				width = 46,
				preset = {
					header = os_header,
					keys = {
						{ icon = "󰈞 ", key = "f", desc = "find file", action = pick("find_files") },
						{ icon = "󰊄 ", key = "g", desc = "grep", action = pick("live_grep") },
						{ icon = "󰋚 ", key = "r", desc = "recent files", action = pick("oldfiles") },
						{ icon = "󰉋 ", key = "e", desc = "file browser", action = ":Oil" },
						{ icon = " ", key = "n", desc = "new file", action = ":ene | startinsert" },
						{ icon = "󰁯 ", key = "s", desc = "restore session", section = "session" },
						{
							icon = "󰊢 ",
							key = "G",
							desc = "lazygit",
							action = function() Snacks.lazygit() end,
							enabled = vim.fn.executable("lazygit") == 1,
						},
						{ icon = " ", key = "c", desc = "config", action = pick("find_files", { cwd = vim.fn.stdpath("config") }) },
						{ icon = "󰒲 ", key = "l", desc = "plugins", action = ":Lazy" },
						{ icon = "󰗼 ", key = "q", desc = "quit", action = ":qa" },
					},
				},
				sections = {
					{ section = "header", padding = 1 },
					{ text = { { wordmark, hl = "SnacksDashboardTitle" } }, align = "center", padding = 2 },
					{ section = "keys", gap = 0, padding = 2 },
					{ title = "recent", section = "recent_files", limit = 5, indent = 2, padding = 2 },
					function()
						local stats = require("lazy.stats").stats()
						return {
							align = "center",
							text = {
								{ ("%d/%d plugins"):format(stats.loaded, stats.count), hl = "footer" },
								{ "  ·  ", hl = "footer" },
								{ ("%d ms"):format(math.floor(stats.startuptime + 0.5)), hl = "footer" },
							},
						}
					end,
				},
			},
		},
	},

	-- file icons; ADRs get a gavel in tokyonight's green, same glyph and colour as eza in the zsh repo
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		opts = { override_by_extension = { adr = { icon = "󰊛", color = "#c3e88d", name = "Adr" } } },
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
			local logo = os_logo()
			-- `showmode` is off, so this is the only sign that a macro is being recorded
			local function recording()
				local reg = vim.fn.reg_recording()
				return reg ~= "" and ("recording @" .. reg) or ""
			end
			local function lsp_names()
				local names = {}
				for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
					names[#names + 1] = client.name
				end
				return table.concat(names, " ")
			end
			require("lualine").setup({
				options = {
					theme = theme,
					globalstatus = true,
					component_separators = "",
					section_separators = "",
					disabled_filetypes = { statusline = { "snacks_dashboard" } },
				},
				sections = {
					lualine_a = {
						{ function() return logo end, color = { fg = accent }, padding = { left = 1, right = 0 } },
						{ "mode", fmt = string.lower },
					},
					lualine_b = {
						{ "branch", icon = "" },
						{ "diff", symbols = { added = "+", modified = "~", removed = "-" } },
					},
					lualine_c = {
						{
							"filename",
							path = 1,
							symbols = { modified = " ●", readonly = " ", unnamed = "[no name]", newfile = "[new]" },
						},
					},
					lualine_x = {
						{ recording, color = { fg = danger, gui = "bold" } },
						{ "searchcount", color = { fg = accent } },
						{ "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " } },
						{ lsp_names, icon = "󰒋", color = { fg = dim } },
						{ function() return vim.b.molten_kernel or "" end, icon = "󰠮", color = { fg = accent } },
						{ "filetype", colored = false },
					},
					lualine_y = { "progress" },
					lualine_z = { { "location", color = { fg = mute } } },
				},
			})
			-- show / hide the recording marker right away
			vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
				group = vim.api.nvim_create_augroup("archminimal-lualine", { clear = true }),
				callback = function() vim.schedule(function() require("lualine").refresh() end) end,
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
			indent = { char = "│", tab_char = "│" }, -- tabs (Go, Makefiles) get the same thin guide
			whitespace = { remove_blankline_trail = false },
			scope = { enabled = true, show_start = false, show_end = false },
			exclude = { filetypes = { "snacks_dashboard", "oil" } },
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
				excluded_filetypes = { "snacks_dashboard", "snacks_notif", "snacks_input", "blink-cmp-menu", "oil", "grug-far" },
			})
			pcall(function() require("scrollbar.handlers.gitsigns").setup() end)
		end,
	},

	-- git changes in the sign column + hunk actions
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
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
				{ "<leader>g", group = "git" },
				{ "<leader>h", group = "git hunk" },
				{ "<leader>c", group = "code" },
				{ "<leader>r", group = "rename / replace" },
				{ "<leader>s", group = "send to repl" },
				{ "<leader>j", group = "jupyter" },
				{ "<leader>x", group = "diagnostics" },
				{ "<leader>d", group = "debug / db" },
				{ "<leader>b", group = "buffers / breakpoints" },
				{ "<leader>q", group = "session" },
				{ "<leader>A", group = "adr" },
			},
		},
	},

	-- small LSP progress spinner in the corner
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

	-- Colors written as #rrggbb get a swatch next to them (handy for theme files),
	-- in every file type. Neovim 0.12 also colors them through the language
	-- server (Lua, CSS only); that one is turned off so colors aren't drawn twice.
	{
		"nvim-mini/mini.hipatterns",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			if vim.lsp.document_color then vim.lsp.document_color.enable(false) end
			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = { hex_color = hipatterns.gen_highlighter.hex_color({ style = "inline", inline_text = "■ " }) },
			})
		end,
	},
}
