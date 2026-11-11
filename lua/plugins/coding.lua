-- Completion, snippets, Copilot.
--
-- blink.cmp replaces nvim-cmp and its seven helpers (cmp-nvim-lsp, -buffer,
-- -path, -cmdline, cmp_luasnip, LuaSnip, lspkind): one plugin with a native
-- fuzzy matcher that forgives typos, docs beside the menu, and the function
-- signature while you type. Same keys as before; <Tab> stays free for Copilot.
return {
	{
		"saghen/blink.cmp",
		-- release tags ship a prebuilt fuzzy matcher (no Rust toolchain needed);
		-- `make sync` downloads it
		version = "1.*",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				preset = "none",
				["<C-n>"] = { "show", "select_next", "fallback" },
				["<C-p>"] = { "show", "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				-- jump inside snippets (Tab stays free for Copilot)
				["<C-l>"] = { "snippet_forward", "fallback" },
				["<C-h>"] = { "snippet_backward", "fallback" },
				["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				list = { selection = { preselect = true, auto_insert = false } },
				menu = {
					border = "rounded",
					scrollbar = false,
					draw = {
						treesitter = { "lsp" },
						columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
						-- on the : line, just the names (no "Property" labels next to commands)
						components = {
							kind_icon = {
								text = function(ctx) return vim.fn.mode() == "c" and "" or ctx.kind_icon .. ctx.icon_gap end,
							},
							kind = { text = function(ctx) return vim.fn.mode() == "c" and "" or ctx.kind end },
						},
					},
				},
				documentation = { auto_show = true, auto_show_delay_ms = 250, window = { border = "rounded" } },
				ghost_text = { enabled = false }, -- Copilot already draws ghost text
			},
			signature = { enabled = true, window = { border = "rounded", show_documentation = false } },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					-- Neovim API completion while editing this config
					lua = { inherit_defaults = true, "lazydev" },
					-- database-aware completion (vim-dadbod-completion)
					sql = { "dadbod", "snippets", "buffer" },
					mysql = { "dadbod", "snippets", "buffer" },
					plsql = { "dadbod", "snippets", "buffer" },
				},
				providers = {
					lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
					dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
				},
			},
			-- completion on : (commands, paths) and / (words in the buffer), as before
			cmdline = {
				keymap = { preset = "cmdline" },
				completion = { menu = { auto_show = true }, list = { selection = { preselect = false } } },
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
	},

	-- Types and completion for the Neovim API while editing this config
	-- (replaces the old `globals = { "vim" }` workaround).
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } },
	},

	-- Copilot. <Tab> accepts a suggestion. Auth: :Copilot setup (token stays in ~/.config/github-copilot).
	-- In insert: <M-]>/<M-[> cycle suggestions (plugin defaults); <M-\> is tmux's split, so unused.
	{
		"github/copilot.vim",
		cmd = "Copilot",
		event = "InsertEnter",
		keys = {
			{
				"<leader>ai",
				function()
					local on = vim.g.copilot_enabled ~= 0 -- what :Copilot enable/disable sets; unset = on
					vim.cmd("Copilot " .. (on and "disable" or "enable"))
					vim.notify("Copilot inline hints " .. (on and "off" or "on"))
				end,
				desc = "Toggle Copilot inline hints",
			},
		},
	},

	-- Claude Code over the IDE protocol: sees the open file/selection, edits arrive as diffs (ADR 0013).
	-- A claude already running in a tmux pane can attach with /ide.
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		cmd = { "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend", "ClaudeCodeAdd", "ClaudeCodeStatus" },
		opts = { focus_after_send = true }, -- after sending code, type the request straight away
		keys = {
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude session" },
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to Claude" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
			{ "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", ft = "oil", desc = "Add file to Claude" },
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject Claude diff" },
		},
	},
}
