-- Databases, REPL, remote editing, debugging. All load only when used.
return {
	{
		"tpope/vim-dadbod",
		cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection" },
		dependencies = {
			"kristijanhusak/vim-dadbod-ui",
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
		},
		keys = { { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Database UI" } },
		init = function()
			vim.g.db_ui_auto_execute_table_helpers = 1
		end,
	},

	{
		"Vigemus/iron.nvim",
		cmd = { "IronRepl", "IronRestart", "IronFocus", "IronHide" },
		keys = {
			{ "<leader>sc", mode = { "n", "x" }, desc = "Send to REPL" },
			{ "<leader>sf", desc = "Send file" },
			{ "<leader>sl", desc = "Send line" },
			{ "<leader>s<cr>", desc = "Send <CR>" },
			{ "<leader>s<space>", desc = "Interrupt" },
			{ "<leader>sq", desc = "Quit REPL" },
			{ "<leader>cl", desc = "Clear REPL" },
		},
		config = function()
			require("iron.core").setup({
				config = {
					repl_definition = { python = { command = { "ipython", "--no-autoindent" } } },
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
				highlight = { italic = true },
				ignore_blank_lines = true,
			})
		end,
	},

	{
		"chipsenkbeil/distant.nvim",
		cmd = { "DistantLaunch", "DistantConnect", "DistantOpen", "DistantInstall", "DistantShell" },
		config = function() require("distant"):setup() end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		keys = {
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Debug UI" },
			{ "<leader>bp", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
			{ "<F5>", function() require("dap").continue() end, desc = "Debug: continue" },
			{ "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
			{ "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
			{ "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup()
			dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
			dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
		end,
	},
}
