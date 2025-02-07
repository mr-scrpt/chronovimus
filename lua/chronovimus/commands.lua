local history = require("chronovimus.history")

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("HistoryBack", function()
		history.navigate_back()
	end, {})

	vim.api.nvim_create_user_command("HistoryForward", function()
		history.navigate_forward()
	end, {})

	vim.api.nvim_create_user_command("HistoryDebug", function()
		history.debug_history()
	end, {})

	vim.keymap.set("n", "<leader>bp", ":HistoryBack<CR>", { silent = true })
	vim.keymap.set("n", "<leader>bn", ":HistoryForward<CR>", { silent = true })
	vim.keymap.set("n", "<leader>bl", ":HistoryList<CR>", { silent = true })
end

return M
