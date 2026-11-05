-- Headless, reliable mason installs for `make lsp`.
--
-- :MasonInstall in headless mode treats any stderr output of an installer
-- (e.g. Go printing "downloading gopls") as an error and aborts the rest.
-- This drives mason's API directly, waits for every package, and exits
-- non-zero if any of them failed.
--
--   MASON_PKGS="gopls pyright" nvim --headless -c "luafile scripts/mason-install.lua"

local names = vim.split(vim.env.MASON_PKGS or "", "%s+", { trimempty = true })
local function say(s) io.stdout:write(s .. "\n") end

require("lazy").load({ plugins = { "mason.nvim" } })
local registry = require("mason-registry")

local done, pending, failed = false, 0, {}
local function maybe_done() if pending == 0 then done = true end end

registry.refresh(function()
	for _, name in ipairs(names) do
		local ok, pkg = pcall(registry.get_package, name)
		if not ok then
			table.insert(failed, name .. " (no such package)")
		elseif pkg:is_installed() then
			say("  ok      " .. name)
		else
			pending = pending + 1
			say("  install " .. name .. " …")
			pkg:install({}, vim.schedule_wrap(function(success, err)
				say((success and "  done    " or "  FAILED  ") .. name .. (success and "" or (": " .. tostring(err))))
				if not success then table.insert(failed, name) end
				pending = pending - 1
				maybe_done()
			end))
		end
	end
	maybe_done()
end)

vim.wait(30 * 60 * 1000, function() return done end, 200)
if not done then table.insert(failed, "timed out") end

if #failed > 0 then
	io.stderr:write("mason: failed: " .. table.concat(failed, ", ") .. "\n")
	vim.cmd("cquit 1")
else
	vim.cmd("qa!")
end
