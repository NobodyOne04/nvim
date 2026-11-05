-- Completion, snippets, Copilot.
return {
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",          -- NEW: completion on : and /
			"saadparwaiz1/cmp_luasnip",     -- NEW: snippets show up in the menu
			{ "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" } },
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
				window = {
					completion = cmp.config.window.bordered({ winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel" }),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					-- jump inside snippets (Tab stays free for Copilot)
					["<C-l>"] = cmp.mapping(function(fallback)
						if luasnip.locally_jumpable(1) then luasnip.jump(1) else fallback() end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function(fallback)
						if luasnip.locally_jumpable(-1) then luasnip.jump(-1) else fallback() end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
				-- your lspkind icons, now actually shown in the menu
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "…",
						symbol_map = {
							Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
							Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
							Module = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
							Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
							File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
							Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
							TypeParameter = "",
						},
					}),
				},
			})

			-- SQL buffers: database-aware completion (vim-dadbod-completion)
			cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
				sources = { { name = "vim-dadbod-completion" }, { name = "buffer" } },
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "buffer" } },
			})
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})
		end,
	},

	-- Copilot (was an untracked copy in pack/; now managed and reproducible).
	-- <Tab> accepts a suggestion. Auth: :Copilot setup (token stays in ~/.config/github-copilot).
	{ "github/copilot.vim", cmd = "Copilot", event = "InsertEnter" },
}
