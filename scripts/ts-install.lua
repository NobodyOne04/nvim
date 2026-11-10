-- Compile every treesitter parser the config lists, and wait for it.
--
-- On startup the parsers build in the background, so a headless `+qa` (or
-- quitting right after a fresh install) exits before any of them finish and
-- files open without syntax highlighting or folds. `make sync` runs this.
local function say(s) io.stdout:write(s .. "\n") end

if vim.fn.has("nvim-0.12") == 0 then
	say("  skip    treesitter parsers (needs Neovim 0.12+)")
	return vim.cmd("qa!")
end
if vim.fn.executable("tree-sitter") == 0 then
	io.stderr:write("treesitter: the tree-sitter CLI is missing (run `make tools`)\n")
	return vim.cmd("cquit 1")
end

local plugin = require("lazy.core.config").plugins["nvim-treesitter"]
local parsers = require("lazy.core.plugin").values(plugin, "opts", false).parsers
require("lazy").load({ plugins = { "nvim-treesitter" } })

local ok = require("nvim-treesitter").install(parsers, { summary = true }):wait(30 * 60 * 1000)
local missing = {}
local installed = require("nvim-treesitter").get_installed()
for _, p in ipairs(parsers) do
	if not vim.tbl_contains(installed, p) then table.insert(missing, p) end
end
if not ok or #missing > 0 then
	io.stderr:write("treesitter: failed: " .. table.concat(missing, ", ") .. "\n")
	vim.cmd("cquit 1")
else
	say("  ok      " .. #parsers .. " treesitter parsers")
	vim.cmd("qa!")
end
