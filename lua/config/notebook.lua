-- Jupyter cells on top of molten-nvim (plugin specs: lua/plugins/notebook.lua).
--
-- A cell is everything between two `# %%` lines (`// %%` in Go, etc., taken
-- from 'commentstring'); that is how jupytext writes a notebook as a script.
-- `# %% [markdown]` cells are skipped when running. A file without markers is
-- one big cell, so the same keys work in any plain .py file.
--
-- The kernel is picked for you: the one the notebook was saved with, else the
-- one registered for the project's .venv (`make kernel VENV=...`), else you
-- choose from a list.
local M = {}

-- ── cells ───────────────────────────────────────────────────────────────

local function leader(buf)
	local cs = vim.bo[buf or 0].commentstring
	local l = vim.trim((cs:gsub("%%s.*$", "")))
	return l ~= "" and l or "#"
end

local function is_marker(line, l) return line:match("^%s*" .. vim.pesc(l) .. "%s*%%%%") ~= nil end

local function cell_kind(line)
	if line:match("%[markdown%]") or line:match("%[md%]") then return "markdown" end
	if line:match("%[raw%]") then return "raw" end
	return "code"
end

--- All cells of the buffer, top to bottom.
--- Each: { header = marker lnum (0 = none), first, last (code lines, trailing
--- blanks trimmed; last < first when empty), stop = line before next marker, kind }
function M.cells(buf)
	buf = buf or 0
	local l = leader(buf)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local cells, cur = {}, { header = 0, first = 1, kind = "code" }
	local function close(stop)
		cur.stop = stop
		local last = stop
		while last >= cur.first and lines[last]:match("^%s*$") do last = last - 1 end
		cur.last = last
		table.insert(cells, cur)
	end
	for i, line in ipairs(lines) do
		if is_marker(line, l) then
			close(i - 1)
			cur = { header = i, first = i + 1, kind = cell_kind(line) }
		end
	end
	close(#lines)
	-- Text before the first marker counts only if it holds code (jupytext puts
	-- a commented metadata header there).
	local pre = cells[1]
	if pre.header == 0 and #cells > 1 and not M.has_code(pre, buf) then table.remove(cells, 1) end
	return cells
end

function M.has_code(cell, buf)
	if cell.kind ~= "code" or cell.last < cell.first then return false end
	local l = leader(buf)
	for _, line in ipairs(vim.api.nvim_buf_get_lines(buf or 0, cell.first - 1, cell.last, false)) do
		if not line:match("^%s*$") and not line:match("^%s*" .. vim.pesc(l)) then return true end
	end
	return false
end

--- The cell under the cursor (or at `lnum`) and its index.
function M.current(lnum)
	lnum = lnum or vim.fn.line(".")
	local cells = M.cells()
	for i = #cells, 1, -1 do
		if cells[i].header <= lnum then return cells[i], i, cells end
	end
	return cells[1], 1, cells
end

-- ── kernel ──────────────────────────────────────────────────────────────

local function load_molten()
	if not vim.g.python3_host_prog then
		vim.notify("Notebook support isn't installed: run `make notebook` in the nvim config", vim.log.levels.ERROR)
		return false
	end
	require("lazy").load({ plugins = { "molten-nvim" } })
	return true
end

local function kernel_dirs()
	local dirs = { vim.fn.expand("~/Library/Jupyter/kernels"), vim.fn.expand("~/.local/share/jupyter/kernels"),
		"/usr/local/share/jupyter/kernels", "/usr/share/jupyter/kernels" }
	for p in (vim.env.JUPYTER_PATH or ""):gmatch("[^:]+") do table.insert(dirs, 1, p .. "/kernels") end
	return dirs
end

-- Kernel registered for this file's project venv (nearest .venv / venv up the
-- tree, or the active $VIRTUAL_ENV).
local function venv_kernel(buf, available)
	local file = vim.api.nvim_buf_get_name(buf)
	local found = vim.fs.find({ ".venv", "venv" }, { upward = true, path = vim.fs.dirname(file), type = "directory" })[1]
	local venv = found or vim.env.VIRTUAL_ENV
	if not venv then return nil end
	venv = vim.fs.normalize(venv) .. "/"
	for _, dir in ipairs(kernel_dirs()) do
		for _, name in ipairs(available) do
			local ok, spec = pcall(function()
				return vim.json.decode(table.concat(vim.fn.readfile(dir .. "/" .. name .. "/kernel.json"), "\n"))
			end)
			if ok and spec.argv and vim.startswith(vim.fs.normalize(spec.argv[1]), venv) then return name end
		end
	end
end

-- Kernel name stored in the .ipynb (its metadata.kernelspec.name).
local function notebook_kernel(buf)
	local file = vim.api.nvim_buf_get_name(buf)
	if not file:match("%.ipynb$") then return nil end
	local ok, nb = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(file), "\n")) end)
	return ok and vim.tbl_get(nb, "metadata", "kernelspec", "name") or nil
end

function M.guess_kernel(buf)
	local available = vim.fn.MoltenAvailableKernels()
	local name = notebook_kernel(buf)
	if not vim.tbl_contains(available, name) then name = nil end
	-- "python3" is just the generic default kernel: the project's venv wins.
	if name and name ~= "python3" then return name end
	return venv_kernel(buf, available) or name
end

local function start(buf, name)
	vim.cmd("MoltenInit " .. vim.fn.fnameescape(name))
	vim.b[buf].molten_kernel = name
