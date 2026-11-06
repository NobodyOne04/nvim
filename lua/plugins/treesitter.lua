-- Syntax trees (nvim-treesitter `main` branch, which needs Neovim 0.12+).
--
-- The old config pinned nothing and used the pre-rewrite API
-- (require("nvim-treesitter.configs")), so any fresh install crashed once the
-- plugin's default branch moved to the rewrite. One branch for every machine
-- keeps lazy-lock.json valid everywhere.
local parsers = {
	"bash", "css", "csv", "diff", "dockerfile", "git_config", "git_rebase", "gitcommit", "gitignore",
	"go", "gomod", "gosum", "gowork", "hcl", "html", "ini", "javascript", "json", "lua", "luadoc",
	"make", "markdown", "markdown_inline", "python", "qmljs", "query", "regex", "requirements", "sql",
	"ssh_config", "terraform", "toml", "tsx", "typescript", "vim", "vimdoc", "xml", "yaml",
}
local supported = vim.fn.has("nvim-0.12") == 1

if not supported then
	vim.schedule(function()
		vim.notify("treesitter needs Neovim 0.12+ (Arch: pacman -Syu, macOS: brew upgrade neovim); using basic highlighting",
			vim.log.levels.WARN)
	end)
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		cond = supported,
		lazy = false,
		build = ":TSUpdate",
		config = function()
			-- needs the tree-sitter CLI and a C compiler (scripts/install-tools.sh installs both)
			require("nvim-treesitter").install(parsers)
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("archminimal-ts", { clear = true }),
				callback = function(ev)
					if not pcall(vim.treesitter.start, ev.buf) then return end
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					-- folds by syntax: za toggles one, zc / zo close / open, zM / zR all
					for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
						vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
						vim.wo[win][0].foldmethod = "expr"
					end
					-- Neovim 0.12 throws away fold work done while a file is still
					-- opening (it resets at VimEnter and FileType), so a fresh file had
					-- no folds until its first edit. Recompute once opening is done.
					vim.schedule(function()
						for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
							vim.api.nvim_win_call(win, function() vim.cmd("normal! zx") end)
						end
					end)
				end,
			})
		end,
	},

	-- Keeps the enclosing function / class line pinned at the top while you
	-- scroll through its body.
	{
		"nvim-treesitter/nvim-treesitter-context",
		cond = supported,
		event = { "BufReadPost", "BufNewFile" },
		keys = {
			{ "<leader>ct", function() require("treesitter-context").toggle() end, desc = "Toggle sticky header" },
		},
		opts = { max_lines = 3, multiline_threshold = 1, trim_scope = "inner" },
	},
}
