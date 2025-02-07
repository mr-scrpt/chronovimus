local history = require("chronovimus.history")
local picker = require("chronovimus.picker")
local M = {}

-- Инициализируем отслеживание файлов сразу при загрузке модуля
local initialized = false
local function init_autocmds()
	if initialized then
		return
	end

	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*",
		callback = function()
			local file = vim.api.nvim_buf_get_name(0)
			if file ~= "" then
				history.add_to_history(file)
			end
		end,
	})
	initialized = true
end

-- Инициализируем автокоманды сразу
init_autocmds()

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

	-- Если кеймапы не определены через lazy.nvim, устанавливаем их здесь
	if not opts.keys then
		local default_keys = {
			{
				mode = "n",
				lhs = "<leader>bp",
				rhs = ":HistoryBack<CR>",
				opts = { silent = true, desc = "History Back" },
			},
			{
				mode = "n",
				lhs = "<leader>bn",
				rhs = ":HistoryForward<CR>",
				opts = { silent = true, desc = "History Forward" },
			},
			{
				mode = "n",
				lhs = "<leader>bl",
				rhs = ":HistoryList<CR>",
				opts = { silent = true, desc = "History List" },
			},
		}

		for _, mapping in ipairs(default_keys) do
			local mode = mapping.mode or "n"
			local lhs = mapping.lhs
			local rhs = mapping.rhs
			local keyopts = mapping.opts or {}
			vim.keymap.set(mode, lhs, rhs, keyopts)
		end
	end
end

return M
