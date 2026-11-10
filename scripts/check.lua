-- `make check`, second half: most plugins load lazily, so a plain start never runs their
-- setup. Load every plugin, then open one file per language so FileType, LSP and
-- treesitter hooks run too. lazy.nvim and plugins report problems through vim.notify,
-- which prints nothing headless, so collect it: errors fail the check, warnings are shown.
local errors, warnings = {}, {}
vim.notify = function(msg, level)
	level = level or vim.log.levels.INFO
	if level >= vim.log.levels.ERROR then
		errors[#errors + 1] = msg
	elseif level == vim.log.levels.WARN then
		warnings[#warnings + 1] = msg
	end
end

local function try(fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok then errors[#errors + 1] = tostring(err) end
end

try(vim.cmd, "Lazy! load all")

local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
for _, ext in ipairs({ "py", "go", "lua", "ts", "sh", "sql", "md", "json", "yaml", "toml" }) do
	try(vim.cmd.edit, dir .. "/check." .. ext)
end
vim.wait(1500) -- let scheduled callbacks (folds, LSP attach) run and report
vim.fn.delete(dir, "rf")

for _, w in ipairs(warnings) do io.stderr:write("warning: ", w, "\n") end
for _, e in ipairs(errors) do io.stderr:write("Error: ", e, "\n") end
vim.cmd(#errors > 0 and "cquit 1" or "qa!")
