-- tmux integration: Alt-h/j/k/l moves between nvim splits and tmux panes as if
-- they were one thing; Alt-Shift-h/j/k/l resizes. The tmux side is in the tmux
-- repo (conf/keys.conf): it sends the key to nvim when @pane-is-vim is set,
-- which this plugin does. Ctrl-h/l stay your side-scroll keys.
-- Outside tmux the same keys just move between and resize nvim splits.
local function ss(fn)
	return function() require("smart-splits")[fn]() end
end

return {
	{
		"mrjones2014/smart-splits.nvim",
		lazy = false, -- must start with nvim so tmux knows this pane is nvim
		opts = {
			at_edge = "stop", -- same as tmux: no wrapping to the other side
			default_amount = 3,
		},
		keys = {
			{ "<A-h>", ss("move_cursor_left"), desc = "Split / tmux pane left" },
			{ "<A-j>", ss("move_cursor_down"), desc = "Split / tmux pane down" },
			{ "<A-k>", ss("move_cursor_up"), desc = "Split / tmux pane up" },
			{ "<A-l>", ss("move_cursor_right"), desc = "Split / tmux pane right" },
			{ "<A-H>", ss("resize_left"), desc = "Resize split left" },
			{ "<A-J>", ss("resize_down"), desc = "Resize split down" },
			{ "<A-K>", ss("resize_up"), desc = "Resize split up" },
			{ "<A-L>", ss("resize_right"), desc = "Resize split right" },
		},
	},
}
