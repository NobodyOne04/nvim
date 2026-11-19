-- Where plugins, language servers, parsers and the python host live: outside home, next to the
-- repos (archminimal-setup ADR-0010). $ARCHMINIMAL_PLUGINS comes from the zsh repo; nvim started
-- outside zsh falls back to the same default. Machines without /opt/archminimal keep stdpath("data").
if vim.uv.fs_stat("/opt/archminimal") then
	local base = vim.env.ARCHMINIMAL_PLUGINS
	return ((base and base ~= "") and base or "/opt/archminimal/plugins") .. "/nvim"
end
return vim.fn.stdpath("data")
