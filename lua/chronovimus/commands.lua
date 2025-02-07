local history = require("chronovimus.history")
local picker = require("chronovimus.picker")
local M = {}

-- Выполняем основную инициализацию плагина сразу при загрузке
history.setup()

function M.setup(opts)
	opts = opts or {}

	-- Создаем пользовательские команды
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
end

return M
