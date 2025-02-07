local history = require("chronovimus.history")
local picker = require("chronovimus.picker")
local M = {}

function M.setup(opts)
	opts = opts or {}

	vim.api.nvim_create_user_command("HistoryBack", function()
		history.navigate_back()
	end, {})

	vim.api.nvim_create_user_command("HistoryForward", function()
		history.navigate_forward()
	end, {})

	vim.api.nvim_create_user_command("HistoryDebug", function()
		history.debug_history()
	end, {})

	vim.api.nvim_create_user_command("HistoryList", function()
		picker.show_history_in_picker()
	end, {})

	local default_keys = {
		{ mode = "n", lhs = "<leader>bp", rhs = ":HistoryBack<CR>", opts = { silent = true, desc = "History Back" } },
		{
			mode = "n",
			lhs = "<leader>bn",
			rhs = ":HistoryForward<CR>",
			opts = { silent = true, desc = "History Forward" },
		},
		{ mode = "n", lhs = "<leader>bl", rhs = ":HistoryList<CR>", opts = { silent = true, desc = "History List" } },
	}

	local keymaps = opts.keys or default_keys
	for _, mapping in ipairs(keymaps) do
		local mode = mapping.mode or "n"
		local lhs = mapping.lhs or mapping[1]
		local rhs = mapping.rhs or mapping[2]
		local keyopts = mapping.opts or {}
		vim.keymap.set(mode, lhs, rhs, keyopts)
	end
end

return M
