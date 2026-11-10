-- Language servers (installed by mason), keymaps, formatting.
local servers = { "pyright", "ts_ls", "lua_ls", "bashls", "gopls" }

return {
	{
		"mason-org/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUpdate" },
		build = ":MasonUpdate",
		opts = { ui = { border = "rounded", icons = { package_installed = "●", package_pending = "◐", package_uninstalled = "○" } } },
	},

	{
		"mason-org/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig", "saghen/blink.cmp" },
		config = function()
			-- defaults for every server: tell them what the completion menu supports
			vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
			vim.lsp.config("lua_ls", {
				settings = { Lua = { workspace = { checkThirdParty = false } } }, -- `vim` itself comes from lazydev
			})

			-- installs missing servers and enables every installed one
			-- (mason itself is set up once, by its own spec above)
			require("mason-lspconfig").setup({ ensure_installed = servers, automatic_enable = true })
		end,
	},

	-- Keymaps for ANY attached server (before: only 4 named servers got them, gopls didn't).
	{
		"neovim/nvim-lspconfig",
		lazy = true,
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("archminimal-lsp", { clear = true }),
				callback = function(ev)
					local function map(l, r, desc) vim.keymap.set("n", l, r, { buffer = ev.buf, desc = desc }) end
					map("gd", vim.lsp.buf.definition, "Go to definition")
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("K", vim.lsp.buf.hover, "Hover")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("<leader>ch", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
					end, "Toggle inlay hints")
				end,
			})
		end,
	},

	{
		"rmagatti/goto-preview",
		event = "LspAttach",
		opts = { width = 120, height = 25, default_mappings = true, border = "rounded" }, -- gpd gpi gpr gP
	},

	-- Formatting: conform.nvim replaces formatter.nvim (same tools, faster, async).
	-- <leader>cf formats; :Format still works. Moved off <leader>f, which collided
	-- with <leader>fb/fh/fg and made every <leader>f wait a full timeout.
	{
		"stevearc/conform.nvim",
		cmd = { "ConformInfo", "Format" },
		keys = {
			{ "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, mode = { "n", "v" }, desc = "Format" },
		},
		opts = {
			formatters_by_ft = {
				sql = { "pg_format" },
				python = { "black" },
				lua = { "stylua" },
				json = { "jq" },
				go = { "goimports", "gofmt" },
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
			vim.api.nvim_create_user_command("Format", function(args)
				local range = args.count ~= -1 and { start = { args.line1, 0 }, ["end"] = { args.line2, 0 } } or nil
				require("conform").format({ async = true, lsp_format = "fallback", range = range })
			end, { range = true, desc = "Format buffer or range" })
		end,
	},
}
