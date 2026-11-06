-- Fetches blink.cmp's prebuilt fuzzy matcher during `make sync`, so the first
-- completion after an install doesn't wait for the download. If it can't be
-- fetched, completion still works (with the slower Lua matcher); this only warns.
--
--   nvim --headless -c "luafile scripts/blink-fuzzy.lua"

local ok, err = pcall(function()
	require("lazy").load({ plugins = { "blink.cmp" } })
	-- blink's setup downloads the library, then switches its matcher to "rust".
	-- (Don't poll package.loaded: a failed require leaves a marker there.)
	local fuzzy = require("blink.cmp.fuzzy")
	return vim.wait(90 * 1000, function() return fuzzy.implementation_type == "rust" end, 200)
end)

if ok and err then
	io.stdout:write("  ok      blink.cmp fuzzy matcher\n")
	vim.cmd("qa!")
else
	io.stderr:write("blink.cmp: prebuilt fuzzy matcher not available"
		.. (ok and "" or (": " .. tostring(err)))
		.. "; completion uses the slower Lua matcher (see :checkhealth blink.cmp)\n")
	-- the config itself failed to load: make `make sync` fail loudly
	vim.cmd(ok and "qa!" or "cquit 1")
end
