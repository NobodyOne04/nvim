-- Syntax trees (nvim-treesitter `main` branch, which needs Neovim 0.12+).
--
-- The old config pinned nothing and used the pre-rewrite API
-- (require("nvim-treesitter.configs")), so any fresh install crashed once the
-- plugin's default branch moved to the rewrite. One branch for every machine
-- keeps lazy-lock.json valid everywhere.
local parsers = {
	"bash", "css", "dockerfile", "go", "html", "javascript", "json", "lua", "luadoc",
	"make", "markdown", "markdown_inline", "python", "query", "regex", "sql", "toml",
	"tsx", "typescript", "vim", "vimdoc", "yaml",
}
local supported = vim.fn.has("nvim-0.12") == 1

if not supported then
	vim.schedule(function()
		vim.notify("treesitter needs Neovim 0.12+ (Arch: pacman -Syu, macOS: brew upgrade neovim); using basic highlighting",
			vim.log.levels.WARN)
	end)
end

return {
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
				if pcall(vim.treesitter.start, ev.buf) then
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
