-- ┌─────────────────────────────────────────────┐
-- │ nvim · archminimal                          │
-- │ options → keymaps → autocmds → plugins      │
-- └─────────────────────────────────────────────┘

-- Leader must be set before any mapping or plugin uses it.
-- "\" was the effective leader before (it was never set); kept so muscle
-- memory still works. Change both to " " for a Space leader.
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