end

--- Call `cb` once the buffer has a kernel, starting one if needed.
function M.ensure_kernel(cb, opts)
	opts = opts or {}
	if not load_molten() then return end
	local buf = vim.api.nvim_get_current_buf()
	if #vim.fn.MoltenRunningKernels(true) > 0 then return cb and cb() end
	local name = M.guess_kernel(buf)
	if name then
		start(buf, name)
		return cb and cb()
	end
	if opts.quiet then return end
	vim.ui.select(vim.fn.MoltenAvailableKernels(), { prompt = "Jupyter kernel" }, function(choice)
		if not choice then return end
		start(buf, choice)
		if cb then cb() end
	end)
end

function M.init()
	if load_molten() and #vim.fn.MoltenRunningKernels(true) > 0 then
		-- Already running: let molten ask, to attach a second kernel.
		return vim.cmd("MoltenInit")
	end
	M.ensure_kernel(function() vim.notify("Kernel: " .. (vim.b.molten_kernel or "?")) end)
end

-- ── running ─────────────────────────────────────────────────────────────

local function eval(cell) vim.fn.MoltenEvaluateRange(cell.first, cell.last) end

local function run_cells(list)
	local todo = vim.tbl_filter(function(c) return M.has_code(c) end, list)
	if #todo == 0 then return vim.notify("No code to run", vim.log.levels.WARN) end
	M.ensure_kernel(function()
		for _, c in ipairs(todo) do eval(c) end
	end)
end

--- Go to the code of cell `i` (appends a new empty cell past the last one).
local function goto_cell(cells, i)
	local c = cells[i]
	if not c then
		local last = vim.api.nvim_buf_line_count(0)
		vim.api.nvim_buf_set_lines(0, last, last, false, { "", leader() .. " %%", "" })
		return vim.api.nvim_win_set_cursor(0, { last + 3, 0 })
	end
	vim.api.nvim_win_set_cursor(0, { math.min(c.first, vim.api.nvim_buf_line_count(0)), 0 })
end

function M.run_cell(advance)
	local cell, i, cells = M.current()
	if M.has_code(cell) then run_cells({ cell }) end
	if advance then goto_cell(cells, i + 1) end
end

function M.run_all() run_cells(M.cells()) end

function M.run_above()
	local _, i, cells = M.current()
	run_cells(vim.list_slice(cells, 1, i))
end

function M.run_below()
	local _, i, cells = M.current()
	run_cells(vim.list_slice(cells, i))
end

function M.run_line()
	M.ensure_kernel(function() vim.cmd("MoltenEvaluateLine") end)
end

function M.run_visual()
	vim.cmd("normal! \27") -- leave visual mode so '< and '> are set
	M.ensure_kernel(function() vim.cmd("MoltenEvaluateVisual") end)
end

-- ── editing ─────────────────────────────────────────────────────────────

function M.new_cell(kind)
	local cell = M.current()
	local l = leader()
	local at = math.max(cell.last, cell.header) -- after this cell's code
	local lines = kind == "markdown" and { "", l .. " %% [markdown]", l .. " " } or { "", l .. " %%", "" }
	vim.api.nvim_buf_set_lines(0, at, at, false, lines)
	vim.api.nvim_win_set_cursor(0, { at + 3, 0 })
	vim.cmd("startinsert!")
end

--- ]j / [j: next / previous cell.
function M.jump(dir)
	local _, i, cells = M.current()
	local target = cells[i + dir * vim.v.count1]
	if target then
		vim.cmd("normal! m'")
		vim.api.nvim_win_set_cursor(0, { math.min(target.first, vim.api.nvim_buf_line_count(0)), 0 })
	end
end

--- mini.ai textobject: `ij` = the cell's code, `aj` = marker line + code + trailing blanks.
function M.textobject(ai_type)
	local cell = M.current()
	local from = ai_type == "a" and math.max(cell.header, 1) or cell.first
	local to = ai_type == "a" and cell.stop or cell.last
	if to < from then return nil end
	local to_col = math.max(#vim.fn.getline(to), 1)
	return { from = { line = from, col = 1 }, to = { line = to, col = to_col }, vis_mode = "V" }
end

-- ── notebooks ───────────────────────────────────────────────────────────

function M.autocmds()
	local group = vim.api.nvim_create_augroup("archminimal-notebook", { clear = true })

	-- jupytext sets the filetype after reading a notebook; that's the moment to
	-- start its kernel and show the outputs saved in the .ipynb. No matching
	-- kernel: stay quiet, <leader>ji asks.
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "*",
		callback = function(ev)
			if vim.b[ev.buf].notebook_ready or not vim.api.nvim_buf_get_name(ev.buf):match("%.ipynb$") then return end
			vim.b[ev.buf].notebook_ready = true
			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(ev.buf) or vim.api.nvim_get_current_buf() ~= ev.buf then return end
				M.ensure_kernel(function() pcall(vim.cmd, "MoltenImportOutput") end, { quiet = true })
			end)
		end,
	})

	-- After jupytext writes the .ipynb, add the outputs of the cells run here.
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = "*.ipynb",
		callback = function()
			if vim.b.molten_kernel and #vim.fn.MoltenRunningKernels(true) > 0 then
				pcall(vim.cmd, "silent MoltenExportOutput!")
			end
		end,
	})
end

return M
