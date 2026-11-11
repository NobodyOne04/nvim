-- Architecture Decision Records: docs/adr/NNNN-title.adr, markdown with a "- Status:" line.
-- Only a Proposed ADR can change status here; decided ones are history and stay as they are.
local M = {}

local ns = vim.api.nvim_create_namespace("adr")
local STATUS_HL = {
	Proposed = "AdrProposed",
	Accepted = "AdrAccepted",
	Rejected = "AdrRejected",
	Deprecated = "AdrDeprecated",
	Superseded = "AdrSuperseded",
}

local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = "ADR" }) end

-- first line matching pattern: row (1-based), text
local function find_line(buf, pattern)
	for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 40, false)) do
		if line:match(pattern) then return i, line end
	end
end

local function title_of(lines)
	for _, l in ipairs(lines) do
		local t = l:match("^#%s+(.+)")
		if t then return t end
	end
	return ""
end

-- every .adr file in the repo, sorted by name (= by number)
-- shortcut: needs git; outside a repo it only sees the current file's folder
function M.list()
	local root = vim.fs.root(0, ".git")
	local files
	if root then
		files = vim.fn.systemlist({ "git", "-C", root, "ls-files", "-co", "--exclude-standard", "--", "*.adr" })
		files = vim.tbl_map(function(f) return root .. "/" .. f end, vim.v.shell_error == 0 and files or {})
	else
		files = vim.fn.glob(vim.fn.expand("%:p:h") .. "/*.adr", false, true)
	end
	table.sort(files, function(a, b) return vim.fs.basename(a) < vim.fs.basename(b) end)
	return files
end

function M.pick()
	local items = {}
	for _, file in ipairs(M.list()) do
		local lines = vim.fn.readfile(file, "", 40)
		local status = "?"
		for _, l in ipairs(lines) do
			status = l:match("^%- Status:%s*(%a+)") or status
		end
		items[#items + 1] = { file = file, text = ("%-10s %s"):format(status, title_of(lines)) }
	end
	if #items == 0 then return notify("no .adr files in this repo", vim.log.levels.WARN) end
	Snacks.picker({ title = "ADRs", items = items, format = "text", preview = "file" })
end

-- ]A / [A: next or previous ADR by number
function M.jump(step)
	local files, cur = M.list(), vim.api.nvim_buf_get_name(0)
	for i, f in ipairs(files) do
		if f == cur then
			local target = files[i + step]
			if target then return vim.cmd.edit(vim.fn.fnameescape(target)) end
			return notify(step > 0 and "last ADR" or "first ADR")
		end
	end
end

-- colour the status word
function M.decorate(buf)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	local row, line = find_line(buf, "^%- Status:")
	if not row then return end
	local s, word = line:match("^%- Status:%s*()(%a+)")
	if STATUS_HL[word] then
		vim.api.nvim_buf_set_extmark(buf, ns, row - 1, s - 1, { end_col = s - 1 + #word, hl_group = STATUS_HL[word] })
	end
end

local function link(from_file, to_file)
	local rel = vim.fs.relpath(vim.fs.dirname(from_file), to_file) or to_file
	return ("[%s](%s)"):format(vim.fs.basename(to_file):match("^%d+") or vim.fs.basename(to_file), rel)
end

-- "- Supersedes: …" in the replacing ADR, right after its Date line; that ADR's status is untouched
local function add_supersedes(new_file, old_file)
	local lines = vim.fn.readfile(new_file)
	local entry = link(new_file, old_file)
	for i, l in ipairs(lines) do
		if l:match("^%- Supersedes:") then
			if not l:find(entry, 1, true) then lines[i] = l .. ", " .. entry end
			return vim.fn.writefile(lines, new_file)
		end
	end
	local at = 0
	for i, l in ipairs(lines) do
		if l:match("^%- Date:") or l:match("^%- Status:") then at = i end
	end
	table.insert(lines, at + 1, "- Supersedes: " .. entry)
	vim.fn.writefile(lines, new_file)
	local nbuf = vim.fn.bufnr(new_file)
	if nbuf ~= -1 then vim.api.nvim_buf_call(nbuf, function() vim.cmd("checktime") end) end
end

function M.set_status(status)
	local buf = 0
	local row, line = find_line(buf, "^%- Status:")
	if not row then return notify("no '- Status:' line in this file", vim.log.levels.ERROR) end
	local current = line:match("^%- Status:%s*(%a+)")
	if current ~= "Proposed" then
		return notify(("status is %s; only Proposed ADRs can be changed"):format(current or "?"), vim.log.levels.WARN)
	end

	local function apply(text)
		vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { "- Status: " .. text })
		-- the date records when it was decided
		local drow = find_line(buf, "^%- Date:")
		if drow then vim.api.nvim_buf_set_lines(buf, drow - 1, drow, false, { "- Date: " .. os.date("%Y-%m-%d") }) end
		vim.cmd("silent write")
		M.decorate(vim.api.nvim_get_current_buf())
		notify("status: " .. status)
	end

	if status ~= "Superseded" then return apply(status) end

	local this = vim.api.nvim_buf_get_name(buf)
	local others = vim.tbl_filter(function(f) return f ~= this end, M.list())
	vim.ui.select(others, {
		prompt = "Superseded by",
		format_item = function(f) return vim.fs.basename(f) end,
	}, function(choice)
		if not choice then return end
		apply("Superseded by " .. link(this, choice))
		add_supersedes(choice, this)
	end)
end

-- gd: open the target of the [text](path) link under the cursor, path relative to this file
-- gpd: same, in a float sized like goto-preview's (lsp.lua)
function M.follow(float)
	local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2] + 1
	for s, path, e in line:gmatch("()%[[^%]]*%]%(([^)%s#]+)[^)]*%)()") do
		if col >= s and col < e then
			local file = vim.fs.normalize(vim.fs.joinpath(vim.fn.expand("%:p:h"), path))
			if not vim.uv.fs_stat(file) then return notify("no such file: " .. path, vim.log.levels.WARN) end
			if not float then return vim.cmd.edit(vim.fn.fnameescape(file)) end
			local fbuf = vim.fn.bufadd(file)
			vim.fn.bufload(fbuf)
			local w, h = math.min(120, vim.o.columns - 4), math.min(25, vim.o.lines - 4)
			return vim.api.nvim_open_win(fbuf, true, {
				relative = "cursor", row = 1, col = 0, width = w, height = h, border = "rounded", title = " " .. path .. " ",
			})
		end
	end
	notify("no link under the cursor")
end

function M.attach(buf)
	local map = function(lhs, fn, desc) vim.keymap.set("n", lhs, fn, { buffer = buf, desc = desc }) end
	map("gd", function() M.follow() end, "Go to linked ADR")
	map("gpd", function() M.follow(true) end, "Peek linked ADR")
	map("]A", function() M.jump(1) end, "Next ADR")
	map("[A", function() M.jump(-1) end, "Previous ADR")
	map("<leader>Aa", function() M.set_status("Accepted") end, "Accept")
	map("<leader>Ar", function() M.set_status("Rejected") end, "Reject")
	map("<leader>Ad", function() M.set_status("Deprecated") end, "Deprecate")
	map("<leader>As", function() M.set_status("Superseded") end, "Supersede")
	M.decorate(buf)
	vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
		buffer = buf,
		callback = function(ev) M.decorate(ev.buf) end,
	})
end

return M
