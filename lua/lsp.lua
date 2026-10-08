local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

local on_attach = function(_, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end

local servers = { "pyright", "ts_ls", "lua_ls", "bashls" }

for _, server in ipairs(servers) do
	vim.lsp.config(server, {
		on_attach = on_attach,
		capabilities = capabilities,
	})
end
